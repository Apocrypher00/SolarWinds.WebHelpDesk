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
    # FIXME: Use a better qualifier here
    $Results = if ($PSCmdlet.ParameterSetName -eq "Single") {
        Get-WHDResource `
            -Resource   ([WHDResourceType]::AssetStatuses) `
            -ResourceId $ResourceId `
            -Expand:$Expand
    } else {
        Get-WHDResource `
            -Resource  ([WHDResourceType]::AssetStatuses) `
            -Qualifier "" `
            -Expand:$Expand
    }

    # Return the results
    return $Results
}