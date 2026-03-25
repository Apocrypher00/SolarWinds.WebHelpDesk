<#
    .SYNOPSIS
    Get an asset type from WHD.

    .DESCRIPTION
    This function retrieves asset types from WHD based on a provided search parameter.

    .PARAMETER Expand
    If specified, the function will expand the asset type details to include additional information.
#>
function Get-AssetType {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [string] $Qualifier,

        [Parameter(ParameterSetName = "Search")]
        [string] $Name,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::AssetTypes

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $AssetTypeAttributeMap = @{
        Name = "assetType"
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
        "Search" {
            # Build a search qualifier for each of the provided parameters
            $Qualifiers = foreach ($Param in $PSBoundParameters.Keys) {
                if ($AssetTypeAttributeMap.ContainsKey($Param)) {
                    New-Qualifier `
                        -Attribute $AssetTypeAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSBoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all asset types
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-Qualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the asset types
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the asset types
    return $Results
}