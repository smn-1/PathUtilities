function Get-PathEntries {
    <#
    .SYNOPSIS
    Retrieves and displays entries of the PATH environment variable by environment (System, User, or Both),
    with an option to display duplicates between System and User PATH entries.

    .DESCRIPTION
    This function retrieves and displays the entries of the PATH environment variable,
    based on the specified target. It can:

    - Display entries from the System PATH, User PATH, or both.
    - Identify and display duplicates between the System and User PATH entries.

    .PARAMETER Target
    Specifies which PATH variable(s) to display:

    - 'System'     : Displays only the System PATH entries.
    - 'User'       : Displays only the User PATH entries.
    - 'All'        : Displays both System and User PATH entries.
    - 'Duplicates' : Displays entries that are duplicates between User and System PATH.

    Defaults to 'All'.

    .EXAMPLE
    Get-PathEntries -Target System
    Displays only the System PATH entries.

    .EXAMPLE
    Get-PathEntries -Target Duplicates
    Displays entries that are duplicates between User and System PATH.

    .NOTES
    - No destructive actions are performed.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("System", "User", "All", "Duplicates")]
        [string]$Target = "All"
    )

    # Function to retrieve PATH entries for a given environment
    function Get-EnvironmentPathEntries {
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

    # Retrieve PATH entries based on the Target parameter
    switch ($Target) {
        "System" {
            $systemPathEntries = Get-EnvironmentPathEntries -Environment "System"
            if ($systemPathEntries.Count -gt 0) {
                Write-Host "System PATH Entries:`n" -ForegroundColor Cyan
                $systemPathEntries | ForEach-Object {
                    Write-Host $_
                }
                Write-Host
            } else {
                Write-Warning "No System PATH entries found."
            }
        }
        "User" {
            $userPathEntries = Get-EnvironmentPathEntries -Environment "User"
            if ($userPathEntries.Count -gt 0) {
                Write-Host "User PATH Entries:`n" -ForegroundColor Yellow
                $userPathEntries | ForEach-Object {
                    Write-Host $_
                }
                Write-Host
            } else {
                Write-Warning "No User PATH entries found."
            }
        }
        "All" {
            $systemPathEntries = Get-EnvironmentPathEntries -Environment "System"
            $userPathEntries = Get-EnvironmentPathEntries -Environment "User"

            if ($systemPathEntries.Count -gt 0) {
                Write-Host "System PATH Entries:`n" -ForegroundColor Cyan
                $systemPathEntries | ForEach-Object {
                    Write-Host $_
                }
                Write-Host
            } else {
                Write-Warning "No System PATH entries found."
            }

            if ($userPathEntries.Count -gt 0) {
                Write-Host "User PATH Entries:`n" -ForegroundColor Yellow
                $userPathEntries | ForEach-Object {
                    Write-Host $_
                }
                Write-Host
            } else {
                Write-Warning "No User PATH entries found."
            }
        }
        "Duplicates" {
            $systemPathEntries = Get-EnvironmentPathEntries -Environment "System"
            $userPathEntries = Get-EnvironmentPathEntries -Environment "User"

            if ($systemPathEntries.Count -eq 0 -and $userPathEntries.Count -eq 0) {
                Write-Warning "Both System and User PATH variables are empty or not found."
                return
            }

            $normalizedSystemPaths = $systemPathEntries | ForEach-Object { ($_.TrimEnd('\')).ToLowerInvariant() }
            $duplicates = $userPathEntries | Where-Object {
                $normalizedSystemPaths -contains ($_.TrimEnd('\')).ToLowerInvariant()
            }

            if ($duplicates.Count -gt 0) {
                Write-Host "Duplicate Entries between User and System PATH:`n" -ForegroundColor Red
                $duplicates | ForEach-Object {
                    Write-Host $_
                }
                Write-Host
            } else {
                Write-Host "No duplicates found between User and System PATH entries." -ForegroundColor Green
            }
        }
    }
}