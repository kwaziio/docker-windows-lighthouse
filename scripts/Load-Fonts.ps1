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

################################################
# C# Code for Adding Font Resources to Windows # 
################################################

$code = @'
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;

namespace FontResource {

  public class AddRemoveFonts {

    [DllImport("gdi32.dll")]
    static extern int AddFontResource(string lpFilename);

    public static int AddFont(string fontFilePath) {
      try {
        return AddFontResource(fontFilePath);
      } catch {
        return 0;
      }
    }

  }

}
'@

#########################################################
# Loads Available Fonts for Use by Windows Applications #
#########################################################
 
Add-Type $code

foreach ($font in $(Get-ChildItem $FontDirectory)) {
  Write-Output "Loading $($font.FullName)..."
  [FontResource.AddRemoveFonts]::AddFont($font.FullName)
}

Write-Output "Successfully Loaded Available Fonts..."
Exit 0
