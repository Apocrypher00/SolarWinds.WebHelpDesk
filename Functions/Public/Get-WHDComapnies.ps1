<#
    .SYNOPSIS
    Get a company from WHD.

    .DESCRIPTION
    This function retrieves companies from WHD based on a provided search parameter.

    .PARAMETER Expand
    If specified, the function will expand the company details to include additional information.

    .NOTES
    TODO: Needs expanding, I don't have any test objects yet.
#>
function Get-WHDCompany {
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

    $ResourceType = [WHDResourceType]::Companies

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $CompanyAttributeMap = @{
        Name  = "companyName"
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
                if ($CompanyAttributeMap.ContainsKey($Param)) {
                    New-WHDQualifier `
                        -Attribute $CompanyAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSCmdlet.MyInvocation.BoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all companies
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the companies
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the companies
    return $Results
}