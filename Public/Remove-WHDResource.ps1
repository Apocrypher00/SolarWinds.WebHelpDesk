<#
    .SYNOPSIS
    Delete WHD Resource by ID only
#>
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $Resource,

        [Parameter(Mandatory)]
        [int] $ResourceId
    )

    # Build the Uri
    # FIXME: Do we need to put the sessionKey here, or can we use the body like the other functions?
    # $Uri = "$BaseUrl/$Resource/$ResourceId`?sessionKey=$($WHDConnection.$SessionKey)"
    $Uri = "$($WHDConnection.BaseUrl)/$Resource/$ResourceId"
    $Uri += "?sessionKey=$($Script:WHDConnection.Session.sessionKey)"

    # Send the query and return the result
    if ($PSCmdlet.ShouldProcess("$($WHDConnection.BaseUrl)/$Resource/$ResourceId")) {
        return Invoke-RestMethod `
            -Uri         $Uri `
            -Method      ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) `
            -ContentType "application/json" `
            -WebSession  $Script:WHDConnection.WebSession
    }
}