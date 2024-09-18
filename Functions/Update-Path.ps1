function Update-Path {
    <#
    .SYNOPSIS
    Updates the current session's PATH environment variable.

    .DESCRIPTION
    This function reloads the PATH environment variable for the current session by combining
    the User, System, and Process PATH variables, reflecting any changes made to the PATH.

    .EXAMPLE
    Update-Path
    Updates the current session's PATH environment variable.

    .NOTES
    - No destructive actions are performed.
    #>

    [CmdletBinding()]
    param ()

    # Retrieve the Process, User, and System PATH variables
    $processPath = [Environment]::GetEnvironmentVariable("Path", "Process")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

    # Combine all PATH variables
    $newPath = "$systemPath;$userPath;$processPath"

    # Update the current session's PATH variable
    $env:Path = $newPath

    Write-Output "The PATH environment variable has been updated for the current session."
}
