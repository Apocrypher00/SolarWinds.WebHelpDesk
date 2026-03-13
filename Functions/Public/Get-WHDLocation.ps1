<#
    .SYNOPSIS
    Get a location from WHD.

    .DESCRIPTION
    This function retrieves locations from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the location to retrieve.

    .PARAMETER Name
    The short name of the location to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the location details to include additional information.
#>
function Get-WHDLocation {
    [CmdletBinding()]
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

    $ResourceType = [WHDResourceType]::Locations

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $LocationAttributeMap = @{
        Name = "locationName"
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
        "Search" {
            # Build a search qualifier for each of the provided parameters
            $Qualifiers = foreach ($Param in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                if ($LocationAttributeMap.ContainsKey($Param)) {
                    New-WHDQualifier `
                        -Attribute $LocationAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSCmdlet.MyInvocation.BoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all locations
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the locations
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the locations
    return $Results
}