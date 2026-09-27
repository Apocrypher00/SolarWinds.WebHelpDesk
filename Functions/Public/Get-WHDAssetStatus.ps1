<#
    .SYNOPSIS
    Get an AssetStatus from WHD.

    .DESCRIPTION
    This function retrieves a specific AssetStatus from WHD, or a list of all AssetStatuses.

    .PARAMETER ResourceId
    The id of the AssetStatus to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDAssetStatus {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::AssetStatus
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
