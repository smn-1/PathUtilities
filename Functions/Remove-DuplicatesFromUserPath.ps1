function Remove-DuplicatesFromUserPath {
    <#
    .SYNOPSIS
    Removes entries from the User PATH that are duplicates of the System PATH.

    .DESCRIPTION
    This function removes entries from the User PATH that already exist in the System PATH.

    .EXAMPLE
    Remove-DuplicatesFromUserPath
    Removes duplicates from the User PATH.

    .NOTES
    - Modifying the User PATH does not require administrative privileges.
    - Use -WhatIf and -Confirm for safety.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param ()

    # Get the System and User PATH entries
    $systemPathEntries = Get-EnvironmentPathEntries -Environment "System"
    $userPathEntries = Get-EnvironmentPathEntries -Environment "User"

    # Normalize the paths to ensure case-insensitive and consistent comparison
    $normalizedSystemPaths = $systemPathEntries | ForEach-Object { $_.TrimEnd('\').ToLowerInvariant() }

    # Find duplicates between User PATH and System PATH
    $duplicates = $userPathEntries | Where-Object {
        $normalizedSystemPaths -contains $_.TrimEnd('\').ToLowerInvariant()
    }

    # If no duplicates found, provide feedback and exit
    if (-not $duplicates) {
        Write-Host "No duplicates found between User and System PATH entries." -ForegroundColor Green
        return
    }

    # Confirm before proceeding with removal
    if ($PSCmdlet.ShouldProcess("User PATH", "Remove duplicates that exist in System PATH")) {
        # Backup User PATH before making changes
        $backupPath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupFile = "$env:USERPROFILE\UserPathBackup_$timestamp.txt"
        Set-Content -Path $backupFile -Value $backupPath
        Write-Host "User PATH has been backed up to $backupFile" -ForegroundColor Green

        # Remove duplicates from User PATH
        $normalizedDuplicates = $duplicates | ForEach-Object { $_.TrimEnd('\').ToLowerInvariant() }
        $cleanedUserPathEntries = $userPathEntries | Where-Object {
            -not ($normalizedDuplicates -contains $_.TrimEnd('\').ToLowerInvariant())
        }

        # Update the User PATH environment variable
        $newUserPath = $cleanedUserPathEntries -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, [System.EnvironmentVariableTarget]::User)
        Write-Host "Duplicates have been removed from the User PATH." -ForegroundColor Green
    }
}
