<#
    .SYNOPSIS
    Connect to the WebHelpDesk API.

    .DESCRIPTION
    This function establishes a connection to the WHD API using an API key, bearer Token, or Session.
    By default, API key authentication is exchanged for a bearer Token.
    The resulting authentication state and base URL are stored for use in subsequent API calls.

    .PARAMETER BaseUrl
    The base URL of the WebHelpDesk instance (e.g., "https://whd.mydomain.com").
    Targets the WHD 2026.4.0 NextGen API. Any supplied path is replaced with "/api/v1/ra".

    .PARAMETER ApiKey
    The API key for authentication.

    .PARAMETER Username
    The username associated with the API key.
    This is required for Application API keys but optional for User API keys.

    .PARAMETER AuthenticationMode
    Determines how supplied API-key credentials are used. The default is Token.
    Token exchanges the credentials for a bearer Token, Session exchanges them for a Session,
    and Direct retains them for direct API-key authentication.

    .PARAMETER Token
    A bearer Token returned by New-WHDToken.

    .PARAMETER Session
    A Session returned by New-WHDSession.
#>
function Connect-WHDServer {
    [CmdletBinding(DefaultParameterSetName = "ApiKey")]
    [Alias("Connect-WebHelpDesk")]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string] $BaseUrl,

        [Parameter(Mandatory, ParameterSetName = "ApiKey")]
        [string] $ApiKey,

        [Parameter(ParameterSetName = "ApiKey")]
        [string] $Username,

        [Parameter(ParameterSetName = "ApiKey")]
        [WHDConnectionMode] $AuthenticationMode = [WHDConnectionMode]::Token,

        [Parameter(Mandatory, ParameterSetName = "Token")]
        [PSTypeName("SolarWinds.WebHelpDesk.Token")] $Token,

        [Parameter(Mandatory, ParameterSetName = "Session")]
        [PSTypeName("SolarWinds.WebHelpDesk.Session")] $Session
    )

    # Disconnect first to keep things clean if we're already connected
    Disconnect-WHDServer -Confirm:$false

    try {
        # Store the base URL, used by other helper functions when building endpoints
        $Script:WHDConnection.UriBuilder          = [System.UriBuilder]::new($BaseUrl)
        $Script:WHDConnection.UriBuilder.Path     = "api/v1/ra"
        $Script:WHDConnection.UriBuilder.UserName = $null
        $Script:WHDConnection.UriBuilder.Password = $null
        $Script:WHDConnection.UriBuilder.Query    = $null
        $Script:WHDConnection.UriBuilder.Fragment = $null

        # Pre-create a WebSession object that we can reuse for all our requests
        # This handles cookies/caching for the REST API
        $Script:WHDConnection.WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

        switch ($PSCmdlet.ParameterSetName) {
            "Token" {
                if ($Token.IsExpired) {
                    throw "The supplied Token has expired."
                }

                $Script:WHDConnection.Token = $Token
            }
            "Session" {
                if ($Session.IsExpired) {
                    throw "The supplied Session has expired."
                }

                $Script:WHDConnection.Session = $Session
            }
            "ApiKey" {
                # Store the credentials in our state so they can authenticate directly or be exchanged.
                $Script:WHDConnection.ApiKey = $ApiKey
                if ($PSBoundParameters.ContainsKey("Username")) {
                    $Script:WHDConnection.Username = $Username
                }

                switch ($AuthenticationMode) {
                    ([WHDConnectionMode]::Token) {
                        $Script:WHDConnection.Token = New-WHDToken -ErrorAction Stop
                    }
                    ([WHDConnectionMode]::Session) {
                        $Script:WHDConnection.Session = New-WHDSession -ErrorAction Stop
                    }
                    ([WHDConnectionMode]::Direct) {
                        # Keep the supplied credentials for direct API-key authentication.
                    }
                }

                if ($AuthenticationMode -ne [WHDConnectionMode]::Direct) {
                    # Clear credentials after exchanging them for the selected authentication type.
                    $Script:WHDConnection.Username = $null
                    $Script:WHDConnection.ApiKey   = $null
                }
            }
        }
    } catch {
        # Do not leave credentials or partial connection state after initialization fails.
        Clear-Connection
        throw
    }
}
