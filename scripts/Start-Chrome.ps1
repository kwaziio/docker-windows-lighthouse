#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [Int]    $ChromeDebugPort      = 9222,
  [String] $ChromeExecutable     = "chrome.exe",
  [Int]    $ChromeLaunchInterval = 5,
  [Int]    $ChromeLaunchRetries  = 3
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CHROME_DEBUG_PORT)      { $ChromeDebugPort      = [Int]    $env:CHROME_DEBUG_PORT }
if ($null -ne $env:CHROME_EXECUTABLE)      { $ChromeExecutable     = [String] $env:CHROME_EXECUTABLE }
if ($null -ne $env:CHROME_LAUNCH_INTERVAL) { $ChromeLaunchInterval = [Int]    $env:CHROME_LAUNCH_INTERVAL }
if ($null -ne $env:CHROME_LAUNCH_RETRIES)  { $ChromeLaunchRetries  = [Int]    $env:CHROME_LAUNCH_RETRIES }

##################################################
# Launches Google Chrome with Debug Port Enabled #
##################################################

Write-Output "Launching Chrome Instance with Debug Port Enabled..."
& $ChromeExecutable --remote-debugging-port=$ChromeDebugPort --no-sandbox

#########################################################
# Validates Google Chrome Launch by Locating Process ID #
#########################################################

Write-Output "Waiting for Google Chrome to Launch..."
$processID = $null

for ($i = 0; $i -lt $ChromeLaunchRetries; $i++) {
  Write-Output "Checking for Process Running on Port ${ChromeDebugPort}..."
  $processID = (Get-NetTCPConnection -LocalPort $ChromeDebugPort -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }).OwningProcess

  if ($null -ne $processID) { break }

  Write-Output "Google Chrome NOT Available; Waiting ${ChromeLaunchInterval} Seconds Before Retrying..."
  Start-Sleep -Seconds $ChromeLaunchInterval
}

if ($null -eq $processID) {
  Write-Output "Failed to Launch Google Chrome!"
  Exit 1
}

Write-Output "Google Chrome Instance Running with Process ID ${processID}"
Exit 0
