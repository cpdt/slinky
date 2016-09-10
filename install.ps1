param(
    [string]$v = $false,
    [switch]$h = $false,
    [string]$bash_exe = $false,
    [string]$install_dir = $false,
    [string]$win_link_dir = $false,
    [string]$linux_link_dir = $false,
    [string]$command_prepend = $false,
    [string]$allow_path = $false
)

# asks a question - first parameter is the question, second is the default value (for if the user leaves it empty)
function Read-Question {
    Write-Host -NoNewline $args[0] -ForegroundColor Cyan
    Write-Host -NoNewline " [$($args[1])]" -ForegroundColor DarkYellow
    $in = Read-Host -prompt ' '
    if ($in) { $in } else { $args[1] }
}

Write-Host "Loading versions..."

$client = New-Object System.Net.WebClient

try {
    $tags = Invoke-WebRequest 'https://api.github.com/repos/cpdt/slinky/tags' | ConvertFrom-Json
    $branches = Invoke-WebRequest 'https://api.github.com/repos/cpdt/slinky/branches' | ConvertFrom-Json
} catch [System.Net.WebException] {
    Write-Host ""
    Write-Host "Oops!" -ForegroundColor Red
    Write-Host "Couldn't fetch the list of versions. You may not be connected to the internet, or Github may be down." -ForegroundColor Red
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host (ConvertFrom-Json $_).message -ForegroundColor Red
    exit
}

$options = ($tags + $branches) | % {$_.name}

$install_ver = if ($v -ne $false) {
    if (!$options.Contains($v)) {
        Write-Host "Unknown version $v"
        exit 1
    }
    $v
} else {
    do {
        Write-Host ""
        Write-Host -NoNewline "Available versions: "
        Write-Host ($options -join ', ') -ForegroundColor DarkYellow
        $entered_ver = (Read-Question "Version to install" $options[0]).ToLower()

        $is_valid = $options.Contains($entered_ver)
        if (!$is_valid) {
            Write-Host "Please provide a valid version." -ForegroundColor Red
        }
    } while (!$is_valid)

    $entered_ver
}

Write-Host "Downloading installer for $install_ver"

$root_url = "https://raw.githubusercontent.com/cpdt/slinky/$install_ver"

try {
    $installer_content = $client.DownloadString("$root_url/install-version.ps1")
    iex $installer_content
} catch [System.Net.WebException] {
    try {
        # for versions pre-1.4, need to use install.ps1
        $installer_content = $client.DownloadString("$root_url/install.ps1")
        iex $installer_content
    } catch [System.Net.WebException] {
        # versions pre-1.3 use the old Bash installer
        Write-Host ""
        Write-Host "The specified version uses the old installer."
        Write-Host "This version is only compatible with Bash on Ubuntu for Windows, and can be installed by running the following command in Bash:"
        Write-Host ""
        Write-Host "  apt-get install curl && curl -o- https://raw.githubusercontent.com/cpdt/slinky/$install_ver/install.sh | bash" -ForegroundColor Yellow
    }
}