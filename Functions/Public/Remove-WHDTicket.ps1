<#
    .SYNOPSIS
    Remove a Ticket from WHD.
#>
function Remove-WHDTicket {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Tickets")] $Ticket
    )

    process {
        if ($PSCmdlet.ShouldProcess("TicketNumber=$($Ticket.id)", "Remove Ticket from Web Help Desk")) {
            Remove-WHDResource -Resource $Ticket -Confirm:$false
        }
    }
}