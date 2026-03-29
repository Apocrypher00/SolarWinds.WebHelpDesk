<#
    .SYNOPSIS
    Get a Ticket from WHD.

    .DESCRIPTION
    This function retrieves a specific Ticket from WHD, or a list of Tickets based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Ticket to be retrieved.

    .PARAMETER ListType
    A WHDTicketListType to filter the results.
    Required if no Qualifier, QualifierString, or Search options are provided.

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
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [Parameter(ParameterSetName = "QualifierString")]
        [Parameter(ParameterSetName = "Search")]
        [WHDTicketListType] $ListType,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
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

    if ($PSBoundParameters.ContainsKey("ListType")) {
        $QueryParameters["AdditionalParameters"] = @{ list = $ListType }
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
                -AttributeMap    (
                @{
                    Status   = "statustype.statusTypeName"
                    Location = "location.locationName"
                }
            )
        }
    }

    if (
        ($PSCmdlet.ParameterSetName -ne "Single") -and
        ($null -eq $QueryParameters["Qualifier"]) -and
        [string]::IsNullOrWhiteSpace($QueryParameters["QualifierString"]) -and
        (-not $PSBoundParameters.ContainsKey("ListType"))
    ) {
        throw "ListType is required when no Qualifier, QualifierString, Search options are specified."
    }

    return Get-Resource @QueryParameters
}