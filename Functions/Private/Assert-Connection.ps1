<#
    .SYNOPSIS
    Asserts the current Web Help Desk connection is valid.

    .DESCRIPTION
    Checks that the current connection state is valid for making API calls.
#>
function Assert-Connection {
    [CmdletBinding()]
    [OutputType([void])]
    param ()

    switch (Get-AuthenticationType) {
        ([WHDAuthenticationType]::None) {
            throw "No authentication method provided. Please connect to Web Help Desk first using Connect-WebHelpDesk."
        }

        ([WHDAuthenticationType]::Headers) {
            if ($Script:WHDConnection.Token.IsExpired) {
                throw "Token has expired. Please connect to Web Help Desk again using Connect-WebHelpDesk."
            }
        }

        ([WHDAuthenticationType]::QueryParameters) {
            if (($null -ne $Script:WHDConnection.Session) -and ($Script:WHDConnection.Session.IsExpired)) {
                throw "Session key has expired. Please connect to Web Help Desk again using Connect-WebHelpDesk."
            }
        }
    }
}
