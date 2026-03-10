<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear session state.

    .DESCRIPTION
    This function removes the active session from WHD and clears any connection state from the module.
#>
function Disconnect-WebHelpDesk {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")] param ()

    if ($PSCmdlet.ShouldProcess("Web Help Desk connection", "Disconnect and clear session state")) {
        # Remove the actual sesson from WHD
        if ($null -ne $Script:WHDConnection.Session) {
            Remove-WHDSession -Session $Script:WHDConnection.Session -Confirm:$false | Out-Null
        }

        Clear-WHDConnection
    }
}