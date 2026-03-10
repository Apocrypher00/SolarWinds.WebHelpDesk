function Remove-WHDSessionTest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSTypeName("SolarWinds.WebHelpDesk.Session")] $Session
    )

    $AuthString = "sessionKey=$($Session.sessionKey)"

    $Uri = "$($WHDConnection.BaseUrl)/$([WHDResourceType]::Session)"
    $Uri += "?$AuthString"

    Write-Host "Uri: $Uri" -ForegroundColor Yellow

    return Invoke-RestMethod `
        -Uri         $Uri `
        -Method      ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) `
        -ContentType "application/json" `
        -WebSession  $Script:WHDConnection.WebSession
}