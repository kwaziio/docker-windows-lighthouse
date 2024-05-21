#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $NPMExecutable = "npm"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:NPM_EXECUTABLE) { $NPMExecutable = [String] $env:NPM_EXECUTABLE }

#######################################################################################
# Installs Puppeteer and Additional Required Libraries via Node Package Manager (NPM) #
#######################################################################################

Write-Output "Installing Puppeteer via Node Package Manager (NPM)..."
& $NPMExecutable install -g puppeteer

Write-Output "Installing YArgs Package via Node Package Manager (NPM)..."
& $NPMExecutable install -g yargs

Write-Output "Installing UUID Package via Node Package Manager (NPM)..."
& $NPMExecutable install -g uuid
