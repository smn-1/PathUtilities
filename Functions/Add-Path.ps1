function Add-Path {
    <#
    .SYNOPSIS
    Adds a specified directory to the Windows PATH environment variable.

    .DESCRIPTION
    This function checks if the provided directory path exists and whether it is already in the PATH variable.
    If the path is valid and not already included, it appends it to the PATH environment variable.

    .PARAMETER Path
    The directory to add to the PATH environment variable.

    .PARAMETER Target
    Specifies whether to add the path to the User or System environment variable. Valid values are "User" or "System".

    .EXAMPLE
    Add-Path -Path 'C:\Source\Scripts' -Target User
    Adds the specified directory to the User PATH.

    .NOTES
    - Modifying the System PATH requires administrative privileges.
    - Use -WhatIf and -Confirm for safety.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "System")]
        [string]$Target
    )

    try {
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Write-Error "'$Path' is not a valid directory path."
            return
        }

        $envTarget = if ($Target -eq "System") {
            [EnvironmentVariableTarget]::Machine
        } else {
            [EnvironmentVariableTarget]::User
        }
        $envPath = [Environment]::GetEnvironmentVariable("Path", $envTarget)

        # Split and clean the PATH entries
        $pathArray = $envPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

        # Check if the path already exists
        if ($pathArray -contains $Path) {
            Write-Output "'$Path' is already in the $Target PATH."
            return
        }

        # Add the path with confirmation
        if ($PSCmdlet.ShouldProcess("$Target PATH", "Add '$Path'")) {
            $newPath = "$envPath;$Path"
            [Environment]::SetEnvironmentVariable("Path", $newPath, $envTarget)
            Write-Output "'$Path' has been added to the $Target PATH."
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}
