#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $NodeDownloadPath = "C:\nodejs.msi",
  [String] $NodeExecutable   = "node",
  [String] $NodeReleaseURL   = "https://nodejs.org/dist/index.json",
  [String] $NPMExecutable    = "npm"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:NODE_DOWNLOAD_PATH) { $NodeDownloadPath = [String] $env:NODE_DOWNLOAD_PATH }
if ($null -ne $env:NODE_DOWNLOAD_URL)  { $NodeDownloadURL  = [String] $env:NODE_DOWNLOAD_URL }
if ($null -ne $env:NODE_EXECUTABLE)    { $NodeExecutable   = [String] $env:NODE_EXECUTABLE }
if ($null -ne $env:NODE_RELEASE_URL)   { $NodeReleaseURL   = [String] $env:NODE_RELEASE_URL }
if ($null -ne $env:NPM_EXECUTABLE)     { $NPMExecutable    = [String] $env:NPM_EXECUTABLE }

###############################################################
# Retrieves Latest NodeJS Version via Official NodeJS Website #
###############################################################

if ($null -eq $NodeDownloadURL) {
  Write-Output "Retrieving List of NodeJS Releases from Official Website..."

  $NodeReleaseURL  = "https://nodejs.org/dist/index.json"
  $releases        = Invoke-RestMethod -Uri $NodeReleaseURL
  $mostRecent      = $releases | Sort-Object -Property { [datetime]$_."date" } -Descending | Select-Object -First 1
  $nodeVersion     = $mostRecent.version
  $NodeDownloadURL = "https://nodejs.org/dist/${nodeVersion}/node-${nodeVersion}-x64.msi"
}

###########################################################
# Downloads Official NodeJS Installer from NodeJS Website #
###########################################################

Write-Output "Downloading Official NodeJS Installer at ${NodeDownloadURL}..."
$webClient = New-Object net.WebClient
$webClient.DownloadFile($NodeDownloadURL, $NodeDownloadPath)

#########################################################
# Installs NodeJS via Offical Microsoft Installer (MSI) #
#########################################################

Write-Output "Installing NodeJS via Official Microsoft Installer (MSI)..."
Start-Process msiexec.exe -ArgumentList "/i ${NodeDownloadPath} /quiet /norestart" -NoNewWindow -Wait

##############################################################
# Updates Global Path Environment Variable to Support NodeJS #
##############################################################

Write-Output "Adding NodeJS and Node Package Manager (NPM) to the System Path..."
$env:PATH = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";C:\Program Files\nodejs"
[System.Environment]::SetEnvironmentVariable('Path', $env:PATH, [System.EnvironmentVariableTarget]::Machine)

########################################################################
# Updates Node Package Manager (NPM) Installed via MSI (if Applicable) #
########################################################################

Write-Output "Updating Node Package Manager (NPM) to Latest Version..."
& $NPMExecutable install -g "npm@latest"

###################################################
# Removes Temporarily Downloaded NodeJS Artifacts #
###################################################

Write-Output "Removing Official Installer for NodeJS..."
Remove-Item $NodeDownloadPath -Force

####################################################
# Validates that NodeJS has Successfully Installed #
####################################################

Write-Output "Validating NodeJS Installation..."
if (Get-Command $NodeExecutable -ErrorAction SilentlyContinue) {
  Write-Output "Successfully Installed NodeJS"
} else {
  Write-Output "Failed to Install NodeJS!"
  exit $1
}
