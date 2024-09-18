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

    $systemPathEntries = Get-PathEntries -Environment "Machine"
    $userPathEntries = Get-PathEntries -Environment "User"

    $normalizedSystemPaths = $systemPathEntries | ForEach-Object { $_.ToLowerInvariant() }
    $duplicates = $userPathEntries | Where-Object {
        $normalizedSystemPaths -contains $_.ToLowerInvariant()
    }

    if (-not $duplicates) {
        Write-Host "No duplicates found between User and System PATH entries." -ForegroundColor Green
        return
    }

    if ($PSCmdlet.ShouldProcess("User PATH", "Remove duplicates that exist in System PATH")) {
        # Backup User PATH
        $backupPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupFile = "$env:USERPROFILE\UserPathBackup_$timestamp.txt"
        Set-Content -Path $backupFile -Value $backupPath
        Write-Host "User PATH has been backed up to $backupFile" -ForegroundColor Green

        # Remove duplicates
        $normalizedDuplicates = $duplicates | ForEach-Object { $_.ToLowerInvariant() }
        $cleanedUserPathEntries = $userPathEntries | Where-Object {
            -not ($normalizedDuplicates -contains $_.ToLowerInvariant())
        }

        # Update User PATH
        $newUserPath = $cleanedUserPathEntries -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
        Write-Host "Duplicates have been removed from the User PATH." -ForegroundColor Green
    }
}
