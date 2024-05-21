#############################################
# PowerShell Script Parameter Configuration #
#############################################

param (
  [Int] $ChromeDebugPort = 9222
)

#######################################################################
# Overrides Default Values with Environment Variables (if Applicable) #
#######################################################################

if ($null -ne $env:CHROME_DEBUG_PORT) { $ChromeDebugPort = [Int]$env:CHROME_DEBUG_PORT }

#######################################################################
# Retrieves Process ID Associated with Running Google Chrome Instance #
#######################################################################

Write-Output "Checking for Process Running on Port ${ChromeDebugPort}..."
$processID = (Get-NetTCPConnection -LocalPort $ChromeDebugPort -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }).OwningProcess

#############################################
# Terminates Running Google Chrome Instance #
#############################################

Write-Output "Terminating Google Chrome Instance with Process ID ${processID}..."
taskkill /PID $processID /F
Exit 0
