<#
.SYNOPSIS
    Remove a session from WHD based on the Session id.
#>
function Remove-WHDSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(ParameterSetName = "Session", Mandatory)]
        [PSTypeNameAttribute("SolarWinds.WebHelpDesk.Session")] $Session,

        [Parameter(ParameterSetName = "SessionId", Mandatory)]
        [int] $SessionId
    )

    if ($PSCmdlet.ParameterSetName -eq "Session") {
        $SessionId = $Session.id
    }

    if ($PSCmdlet.ShouldProcess("SessionId=$SessionId")) {
        Remove-WHDResource `
            -Resource   ([WHDResourceType]::Session) `
            -ResourceId $SessionId `
            -Confirm:$false
    }
}