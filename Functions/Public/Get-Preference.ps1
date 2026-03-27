<#
    .SYNOPSIS
    Get the system configuration settings from WHD.

    .DESCRIPTION
    This function retrieves the system configuration settings from WHD.
    The API also refers to this as Setup/Preferences.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support retrieving a single Preference by id.
    This ResourceType doesn't support Qualifiers.
#>
function Get-Preference {
    [CmdletBinding()]
    [Alias("Get-Setup")]
    param (
        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Preferences
        Expand       = $Expand.IsPresent
    }

    return Get-Resource @QueryParameters
}