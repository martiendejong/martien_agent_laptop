# clickable-paths.ps1
# Converts file paths in output to clickable VSCode/Windows Explorer links
# Makes navigation faster by eliminating copy-paste

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$Text,

    [ValidateSet("VSCode", "Explorer", "Both", "None")]
    [string]$LinkFormat = "VSCode",

    [switch]$AsHTML
)

function Convert-PathToClickable {
    param(
        [string]$InputText,
        [string]$Format
    )

    # Regex to match file paths (C:\..., /c/..., etc.)
    $pathPattern = '(?:C:\\|/c/)[^\s\)\]"<>|]+'

    $matches = [regex]::Matches($InputText, $pathPattern)

    $result = $InputText

    foreach ($match in $matches) {
        $path = $match.Value

        # Normalize path
        $normalizedPath = $path -replace '/c/', 'C:\' -replace '/', '\'

        # Check if file exists
        if (Test-Path $normalizedPath) {
            $clickableLink = ""

            switch ($Format) {
                "VSCode" {
                    # VSCode link: code --goto <path>
                    $clickableLink = "vscode://file/$($normalizedPath -replace '\\', '/')"
                }
                "Explorer" {
                    # Windows Explorer: explorer /select,<path>
                    $clickableLink = "file:///$($normalizedPath -replace '\\', '/')"
                }
                "Both" {
                    $vscodeLink = "vscode://file/$($normalizedPath -replace '\\', '/')"
                    $explorerLink = "file:///$($normalizedPath -replace '\\', '/')"
                    $clickableLink = "$vscodeLink | $explorerLink"
                }
            }

            if ($AsHTML) {
                # HTML link format
                $htmlLink = "<a href=`"$clickableLink`">$path</a>"
                $result = $result -replace [regex]::Escape($path), $htmlLink
            } else {
                # PowerShell / Terminal format (ANSI escape codes)
                # Use OSC 8 hyperlink: \e]8;;URL\e\\TEXT\e]8;;\e\\
                $ansiLink = "`e]8;;$clickableLink`e\\$path`e]8;;`e\\"
                $result = $result -replace [regex]::Escape($path), $ansiLink
            }
        }
    }

    return $result
}

# Main logic
$output = Convert-PathToClickable -InputText $Text -Format $LinkFormat

Write-Output $output
