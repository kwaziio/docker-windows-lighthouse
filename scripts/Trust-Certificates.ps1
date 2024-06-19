#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $CertificateDirectory = "C:\\Certificates",
  [String] $CertificateFilter    = "*.cer"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CERTIFICATE_DIRECTORY) { $CertificateDirectory = [String] $env:CERTIFICATE_DIRECTORY }

######################################################################################
# Imports Trusted Certificates to the Operating System's (OS) Root Certificate Store #
######################################################################################

Write-Output "Retrieving List of Mounted Certificates..."
$certificates = Get-ChildItem -Path $CertificateDirectory -Filter $CertificateFilter

foreach ($certificate in $certificates) {
  Write-Output "Adding $($certificate.FullName) to Trusted Certificate Store..."
  Import-Certificate -FilePath $certificate.FullName -CertStoreLocation Cert:\LocalMachine\Root
}
