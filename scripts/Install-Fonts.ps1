#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $FontDirectory = "C:\Windows\Fonts"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:FONT_DIRECTORY) { $FontDirectory = [String] $env:FONT_DIRECTORY }

##################################################################
# Installs Locally Mounted Fonts for Use by Windows Applications #
##################################################################

Write-Output "Installing All Fonts in Directory ${FontDirectory}..."
$fontFiles = Get-ChildItem -Path $FontDirectory -Filter *.ttf

foreach ($fontFile in $fontFiles) {
  $fontName         = $fontFile.Name
  $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

  Write-Output "Installing Font ${fontName}..."
  New-ItemProperty -Path $fontRegistryPath -Name $fontName -Value $fontName -PropertyType String -Force
}

Write-Output "Successfully Installed All Available Fonts"
