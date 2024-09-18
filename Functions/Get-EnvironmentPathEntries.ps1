function Get-EnvironmentPathEntries {
    <#
    .SYNOPSIS
    Retrieves the entries of the PATH environment variable for the specified environment.

    .DESCRIPTION
    This function retrieves the entries of the PATH environment variable for either the System or User environment.

    .PARAMETER Environment
    Specifies which PATH variable to retrieve: 'System' or 'User'.

    .EXAMPLE
    Get-EnvironmentPathEntries -Environment System
    Retrieves the System PATH entries.

    .NOTES
    - No destructive actions are performed.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("System", "User")]
        [string]$Environment
    )

    # Determine the environment variable target
    $environmentTarget = if ($Environment -eq "System") {
        [EnvironmentVariableTarget]::Machine
    } else {
        [EnvironmentVariableTarget]::User
    }

    # Get the PATH variable for the specified environment
    $pathValue = [Environment]::GetEnvironmentVariable("Path", $environmentTarget)

    if (-not $pathValue) {
        Write-Warning "The $Environment PATH variable is empty or not found."
        return @()
    }

    $pathEntries = $pathValue -split ';' | ForEach-Object {
        $_.Trim()
    } | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }

    return $pathEntries
}
