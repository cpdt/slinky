if (!(Test-Path variable:global:install_ver)) {
    $install_ver = 'master' # download master (usually latest version) if not set
}

# config for installation
$download_location = "https://raw.githubusercontent.com/cpdt/slinky/$install_ver"

$step_counter = 1

# asks a question - first parameter is the question, second is the default value (for if the user leaves it empty)
function Read-Question {
    Write-Host -NoNewline $args[0] -ForegroundColor Cyan
    Write-Host -NoNewline " [$($args[1])]" -ForegroundColor DarkYellow
    $in = Read-Host -prompt ' '
    if ($in) { $in } else { $args[1] }
}

# displays a coloured configuration property - first parameter is the property name, second is the value
function Write-Conf {
    Write-Host -NoNewline "  $($args[0])" -ForegroundColor Green
    Write-Host -NoNewline '=' -ForegroundColor DarkGray
    Write-Host $args[1] -ForegroundColor DarkCyan
}

# invokes a bash command passed as the first parameter
function Invoke-Bash {
    param($command, $DieOnError = $true)

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo.FileName = $bash_dir
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.RedirectStandardInput = $true
    $p.Start() > $null

    $p.StandardInput.Write("$command`n")
    $p.StandardInput.Close()
    $p.WaitForExit()

    if ($p.ExitCode -ne 0) {
        Write-Host -NoNewline "Failed to run " -ForegroundColor Red
        Write-Host -NoNewline $command -ForegroundColor Yellow
        if ($DieOnError -eq $true) {
            Write-Host " - Slinky is NOT installed." -ForegroundColor Red
            Write-Host "Installation cannot continue, and has been aborted." -ForegroundColor Red
            exit 1
        } else {
            Write-Host ", continuing anyway" -ForegroundColor Red
        }
    }
}

# shows a list number
function Show-Step {
    Write-Host -NoNewline " $step_counter. " -ForegroundColor DarkGreen
}

Write-Host ''
Write-Host "Welcome to the Slinky ($install_ver) installation script"

# repeat running until the user says its okay
do {
    $bash_dir = Read-Question "Bash executable path (as Windows path)" (where.exe 'bash' | Select -First 1)
    $install_dir = Read-Question "Install directory (as Linux path)" '/usr/local/bin'
    $link_install_dir = Read-Question "Link install directory (as Windows path)" "$env:systemdrive\.slinky"
    $slink_install_dir = Read-Question "Link install directory (as Linux path)" "/mnt/$($env:systemdrive.Substring(0, 1).ToLower())/.slinky"
    $command_prepend = Read-Question "Text to prepend to Windows commands" ''

    # determine if the install directory is already in the PATH variable
    $add_path = if ($env:Path.Split(';') -NotContains $link_install_dir) {
        Read-Question 'Add link install directory to PATH?' 'Y/n'
    } else {
        $in_path = 'True'
        'n'
    } 
    $conf = "install_dir=`"$slink_install_dir`"`nrun_file=`"$install_dir/slinky-run.sh`"`nwin_bash=`"$bash_dir`""

    # convert slashes for paths 
    $bash_dir = $bash_dir.replace('/', '\') # windows path
    $install_dir = $install_dir.replace('\', '/') # linux path
    $link_install_dir = $link_install_dir.replace('/', '\') # windows path
    $slink_install_dir = $slink_install_dir.replace('\', '/') # linux path

    Write-Host ''
    Write-Host "Here's the contents of slinky.cfg:"
    Write-Conf "install_dir" "`"$slink_install_dir`""
    Write-Conf "run_file" "`"$install_dir/slinky-run.sh`""
    Write-Conf "win_bash" "`"$bash_dir`""
    Write-Conf "command_prepend" "`"$command_prepend`""
    Write-Conf "use_color" "true"
    $conf_ok = Read-Question 'Is this okay?' 'Y/n'
} while ($conf_ok.Substring(0, 1).ToLower() -ne "y")

Write-Host ''
Write-Host -NoNewline "Excellent! Beginning installation from "
Write-Host $download_location -ForegroundColor DarkCyan
Write-Host "  Ensuring curl is installed" -ForegroundColor DarkGreen
# the installation requires curl in bash, so install it here - some implementations (e.g. Cygwin and Git Bash) don't provide apt-get, meaning this line will fail.
# most of them include curl anyway, so everything else should be fine.
Invoke-Bash "apt-get install curl -y" -DieOnError $false

# make sure the installation path exists
Invoke-Bash "mkdir -p `"$install_dir`""

# iterate through each file to download, use curl to place it in the correct location, and ensure permissions are correct
$downloads = 'slink', 'rmslink', 'lsslink', 'delslink', 'slinky-run.sh', 'relativepath.sh'
foreach ($download in $downloads) {
    Write-Host -NoNewline "  Downloading " -ForegroundColor DarkGreen
    Write-Host -NoNewline "$download_location/$download" -ForegroundColor DarkCyan
    Write-Host -NoNewline " to " -ForegroundColor DarkGreen
    Write-Host "$install_dir/$download" -ForegroundColor DarkCyan

    # curl is used here instead of Powershell's HTTP functions as we don't know the path in Windows for the installation (in the case of many implementations,
    # the path isn't even accessible).
    Invoke-Bash "curl -o- -# `"$download_location/$download`" > `"$install_dir/$download`""
    Invoke-Bash "chmod u+rx `"$install_dir/$download`""
}

# create the .dirchange file, used to update the current directory on windows if the bash one changes
Invoke-Bash "mkdir -p `"$slink_install_dir`""
Invoke-Bash "touch `"$slink_install_dir/.dirchange`""

Write-Host "  Writing configuration file" -ForegroundColor DarkGreen
# again writing to the files with bash as we do not necessarily have access to these files from Windows
Invoke-Bash "echo -e `"install_dir=\`"$slink_install_dir\`"`" > `"$install_dir/slinky.cfg`""
Invoke-Bash "echo -e `"run_file=\`"$install_dir/slinky-run.sh\`"`" >> `"$install_dir/slinky.cfg`""
# path goes through several layers of string execution, hence why so many slashes are required (incredibly ugly, I know)
Invoke-Bash "echo -e `"win_bash=\`"$($bash_dir.replace('\', '\\\\\\\\\\\\\\\\'))\`"`" >> `"$install_dir/slinky.cfg`""
Invoke-Bash "echo -e `"command_prepend=\`"$command_prepend\`"`" >> `"$install_dir/slinky.cfg`""
Invoke-Bash "echo -e `"use_color=true`" >> `"$install_dir/slinky.cfg`""

Write-Host "  Creating Slinky command links for Windows use (if any of these fail, Slinky is not installed)" -ForegroundColor DarkGreen
# slink the actual slink commands so they are accessible from the Windows prompt, as they are implemented as shell scripts
Invoke-Bash "`"$install_dir/slink`" slink `"$install_dir/slink`""
Invoke-Bash "`"$install_dir/slink`" rmslink `"$install_dir/rmslink`""
Invoke-Bash "`"$install_dir/slink`" lsslink `"$install_dir/lsslink`""
Invoke-Bash "`"$install_dir/slink`" delslink `"$install_dir/delslink`""

# update the system environment variable if told to
$add_path_start = $add_path.Substring(0, 1).ToLower()
if ($add_path_start -eq "y") {
    Write-Host "  Adding link install directory to PATH"
    $new_path = "$env:Path;$link_install_dir"
    [Environment]::SetEnvironmentVariable("Path", $new_path, [EnvironmentVariableTarget]::Machine)
    # update the in-memory path variable in the hopes that this will prevent the need for a terminal re-start
    $env:Path = $new_path
}

# display some fun info
Write-Host "  Finished installing Slinky!" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Green
if ($add_path_start -ne "y" -And $in_path -ne 'True') {
    Show-Step
    Write-Host "Add $link_install_dir to your PATH in Windows"
    $step_counter++
}
Show-Step
$step_counter++
Write-Host -NoNewline "Run "
Write-Host -NoNewline "slink <command>" -ForegroundColor Yellow
Write-Host -NoNewline " to bind a command, and "
Write-Host -NoNewline "rmslink <command>" -ForegroundColor Yellow
Write-Host " to remove a command"

Show-Step
$step_counter++
Write-Host -NoNewline "Star Slinky on Github at "
Write-Host "https://github.com/cpdt/slinky" -ForegroundColor DarkCyan
Show-Step
Write-Host "Enjoy your brand-new command-prompt powers :)"

if ($add_path_start -eq "y") {
    Write-Host "Note: The terminal may need to be restarted in order for the commands to be accessible" -ForegroundColor DarkYellow
}

