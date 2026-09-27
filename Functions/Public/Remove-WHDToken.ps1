<#
    .SYNOPSIS
    Remove the active Token from WHD.

    .DESCRIPTION
    This function revokes the active bearer Token in WHD.

    .PARAMETER Token
    The active Token to revoke.
#>
function Remove-WHDToken {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Token")] $Token
    )

    process {
        if ($PSCmdlet.ShouldProcess("Active Token", "Remove Token from Web Help Desk")) {
            Remove-WHDResource -Resource $Token -Confirm:$false
        }
    }
}
