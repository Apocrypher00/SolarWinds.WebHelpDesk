<#
    .SYNOPSIS
    Get a manufacturer from WHD.

    .DESCRIPTION
    This function retrieves manufacturers from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the manufacturer to retrieve.

    .PARAMETER Name
    The short name of the manufacturer to retrieve.

    .PARAMETER FullName
    The full name of the manufacturer to retrieve.

    .PARAMETER PostalCode
    The postal code of the manufacturer to retrieve.

    .PARAMETER Address
    The address of the manufacturer to retrieve.

    .PARAMETER City
    The city of the manufacturer to retrieve.

    .PARAMETER State
    The state of the manufacturer to retrieve.

    .PARAMETER Country
    The country of the manufacturer to retrieve.

    .PARAMETER Phone
    The phone number of the manufacturer to retrieve.

    .PARAMETER Fax
    The fax number of the manufacturer to retrieve.

    .PARAMETER Url
    The URL of the manufacturer to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the manufacturer details to include additional information.
#>
function Get-Manufacturer {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [string] $Qualifier,

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

    $ResourceType = [WHDResourceType]::Manufacturers

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $ManufacturerAttributeMap = @{
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
            # Build a search qualifier for each of the provided parameters
            $Qualifiers = foreach ($Param in $PSBoundParameters.Keys) {
                if ($ManufacturerAttributeMap.ContainsKey($Param)) {
                    New-Qualifier `
                        -Attribute $ManufacturerAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSBoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all manufacturers
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-Qualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the manufacturers
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the manufacturers
    return $Results
}