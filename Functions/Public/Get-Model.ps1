<#
    .SYNOPSIS
    Get a model from WHD.

    .DESCRIPTION
    This function retrieves models from WHD based on a provided search parameter.

    .PARAMETER Name
    The name of the model to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the model details to include additional.

    .NOTES
    This can return 0, 1, or multiple Models!
#>
function Get-Model {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [string] $Qualifier,

        [Parameter(ParameterSetName = "Search")]
        [string] $Name,

        [Parameter(ParameterSetName = "Search")]
        [string] $Manufacturer,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::Models

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $ModelAttributeMap = @{
        Name         = "modelName"
        Manufacturer = "manufacturer.name"
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
            # Build a search qualifier for eachof the provided parameters
            $Qualifiers = foreach ($Param in $PSBoundParameters.Keys) {
                if ($ModelAttributeMap.ContainsKey($Param)) {
                    New-Qualifier `
                        -Attribute $ModelAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSBoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all models
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-Qualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the models
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the model
    return $Results
}