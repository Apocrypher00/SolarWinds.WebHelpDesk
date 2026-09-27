<#
    .SYNOPSIS
    Get the CustomFieldDefinitions from WHD.

    .DESCRIPTION
    This function retrieves a list of CustomFieldDefinitions based on the specified CustomFieldType.

    .PARAMETER CustomFieldType
    The type of CustomFieldDefinition to retrieve, e.g. Asset, Location, or Ticket.
    Restricted by the [WHDCustomFieldType] enum.

    .NOTES
    This ResourceType doesn't support retrieving a single CustomFieldDefinition by id.
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDCustomFieldDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [WHDCustomFieldType] $CustomFieldType
    )

    $QueryParameters = @{
        ResourceType    = [WHDResourceType]::CustomFieldDefinition
        CustomFieldType = $CustomFieldType
    }

    return Get-WHDResource @QueryParameters
}
