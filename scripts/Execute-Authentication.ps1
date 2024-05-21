#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [Int]          $ChromeDebugPort  = 9222,
  [String]       $CustomAuthScript = "C:\\Data\\authenticate.js",
  [Bool]         $InjectBasicCreds = $false,
  [String]       $NodeExecutable   = "node",
  [SecureString] $Password         = $null,
  [String[]]     $URLs             = @(),
  [String]       $Username         = $null
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CHROME_DEBUG_PORT)     { $ChromeDebugPort      = [Int]      $env:CHROME_DEBUG_PORT }
if ($null -ne $env:CUSTOM_AUTH_SCRIPT)    { $CustomAuthScript     = [Int]      $env:CUSTOM_AUTH_SCRIPT }
if ($null -ne $env:FILE)                  { $File                 = [String]   $env:FILE }
if ($null -ne $env:INJECT_BASIC_CREDS)    { $InjectBasicCreds     = [Bool]     $env:INJECT_BASIC_CREDS }
if ($null -ne $env:NODE_EXECUTABLE)       { $NodeExecutable       = [String]   $env:NODE_EXECUTABLE }
if ($null -ne $env:URLs)                  { $URLs                 = [String[]] $env:URLs -Split "," }
if ($null -ne $env:USERNAME)              { $Username             = [String]   $env:USERNAME }

#########################################################################
# Updates the Password Value for Basic Auth Credentials (if Applicable) #
#########################################################################

Write-Output "Processing Password Value (if Applicable)..."
$securePassword = $null

if ($null -ne $Password)     { $securePassword = ConvertFrom-SecureStringToPlainText -SecureString $Password }
if ($null -ne $env:PASSWORD) { $securePassword = $env:PASSWORD }

#############################################################
# Executes Custom NodeJS Script for Advanced Authentication #
#############################################################

Write-Output "Retrieving Google Chrome DevTools Debugger URL..."
$debuggerURL = (Invoke-RestMethod -URI "http://localhost:${ChromeDebugPort}/json/version" -Method GET).webSocketDebuggerUrl

Write-Output "Executing Custom Authentictation Script at ${CustomAuthScript}..."
& $NodeExecutable $CustomAuthScript --debuggerURL $debuggerURL --initialURL $URLs[0] --username $Username --password $securePassword
