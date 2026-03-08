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

    .PARAMETER Expand
    If specified, the function will expand the asset details to include additional information such as status names.

    .NOTES
    This can return 0, 1, or multiple Assets!
#>
function Get-WHDAsset {
    [CmdletBinding()]
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

        [Parameter()]
        [switch] $Expand
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType  ([WHDResourceType]::Assets) `
                -ResourceId $ResourceId
        }
        "Search" {
            # Build a search qualifier based on the provided parameters
            # FIXME: I wanted this to be a loop, but the attribute names don't match the parameter names
            $Qualifiers = [System.Collections.ArrayList]::new()
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("AssetNumber")) {
                $Qualifiers.Add(
                    (
                        New-WHDQualifier `
                            -Attribute "assetNumber" `
                            -Operator  ([WHDQualifierOperator]::Equals) `
                            -Value     $PSCmdlet.MyInvocation.BoundParameters["AssetNumber"]
                    )
                )
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("SerialNumber")) {
                $Qualifiers.Add(
                    (
                        New-WHDQualifier `
                            -Attribute "serialNumber" `
                            -Operator  ([WHDQualifierOperator]::Equals) `
                            -Value     $PSCmdlet.MyInvocation.BoundParameters["SerialNumber"]
                    )
                )
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Location")) {
                $Qualifiers.Add(
                    (
                        New-WHDQualifier `
                            -Attribute "location.locationName" `
                            -Operator  ([WHDQualifierOperator]::Equals) `
                            -Value     $PSCmdlet.MyInvocation.BoundParameters["Location"]
                    )
                )
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Room")) {
                $Qualifiers.Add(
                    (
                        New-WHDQualifier `
                            -Attribute "room.roomName" `
                            -Operator  ([WHDQualifierOperator]::Equals) `
                            -Value     $PSCmdlet.MyInvocation.BoundParameters["Room"]
                    )
                )
            }

            # Combine qualifiers with AND, if there are any
            # Otherwise, if there are no qualifiers, we want to pass an empty string to get all assets
            $Qualifier = if ($Qualifiers.Count -eq 0) { "" } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the assets
            $Results = Get-WHDResource `
                -ResourceType  ([WHDResourceType]::Assets) `
                -Qualifier $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the asset
    return $Results
}