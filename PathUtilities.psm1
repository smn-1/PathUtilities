# Dot-source the function scripts
. $PSScriptRoot\Functions\Add-Path.ps1
. $PSScriptRoot\Functions\Remove-DuplicatePaths.ps1
. $PSScriptRoot\Functions\Get-PathEntries.ps1
. $PSScriptRoot\Functions\Remove-DuplicatesFromUserPath.ps1
. $PSScriptRoot\Functions\Update-Path.ps1

# Export the functions
Export-ModuleMember -Function *-*
