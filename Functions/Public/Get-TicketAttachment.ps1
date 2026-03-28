<#
    .SYNOPSIS
    Get a TicketAttachment from WHD.

    .DESCRIPTION
    This function retrieves a specific TicketAttachment from WHD.

    .PARAMETER ResourceId
    The id of the TicketAttachment to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers, and only supports retrieval of a single Resource by id.
    This ResourceType returns application/octet-stream binary data, not JSON.
    The raw response is included in the Response property of the returned object.
    The detailed format for this ResourceType is identical to the short format.
#>
function Get-TicketAttachment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int] $ResourceId
    )

    return Get-Resource `
        -ResourceType ([WHDResourceType]::TicketAttachments) `
        -ResourceId   $ResourceId
}