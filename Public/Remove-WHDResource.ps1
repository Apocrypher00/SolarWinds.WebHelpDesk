<#
    .SYNOPSIS
    Delete WHD Resource by ID only
#>
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [ResourceType] $Resource,

        [Parameter(Mandatory)]
        [int] $ResourceId
    )

    # Build the Uri
    # FIXME: Do we need to put the sessionKey here, or can we use the body like the other functions?
    $Uri = "$BaseUrl/$Resource/$ResourceId`?sessionKey=$($WHDConnection.$SessionKey)"

    # Send the query and return the result
    if ($PSCmdlet.ShouldProcess("$BaseUrl/$Resource/$ResourceId")) {
        return Invoke-RestMethod `
            -Uri $Uri `
            -Method "DELETE" `
            -ContentType "application/json"
    }
}