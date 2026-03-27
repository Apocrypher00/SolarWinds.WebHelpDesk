<#
    .SYNOPSIS
    Get a CustomFieldDefinition from WHD.

    .DESCRIPTION
    This function retrieves a list of CustomFieldDefinitions based on the specified CustomFieldType.

    .PARAMETER CustomFieldType
    The type of CustomFieldDefinition to retrieve, e.g. Asset, Location, or Ticket.
    Restricted by the [WHDCustomFieldType] enum.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support retrieving a single CustomFieldDefinition by id.
    This ResourceType doesn't support Qualifiers.
#>
function Get-CustomFieldDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [WHDCustomFieldType] $CustomFieldType,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType    = [WHDResourceType]::CustomFieldDefinitions
        CustomFieldType = $CustomFieldType
        Expand          = $Expand.IsPresent
    }

    return Get-Resource @QueryParameters
}