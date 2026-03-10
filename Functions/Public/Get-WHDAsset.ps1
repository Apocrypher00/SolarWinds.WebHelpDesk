<#
    .SYNOPSIS
    Get an asset from WHD.

    .DESCRIPTION
    This function retrieves assets from WHD based on a provided search parameter.

    .PARAMETER AssetNumber
    The asset number of the asset to be retrieve.

    .PARAMETER SerialNumber
    The serial number of the asset to retrieve.

    .PARAMETER Location
    The location name of the asset to retrieve.

    .PARAMETER Room
    The room name of the asset to retrieve.

    .PARAMETER Status
    The status name of the asset to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the asset details to include additional.

    .NOTES
    This can return 0, 1, or multiple Assets!
#>
function Get-WHDAsset {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Search")]
        [string] $AssetNumber,

        [Parameter(ParameterSetName = "Search")]
        [string] $SerialNumber,

        [Parameter(ParameterSetName = "Search")]
        [string] $Location,

        [Parameter(ParameterSetName = "Search")]
        [string] $Room,

        [Parameter(ParameterSetName = "Search")]
        [string] $Status,

        [Parameter(ParameterSetName = "Search")]
        [string] $Model,

        [Parameter(ParameterSetName = "Search")]
        [string] $Manufacturer,

        [Parameter()]
        [switch] $Expand
    )

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $AssetAttributeMap = @{
        AssetNumber  = "assetNumber"
        SerialNumber = "serialNumber"
        Location     = "location.locationName"
        Room         = "room.roomName"
        Status       = "assetstatus.name"
        Model        = "model.modelName"
        Manufacturer = "model.manufacturer.name"
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType ([WHDResourceType]::Assets) `
                -ResourceId   $ResourceId
        }
        "Search" {
            # Build a search qualifier for eachof the provided parameters
            $Qualifiers = foreach ($Param in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                if ($AssetAttributeMap.ContainsKey($Param)) {
                    New-WHDQualifier `
                        -Attribute $AssetAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSCmdlet.MyInvocation.BoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all assets
            $Qualifier = if ($Qualifiers.Count -eq 0) { "" } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the assets
            $Results = Get-WHDResource `
                -ResourceType ([WHDResourceType]::Assets) `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the asset
    return $Results
}