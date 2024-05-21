#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $ChromeDownloadPath = "C:\chrome-installer.exe",
  [String] $ChromeDownloadURL  = "https://dl.google.com/chrome/install/latest/chrome_installer.exe",
  [String] $ChromeExecutable   = "chrome.exe"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CHROME_DOWNLOAD_PATH) { $ChromeDownloadPath = [String] $env:CHROME_DOWNLOAD_PATH }
if ($null -ne $env:CHROME_DOWNLOAD_URL)  { $ChromeDownloadURL  = [String] $env:CHROME_DOWNLOAD_URL }
if ($null -ne $env:CHROME_EXECUTABLE)    { $ChromeExecutable   = [String] $env:CHROME_EXECUTABLE }

##########################################################
# Downloads Official Google Chrome Installer from Google #
##########################################################

Write-Output "Downloading Official Google Chrome Installer via Google..."
$webClient = New-Object net.WebClient
$webClient.DownloadFile($ChromeDownloadURL, $ChromeDownloadPath)

#####################################################
# Installs Google Chrome via the Official Installer #
#####################################################

Write-Output "Installing Google Chrome via Official Installer..."
Start-Process -FilePath $ChromeDownloadPath -ArgumentList "/silent /install" -NoNewWindow -Wait

#####################################################################
# Updates Global Path Environment Variable to Support Google Chrome #
#####################################################################

Write-Output "Adding Google Chrome to the System Path..."
$chromePath = "C:\Program Files (x86)\Google\Chrome\Application"
$env:PATH = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";${chromePath}"
[System.Environment]::SetEnvironmentVariable('Path', $env:PATH, [System.EnvironmentVariableTarget]::Machine)

##########################################################
# Removes Temporarily Downloaded Google Chrome Artifacts #
##########################################################

Write-Output "Removing Official Installer for Google Chrome..."
Remove-Item $ChromeDownloadPath -Force

###########################################################
# Validates that Google Chrome has Successfully Installed #
###########################################################

Write-Output "Validating Google Chrome Installation..."
if (Get-Command $ChromeExecutable -ErrorAction SilentlyContinue) {
  Write-Output "Successfully Installed Google Chrome"
} else {
  Write-Output "Failed to Install Google Chrome!"
  exit $1
}
