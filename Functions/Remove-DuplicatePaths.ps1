function Remove-DuplicatePaths {
    <#
    .SYNOPSIS
    Removes duplicate entries from the Windows PATH environment variable.

    .DESCRIPTION
    This function scans the PATH environment variable (User or System),
    identifies duplicate paths, removes them, and updates the PATH variable.

    .PARAMETER Target
    Specifies whether to clean the User or System environment variable. Valid values are "User" or "System". Default is "User".

    .EXAMPLE
    Remove-DuplicatePaths -Target User
    Removes duplicates from the User PATH variable.

    .NOTES
    - Modifying the System PATH requires administrative privileges.
    - Use -WhatIf and -Confirm for safety.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("User", "System")]
        [string]$Target = "User"
    )

    try {
        $envTarget = if ($Target -eq "System") {
            [EnvironmentVariableTarget]::Machine
        } else {
            [EnvironmentVariableTarget]::User
        }

        $envPath = [Environment]::GetEnvironmentVariable("Path", $envTarget)

        if (-not $envPath) {
            Write-Output "The $Target PATH variable is empty or not found."
            return
        }

        $pathArray = $envPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

        # Remove duplicates and preserve the order
        $uniquePaths = [System.Collections.Generic.List[string]]::new()
        foreach ($path in $pathArray) {
            if (-not ($uniquePaths -contains $path)) {
                $uniquePaths.Add($path)
            }
        }

        if ($uniquePaths.Count -eq $pathArray.Count) {
            Write-Output "No duplicate paths found in the $Target PATH variable."
            return
        }

        # Update the PATH variable with confirmation
        if ($PSCmdlet.ShouldProcess("$Target PATH", "Remove duplicate paths")) {
            $newPath = $uniquePaths -join ';'
            [Environment]::SetEnvironmentVariable("Path", $newPath, $envTarget)
            Write-Output "Duplicate paths have been removed from the $Target PATH variable."
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}