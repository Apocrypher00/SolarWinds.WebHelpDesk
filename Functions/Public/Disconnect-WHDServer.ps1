<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear session state.

    .DESCRIPTION
    This function removes the active session from WHD and clears any connection state from the module.
    Local state is cleared even if session deletion fails.
    The deletion error is still reported, and the server session may remain active until it expires.
#>
function Disconnect-WHDServer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param ()

    if ($PSCmdlet.ShouldProcess("Web Help Desk", "Disconnect and clear session state")) {
        try {
            # Remove the actual session from WHD before releasing local state.
            if (($null -ne $Script:WHDConnection.Session) -and (-not $Script:WHDConnection.Session.IsExpired)) {
                Remove-WHDSession -Session $Script:WHDConnection.Session -Confirm:$false -ErrorAction Stop | Out-Null
            }
        } finally {
            # Clear-Connection disposes of the WebSession, so this must happen after deleting the Session.
            Clear-Connection
        }
    }
}
