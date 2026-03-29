<#
    .SYNOPSIS
    Get TicketNotes from WHD.

    .DESCRIPTION
    This function retrieves the list of TicketNotes attached to the specified Ticket.

    .PARAMETER TicketId
    The ResourceId of the Ticket for which to retrieve TicketNotes.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support retrieving a single TicketNote by id.
    This ResourceType doesn't support Qualifiers.
#>
function Get-TicketNote {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int] $TicketId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType         = [WHDResourceType]::TicketNotes
        AdditionalParameters = @{ jobTicketId = $TicketId }
        Expand               = $Expand.IsPresent
    }

    return Get-Resource @QueryParameters
}