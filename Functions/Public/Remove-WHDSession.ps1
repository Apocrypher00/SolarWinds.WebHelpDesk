<#
    .SYNOPSIS
    Remove a session from WHD.

    .DESCRIPTION
    This function deletes a session from WHD based on the session key.

    .PARAMETER Session
    The session object representing the session to be removed.
    This can really only be the active session used for authentication.

    .NOTES
    You can only really remove the active session used by session-based authentication.
#>
function Remove-WHDSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Session")] $Session
    )

    process {
        if ($PSCmdlet.ShouldProcess("SessionKey=$($Session.sessionKey)", "Remove session from Web Help Desk")) {
            Remove-WHDResource -Resource $Session -Confirm:$false
        }
    }
}