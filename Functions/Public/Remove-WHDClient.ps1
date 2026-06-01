<#
    .SYNOPSIS
    Remove a Client from WHD.
#>
function Remove-WHDClient {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Clients")] $Client
    )

    process {
        if ($PSCmdlet.ShouldProcess("Email=$($Client.email)", "Remove Client from Web Help Desk")) {
            Remove-WHDResource -Resource $Client -Confirm:$false
        }
    }
}
