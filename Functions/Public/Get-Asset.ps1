<#
    .SYNOPSIS
    Get an Asset from WHD.

    .DESCRIPTION
    This function retrieves a specific Asset from WHD, or a list of Assets based on a provided search parameter.

    .PARAMETER ResourceId
    The id of the Asset to be retrieved.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-Qualifier and Join-Qualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.

    .PARAMETER AssetNumber
    An assetNumber to search for.

    .PARAMETER SerialNumber
    A serialNumber to search for.

    .PARAMETER Location
    A location.locationName to search for.

    .PARAMETER Room
    A room.roomName to search for.

    .PARAMETER Status
    An assetstatus.name to search for.

    .PARAMETER Model
    A model.modelName to search for.

    .PARAMETER Manufacturer
    A model.manufacturer.name to search for.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.
#>
function Get-Asset {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
        [string] $QualifierString,

        [Parameter(ParameterSetName = "Search")]
        [string] $AssetNumber,

        [Parameter(ParameterSetName = "Search")]
        [string] $SerialNumber,

        [Parameter(ParameterSetName = "Search")]
        [string] $Location,

        [Parameter(ParameterSetName = "Search")]
        [string] $Room,

        [Parameter(ParameterSetName = "Search")]
        [string] $Status,

        [Parameter(ParameterSetName = "Search")]
        [string] $Model,

        [Parameter(ParameterSetName = "Search")]
        [string] $Manufacturer,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Assets
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
                    AssetNumber  = "assetNumber"
                    SerialNumber = "serialNumber"
                    Location     = "location.locationName"
                    Room         = "room.roomName"
                    Status       = "assetstatus.name"
                    Model        = "model.modelName"
                    Manufacturer = "model.manufacturer.name"
                }
        }
    }

    return Get-Resource @QueryParameters
}