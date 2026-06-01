<#
    .SYNOPSIS
    Get a Client from WHD.

    .DESCRIPTION
    This function retrieves a specific Client from WHD, or a list of Clients based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Client to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-WHDQualifier and Join-WHDQualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER FirstName
    A firstName to search for.

    .PARAMETER LastName
    A lastName to search for.

    .PARAMETER Location
    A location.locationName to search for.

    .PARAMETER Email
    An email to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.
#>
function Get-WHDClient {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString", Mandatory)]
        [string] $QualifierString,

        [Parameter(ParameterSetName = "Search")]
        [string] $FirstName,

        [Parameter(ParameterSetName = "Search")]
        [string] $LastName,

        [Parameter(ParameterSetName = "Search")]
        [string] $Location,

        [Parameter(ParameterSetName = "Search")]
        [string] $Email,

        [Parameter()]
        [switch] $Expand
    )

    $AttributeMap = @{
        FirstName = "firstName"
        LastName  = "lastName"
        Location  = "location.locationName"
        Email     = "email"
    }

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Clients
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