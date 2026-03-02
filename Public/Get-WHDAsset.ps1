<#
    .SYNOPSIS
    Get an asset from WHD.

    .DESCRIPTION
    This function retrieves assets from WHD based on a provided search parameter.

    .PARAMETER AssetNumber
    The asset number of the asset to be retrieve.

    .PARAMETER SerialNumber
    The serial number of the asset to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the asset details to include additional information such as status names.

    .NOTES
    This can return 0, 1, or multiple Assets!
#>
function Get-WHDAsset {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "AssetNumber", Mandatory)]
        [string] $AssetNumber,

        [Parameter(ParameterSetName = "SerialNumber", Mandatory)]
        [string] $SerialNumber,

        [Parameter()]
        [switch] $Expand
    )

    # Build a search qualifier based on the parameter set
    $Qualifier = switch ($PSCmdlet.ParameterSetName) {
        "AssetNumber" { "(assetNumber = '$AssetNumber')" }
        "SerialNumber" { "(serialNumber = '$SerialNumber')" }
    }

    # Get the assets
    $Results = Get-WHDResource `
        -Resource  ([WHDResourceType]::Assets) `
        -Qualifier $Qualifier `
        -Expand:$Expand

    # Replace status with the actual name, if requested
    # FIXME: we should probably cache these lookups instead of doing one per asset
    # FIXME: This should be a resolved property
    if ($Expand) {
        $AssetStatuses = Get-WHDAssetStatus
        foreach ($Result in $Results) {
            $Result.assetStatus = ($AssetStatuses | Where-Object "id" -EQ $Result.assetStatus.id)[0].name
        }
    }

    # Return the asset
    return $Results
}