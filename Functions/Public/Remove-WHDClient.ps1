<#
    .SYNOPSIS
    Remove a client from WHD.
#>
function Remove-WHDClient {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Clients")] $Client
    )

    process {
        # Delete the Client by ID
        if ($PSCmdlet.ShouldProcess("Email=$($Client.email)", "Remove client from Web Help Desk")) {
            Remove-WHDResource -Resource $Client -Confirm:$false
        }
    }
}
