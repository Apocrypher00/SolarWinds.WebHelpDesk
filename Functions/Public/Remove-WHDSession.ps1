<#
    .SYNOPSIS
    Remove a Session from WHD.

    .DESCRIPTION
    This function deletes a session from WHD based on the session key.

    .PARAMETER Session
    The session object representing the session to be removed.
    This can really only be the active session, as the API will only give you one session key at a time, per api key.
    For session-based authentication, this will effectively log out the session.
#>
function Remove-WHDSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Session")] $Session
    )

    process {
        if ($PSCmdlet.ShouldProcess("SessionKey=$($Session.sessionKey)", "Remove Session from Web Help Desk")) {
            Remove-WHDResource -Resource $Session -Confirm:$false
        }
    }
}