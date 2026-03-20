<#
    .SYNOPSIS
    Get a department from WHD.

    .DESCRIPTION
    This function retrieves departments from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the department to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the department details to include additional information.
#>
function Get-WHDDepartment {
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

    $ResourceType = [WHDResourceType]::Departments

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $DepartmentAttributeMap = @{
        Name = "name"
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
            $Qualifiers = foreach ($Param in $PSBoundParameters.Keys) {
                if ($DepartmentAttributeMap.ContainsKey($Param)) {
                    New-WHDQualifier `
                        -Attribute $DepartmentAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSBoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all departments
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the departments
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    return $Results
}