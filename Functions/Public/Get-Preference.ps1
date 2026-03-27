<#
    .SYNOPSIS
    Get the system configuration settings from WHD.

    .DESCRIPTION
    This function retrieves the system configuration settings from WHD.
    The API also refers to this as Setup/Preferences.

    .NOTES
    This ResourceType doesn't support retrieving a single Preference by id.
    This ResourceType doesn't support Qualifiers.
    The detailed format for this ResourceType is identical to the short format.
#>
function Get-Preference {
    [CmdletBinding()]
    [Alias("Get-Setup")]
    param ()

    return Get-Resource -ResourceType ([WHDResourceType]::Preferences)
}