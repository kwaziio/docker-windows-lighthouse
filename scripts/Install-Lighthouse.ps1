#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $LighthouseExecutable = "lighthouse",
  [String] $NPMExecutable        = "npm"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:LIGHTHOUSE_EXECUTABLE) { $LighthouseExecutable = [String] $env:LIGHTHOUSE_EXECUTABLE }
if ($null -ne $env:NPM_EXECUTABLE)        { $NPMExecutable        = [String] $env:NPM_EXECUTABLE }

#################################################################
# Installs Google Lighthouse CLI via Node Package Manager (NPM) #
#################################################################

& $NPMExecutable install -g lighthouse

###########################################################
# Validates that Google Chrome has Successfully Installed #
###########################################################

Write-Output "Validating Google Lighthouse CLI Installation..."
if (Get-Command $LighthouseExecutable -ErrorAction SilentlyContinue) {
  Write-Output "Successfully Installed Google Lighthouse CLI"
} else {
  Write-Output "Failed to Install Google Lighthouse CLI!"
  exit $1
}
