<#
    .SYNOPSIS
    Get a Location from WHD.

    .DESCRIPTION
    This function retrieves a specific Location from WHD, or a list of Locations based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Location to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-Qualifier and Join-Qualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER Name
    A locationName to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.
#>
function Get-Location {
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

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Locations
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
            $QueryParameters["Qualifier"] = ConvertTo-Qualifier `
                -BoundParameters $PSBoundParameters `
                -AttributeMap    @{
                    Name = "locationName"
                }
        }
    }

    return Get-Resource @QueryParameters
}