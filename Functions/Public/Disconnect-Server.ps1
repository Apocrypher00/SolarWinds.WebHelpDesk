<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear session state.

    .DESCRIPTION
    This function removes the active session from WHD and clears any connection state from the module.
#>
function Disconnect-Server {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param ()

    if ($PSCmdlet.ShouldProcess("Web Help Desk", "Disconnect and clear session state")) {
        # Remove the actual sesson from WHD
        if (($null -ne $Script:WHDConnection.Session) -and (-not $Script:WHDConnection.Session.IsExpired)) {
            Remove-Session -Session $Script:WHDConnection.Session -Confirm:$false | Out-Null
        }

        # Dispose of the WebSession to clear cookies and free resources
        # WARNING: This must happen AFTER deleting the Session
        if ($Script:WHDConnection.WebSession) {
            $Script:WHDConnection.WebSession.Dispose()
        }

        # Clear all connection state from our module
        Clear-Connection
    }
}