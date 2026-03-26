<#
    .SYNOPSIS
    Get a Ticket from WHD.

    .DESCRIPTION
    This function retrieves a specific Ticket from WHD, or a list of Tickets based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Ticket to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-Qualifier and Join-Qualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER Status
    A statustype.statusTypeName to search for.

    .PARAMETER Location
    A location.locationName to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.
#>
function Get-Ticket {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString", Mandatory)]
        [string] $QualifierString,

        [Parameter(ParameterSetName = "Search")]
        [string] $Status,

        [Parameter(ParameterSetName = "Search")]
        [string] $Location,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Tickets
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
                    Status   = "statustype.statusTypeName"
                    Location = "location.locationName"
                }
        }
    }

    return Get-Resource @QueryParameters
}