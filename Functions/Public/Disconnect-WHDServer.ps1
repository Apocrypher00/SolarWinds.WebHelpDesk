<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear connection state.

    .DESCRIPTION
    This function removes the active Session or Token from WHD and clears any connection state from the module.
    Local state is cleared even if removal fails.
    The removal error is still reported, and the server credential may remain active until it expires.
#>
function Disconnect-WHDServer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    [Alias("Disconnect-WebHelpDesk")]
    param ()

    if ($PSCmdlet.ShouldProcess("Web Help Desk", "Disconnect and clear session state")) {
        try {
            # Remove the active server credential from WHD before releasing local state.
            if (($null -ne $Script:WHDConnection.Session) -and (-not $Script:WHDConnection.Session.IsExpired)) {
                Remove-WHDSession -Session $Script:WHDConnection.Session -Confirm:$false -ErrorAction Stop | Out-Null
            } elseif (($null -ne $Script:WHDConnection.Token) -and (-not $Script:WHDConnection.Token.IsExpired)) {
                Remove-WHDToken -Token $Script:WHDConnection.Token -Confirm:$false -ErrorAction Stop | Out-Null
            }
        } finally {
            # Clear-Connection disposes of the WebSession, so this must happen after removing server credentials.
            Clear-Connection
        }
    }
}
