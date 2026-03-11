<#
    .SYNOPSIS
    Asserts the current Web Help Desk connection is valid.

    .DESCRIPTION
    Checks that the current connection state is valid for making API calls.
#>
function Assert-WHDConnection {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    # Do we have either a session key or API key available?
    if (($null -eq $Script:WHDConnection.Session) -and ($null -eq  $Script:WHDConnection.AuthParams["apiKey"])) {
        throw "No authentication method provided. Please connect to Web Help Desk first using Connect-WebHelpDesk."
    }

    # If we have a session, is it expired?
    if (($null -ne $Script:WHDConnection.Session) -and ($Script:WHDConnection.Session.IsExpired)) {
        throw "Session key has expired. Please connect to Web Help Desk again using Connect-WebHelpDesk."
    }
}