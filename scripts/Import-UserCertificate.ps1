#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String] $CertificatePass  = "",
  [String] $CertificatePath  = "",
  [String] $CertificateStore = "Cert:\CurrentUser\My"
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CERTIFICATE_PASSWORD) { $CertificatePass  = [String] $env:CERTIFICATE_PASSWORD }
if ($null -ne $env:CERTIFICATE_PATH)     { $CertificatePath  = [String] $env:CERTIFICATE_PATH }
if ($null -ne $env:CERTIFICATE_STORE)    { $CertificateStore = [String] $env:CERTIFICATE_STORE }

######################################################################
# Imports PFX Certificates for Personal Usage with Mutual-TLS (mTLS) #
######################################################################

Write-Output "Creating Secure String for Certificate Password..."
$password = ConvertTo-SecureString -String $CertificatePass -AsPlainText -Force

Write-Output "Importing PFX-Formatted User Certificate..."
Import-PfxCertificate -FilePath $CertificatePath -Password $password -CertStoreLocation $CertificateStore
