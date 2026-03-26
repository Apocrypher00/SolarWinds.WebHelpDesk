<#
    .SYNOPSIS
    Get an AssetStatus from WHD.

    .DESCRIPTION
    This function retrieves a specific AssetStatus from WHD, or a list of all AssetStatuses.

    .PARAMETER ResourceId
    The id of the AssetStatus to be retrieved.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-AssetStatus {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::AssetStatuses
        Expand       = $Expand.IsPresent
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-Resource @QueryParameters
}