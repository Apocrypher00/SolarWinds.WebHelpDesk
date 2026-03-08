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
        [Parameter(ParameterSetName = "ID", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "AssetNumber", Mandatory)]
        [string] $AssetNumber,

        [Parameter(ParameterSetName = "SerialNumber", Mandatory)]
        [string] $SerialNumber,

        [Parameter()]
        [switch] $Expand
    )

    if ($PSCmdlet.ParameterSetName -eq "ID") {
        $Results = Get-WHDResource `
            -ResourceType  ([WHDResourceType]::Assets) `
            -ResourceId $ResourceId
    } else {
        # Build a search qualifier based on the parameter set
        # FIXME: We could just combine all specified attributes
        $Qualifier = switch ($PSCmdlet.ParameterSetName) {
            "AssetNumber" {
                New-WHDQualifier `
                    -Attribute "assetNumber" `
                    -Operator  ([WHDQualifierOperator]::Equals) `
                    -Value     $AssetNumber
            }
            "SerialNumber" {
                New-WHDQualifier `
                    -Attribute "serialNumber" `
                    -Operator  ([WHDQualifierOperator]::Equals) `
                    -Value     $SerialNumber
            }
        }

        # Get the assets
        $Results = Get-WHDResource `
            -ResourceType  ([WHDResourceType]::Assets) `
            -Qualifier $Qualifier `
            -Expand:$Expand
    }

    # Return the asset
    return $Results
}