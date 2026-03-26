<#
    .SYNOPSIS
    Get a Manufacturer from WHD.

    .DESCRIPTION
    This function retrieves a specific Manufacturer from WHD, or a list of Manufacturers based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Manufacturer to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-Qualifier and Join-Qualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER Name
    A name to search for.

    .PARAMETER FullName
    A fullName to search for.

    .PARAMETER PostalCode
    A postalCode to search for.

    .PARAMETER Address
    An address to search for.

    .PARAMETER City
    A city to search for.

    .PARAMETER State
    A state to search for.

    .PARAMETER Country
    A country to search for.

    .PARAMETER Phone
    A phone to search for.

    .PARAMETER Fax
    A fax to search for.

    .PARAMETER Url
    A url to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.
#>
function Get-Manufacturer {
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

        [Parameter(ParameterSetName = "Search")]
        [string] $FullName,

        [Parameter(ParameterSetName = "Search")]
        [string] $PostalCode,

        [Parameter(ParameterSetName = "Search")]
        [string] $Address,

        [Parameter(ParameterSetName = "Search")]
        [string] $City,

        [Parameter(ParameterSetName = "Search")]
        [string] $State,

        [Parameter(ParameterSetName = "Search")]
        [string] $Country,

        [Parameter(ParameterSetName = "Search")]
        [string] $Phone,

        [Parameter(ParameterSetName = "Search")]
        [string] $Fax,

        [Parameter(ParameterSetName = "Search")]
        [string] $Url,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Manufacturers
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
                    Name       = "name"
                    FullName   = "fullName"
                    PostalCode = "postalCode"
                    Address    = "address"
                    City       = "city"
                    State      = "state"
                    Country    = "country"
                    Phone      = "phone"
                    Fax        = "fax"
                    Url        = "url"
                }
        }
    }

    return Get-Resource @QueryParameters
}