<#
    .SYNOPSIS
    Get a Company from WHD.

    .DESCRIPTION
    This function retrieves a specific Company from WHD, or a list of Companies based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Company to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-WHDQualifier and Join-WHDQualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER Name
    A companyName to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    TODO: Needs expanding, I don't have any test objects yet.
#>
function Get-WHDCompany {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString", Mandatory)]
        [string] $QualifierString,

        [Parameter(ParameterSetName = "Search")]
        [string] $Name,

        [Parameter()]
        [switch] $Expand
    )

    $AttributeMap = @{
        Name = "companyName"
    }

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Companies
        Expand       = $Expand.IsPresent
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $QueryParameters["ResourceId"] = $ResourceId
        }
        "Qualifier" {
            $QueryParameters["Qualifier"] = $Qualifier
        }
        "QualifierString" {
            $QueryParameters["QualifierString"] = $QualifierString
        }
        "Search" {
            $QueryParameters["Qualifier"] = ConvertTo-WHDQualifier `
                -BoundParameters $PSBoundParameters `
                -AttributeMap $AttributeMap
        }
    }

    return Get-WHDResource @QueryParameters
}