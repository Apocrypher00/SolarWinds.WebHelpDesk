<#
    .SYNOPSIS
    Get an AssetStatus from WHD.

    .DESCRIPTION
    This function retrieves all asset statuses from WHD.

    .NOTES
    We could make this searchable or give some options, but it doesn't necessarily seem useful.
#>
function Get-WHDAssetStatus {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single")]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    # Get the AssetStatuses
    $Results = if ($PSCmdlet.ParameterSetName -eq "Single") {
        Get-WHDResource -ResourceType ([WHDResourceType]::AssetStatuses) -ResourceId $ResourceId Expand:$Expand
    } else {
        Get-WHDResource -ResourceType ([WHDResourceType]::AssetStatuses) -Expand:$Expand
    }

    # Return the results
    return $Results
}