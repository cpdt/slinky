# asks a question - first parameter is the question, second is the default value (for if the user leaves it empty)
function Read-Question {
    Write-Host -NoNewline $args[0] -ForegroundColor Cyan
    Write-Host -NoNewline " [$($args[1])]" -ForegroundColor DarkYellow
    $in = Read-Host -prompt ' '
    if ($in) { $in } else { $args[1] }
}

Write-Host "Loading versions..."

$client = New-Object System.Net.WebClient

$tags = $client.DownloadString('https://api.github.com/repos/cpdt/slinky/tags') | ConvertFrom-Json
$branches = $client.DownloadString('https://api.github.com/repos/cpdt/slinky/branches') | ConvertFrom-Json

$options = ($tags + $branches) | % {$_.name}

do {
    Write-Host ""
    Write-Host -NoNewline "Available versions: "
    Write-Host ($options -join ', ') -ForegroundColor DarkYellow
    $install_ver = (Read-Question "Version to install" $options[0]).ToLower()

    $is_valid = $options.Contains($install_ver)
    if (!$is_valid) {
        Write-Host "Please provide a valid version." -ForegroundColor Red
    }
} while (!$is_valid)

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