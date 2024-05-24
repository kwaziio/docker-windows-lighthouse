#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [String]       $CertificateDirectory    = "C:\\Certificates",
  [Int]          $ChromeDebugPort         = 9222,
  [String]       $CustomAuthScript        = "C:\\Data\\authenticate.js",
  [Bool]         $EnableAdvancedAuth      = $false,
  [String]       $ExecuteAuthScript       = "C:\\Scripts\\Execute-Authentication.ps1",
  [String]       $File                    = $null,
  [Bool]         $ForceShutdown           = $false,
  [Bool]         $InjectBasicCreds        = $false,
  [String]       $LighthouseExecutable    = "lighthouse",
  [Bool]         $LoadCertificates        = $false,
  [String]       $NPXExecutable           = "npx",
  [SecureString] $Password                = $null,
  [String]       $ReportDirectory         = "C:\Reports",
  [String]       $ReportExtension         = "report.html",
  [string]       $StartChromeScript       = "C:\\Scripts\\Start-Chrome.ps1",
  [string]       $StopChromeScript        = "C:\\Scripts\\Stop-Chrome.ps1",
  [String]       $TrustCertificatesScript = "C:\\Scripts\\Trust-Certificates.ps1",
  [String]       $URL                     = $null,
  [String[]]     $URLs                    = @(),
  [String]       $Username                = $null
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CERTIFICATE_DIRECTORY) { $CertificateDirectory = [String]   $env:CERTIFICATE_DIRECTORY }
if ($null -ne $env:CHROME_DEBUG_PORT)     { $ChromeDebugPort      = [Int]      $env:CHROME_DEBUG_PORT }
if ($null -ne $env:CUSTOM_AUTH_SCRIPT)    { $CustomAuthScript     = [Int]      $env:CUSTOM_AUTH_SCRIPT }
if ($null -ne $env:ENABLE_ADVANCED_AUTH)  { $EnableAdvancedAuth   = [Bool]     $env:ENABLE_ADVANCED_AUTH }
if ($null -ne $env:FILE)                  { $File                 = [String]   $env:FILE }
if ($null -ne $env:FORCE_SHUTDOWN)        { $ForceShutdown        = [Bool]     $env:FORCE_SHUTDOWN }
if ($null -ne $env:INJECT_BASIC_CREDS)    { $InjectBasicCreds     = [Bool]     $env:INJECT_BASIC_CREDS }
if ($null -ne $env:LIGHTHOUSE_EXECUTABLE) { $LighthouseExecutable = [String]   $env:LIGHTHOUSE_EXECUTABLE }
if ($null -ne $env:LOAD_CERTIFICATES)     { $LoadCertificates     = [Bool]     $env:LOAD_CERTIFICATES }
if ($null -ne $env:NPX_EXECUTABLE)        { $NPXExecutable        = [String]   $env:NPX_EXECUTABLE }
if ($null -ne $env:REPORTS_DIRECTORY)     { $ReportDirectory      = [String]   $env:REPORTS_DIRECTORY }
if ($null -ne $env:REPORTS_EXTENSION)     { $ReportExtension      = [String]   $env:REPORTS_EXTENSION }
if ($null -ne $env:URL)                   { $URL                  = [String]   $env:URL }
if ($null -ne $env:URLs)                  { $URLs                 = [String[]] $env:URLs -Split "," }
if ($null -ne $env:USERNAME)              { $Username             = [String]   $env:USERNAME }

#########################################################################
# Updates the Password Value for Basic Auth Credentials (if Applicable) #
#########################################################################

Write-Output "Processing Password Value (if Applicable)..."
$securePassword = $null

if ($null -ne $Password)     { $securePassword = ConvertFrom-SecureStringToPlainText -SecureString $Password }
if ($null -ne $env:PASSWORD) { $securePassword = $env:PASSWORD }

####################################################
# Adds Single URL to Array of URLs (if Applicable) #
####################################################

if ($null -ne $URL -and "" -ne $URL) {
  $URLs += $URL
}

####################################################################
# Adds URLs in Configuration File to Array of URLs (if Applicable) #
####################################################################

if ($null -ne $File -and "" -ne $File) {
  Write-Output "Searching for URL Input File ${File}..." 
  if (Test-Path $File) {
    Write-Output "File Found; Adding Endpoints to List of URLs..."
    Get-Content $File | ForEach-Object { $URLs += $_ }
  } else {
    Write-Output "File NOT Found: ${File}"
    Exit 1
  }
}

#############################################################
# Verifies Minimum Number of URLs are Provided for Analysis #
#############################################################

if ($URLs.Count -eq 0) {
  Write-Output "NO URLs Provided for Analysis! Exiting..."
  Exit 2
}

#######################################################################################
# Adds Mounted Certificates to List of Trusted Certificates for Operating System (OS) #
#######################################################################################

if ($LoadCertificates) {
  & $TrustCertificatesScript -CertificateDirectory $CertificateDirectory
}

#####################################################################
# Launches Google Chrome with Debugging Enabled via External Script #
#####################################################################

Write-Output "Launching Google Chrome via Startup Script (${StartChromeScript})..."
& $StartChromeScript -ChromeDebugPort $ChromeDebugPort

#################################################################
# Executes Google Lighthouse Analysis Against All Targeted URLs #
#################################################################

try {
  Write-Output "Beginning Analysis Against $($URLs.Count) URLs..."
  $isFirst = $true

  ################################################################
  # Executes Analysis Process for Each Individually Targeted URL #
  ################################################################

  $URLs.Where({ $_ -Match "^http.*" }) | ForEach-Object {
    $targetedURL = $_
    Write-Output "Analyzing Targeted URL ${targetedURL}"

    ##########################################################
    # Executes ICAM Authentication for Microsoft Environment #
    ##########################################################

    if ($isFirst -and $EnableAdvancedAuth) {
      Write-Output "Advanced Authentication Enabled; Preparing to Authenticate as ${Username}..."
      & $ExecuteAuthScript `
        -ChromeDebugPort $ChromeDebugPort `
        -CustomAuthScript $CustomAuthScript `
        -InjectBasicCreds $InjectBasicCreds `
        -Password $Password `
        -URLs $URLs `
        -Username $Username
    }

    ##########################################################
    # Injects Basic Auth Credentials via URL (if Applicable) #
    ##########################################################

    if ($InjectBasicCreds) {
      Write-Output "Generating Basic Auth Credentials..."
      $encodedUsername = [System.Net.WebUtility]::UrlEncode($Username)
      $encodedPassword = [System.Net.WebUtility]::UrlEncode($securePassword)

      Write-Output "Injecting Basic Auth Credentials..."
      $targetedURL = $targetedURL -Replace "://", "://${encodedUsername}:${encodedPassword}@"
    }

    #######################################################
    # Dynamically Generates HTML Report's Output Location #
    #######################################################

    Write-Output "Dynamically Generating Output Location..."
    $reportPath = $targetedURL -Replace ".*://", ""
    $reportPath = $reportPath -Replace ".*@", ""
    $reportPath = $reportPath -Replace "[^A-Za-z0-9._-]", "_"
  
    if ($reportPath.EndsWith("_")) {
      $reportPath = $reportPath.Substring(0, $reportPath.Length - 1)
    }

    #################################################################
    # Executes Google Lighthouse CLI via Globally-Available Command #
    #################################################################
  
    Write-Output "Executing Google Lighthouse CLI..."
    & $LighthouseExecutable $targetedURL `
      --no-enable-error-reporting `
      --output=html `
      --output-path "${ReportDirectory}\${reportPath}.${ReportExtension}" `
      --port $ChromeDebugPort `
      --quiet

    ###########################################################
    # Redacts Embedded Basic Auth Credentials (if Applicable) #
    ###########################################################

    if ($InjectBasicCreds) {
      Write-Output "Generating Basic Auth Credentials..."
      $encodedUsername = [System.Net.WebUtility]::UrlEncode($Username)
      $encodedPassword = [System.Net.WebUtility]::UrlEncode($securePassword)

      Write-Output "Redacting Embedded Basic Auth Credentials..."
      $content = Get-Content -Path "${ReportDirectory}\${reportPath}.${ReportExtension}" -Raw
      $content = $content.Replace("${encodedUsername}:${encodedPassword}@", "")
      Set-Content -Path "${ReportDirectory}\${reportPath}.${ReportExtension}" -Value $content
    }

  }

} catch {
  Write-Output "An Unexpected Error Occurred (Now Terminating Chrome): ${_}"
  & $StopChromeScript -ChromeDebugPort $ChromeDebugPort
  Exit 3
}

#########################################################
# Terminates Google Chrome Instance via External Script #
#########################################################

Write-Output "Terminating Google Chrome via Shutdown Script (${StopChromeScript})..."
& $StopChromeScript -ChromeDebugPort $ChromeDebugPort

###################################################
# Prints Analysis Result Message and Exits Script #
###################################################

Write-Output "Completed Analysis of All Targeted URLs"

#############################################
# Forces Container to Shutdown (if Enabled) #
#############################################

if ($ForceShutdown) {
  Write-Output "Standard Exit Command Ignored; Forcing Container Termination..."
  Stop-Computer -Force
} else {
  Exit 0
}
