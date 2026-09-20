<#
    .SYNOPSIS
    Get TicketNotes from WHD.

    .DESCRIPTION
    This function retrieves a specific TicketNote, or the list of TicketNotes attached to the specified Ticket.

    .PARAMETER TicketId
    The ResourceId of the Ticket for which to retrieve TicketNotes.

    .PARAMETER ResourceId
    The ResourceId of the TicketNote to retrieve.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDTicketNote {
    [CmdletBinding(DefaultParameterSetName = "List")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory, Position = 0)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "List", Mandatory)]
        [int] $TicketId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::TicketNote
        Expand       = $Expand.IsPresent
    }

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        $QueryParameters["ResourceId"] = $ResourceId
    } else {
        $QueryParameters["AdditionalParameters"] = @{ jobTicketId = $TicketId }
    }

    return Get-WHDResource @QueryParameters
}
