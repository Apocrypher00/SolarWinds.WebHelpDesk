<#
    .SYNOPSIS
    Connect to the WebHelpDesk API.

    .DESCRIPTION
    This function establishes a connection to the WHD API by obtaining a session key using the provided credentials.
    The session key and base URL are stored in a global variable for use in subsequent API calls.

    .PARAMETER BaseUrl
    The base URL of the WebHelpDesk instance (e.g., "https://mywhdserver.com").
    This should not include the "/helpdesk/WebObjects/Helpdesk.woa/ra" suffix, as that is added automatically.

    .PARAMETER ApiKey
    The API key for authentication.

    .PARAMETER Username
    The username associated with the API key. This is required for Application API keys but optional for User API keys.

    .PARAMETER PersistCredentials
    If set, the API key and username will be stored in the module's state for future use.
    By default, credentials are only used to obtain a session key and are not stored.
#>
function Connect-WebHelpDesk {
    [CmdletBinding()] # TODO: Should we add SupportsShouldProcess?
    param (
        [Parameter(Mandatory)]
        [string] $BaseUrl,

        [Parameter(Mandatory)]
        [string] $ApiKey,

        [Parameter()]
        [string] $Username,

        [Parameter()]
        [switch] $PersistCredentials
    )

    # Disconnect first to keep things clean if we're already connected
    Disconnect-WebHelpDesk -Confirm:$false

    # Store the base URL, used by other helper functions when building endpoints
    # TODO: Switch to UriBuilder
    $Script:WHDConnection.UriBuilder          = [System.UriBuilder]::new($BaseUrl)
    $Script:WHDConnection.UriBuilder.Path     = "helpdesk/WebObjects/Helpdesk.woa/ra"
    $Script:WHDConnection.UriBuilder.UserName = $null
    $Script:WHDConnection.UriBuilder.Password = $null
    $Script:WHDConnection.UriBuilder.Query    = $null
    $Script:WHDConnection.UriBuilder.Fragment = $null
    $Script:WHDConnection.BaseUrl  = "$BaseUrl/helpdesk/WebObjects/Helpdesk.woa/ra"

    # Pre-create a WebSession object that we can reuse for all our requests; this
    # handles cookies/caching for the REST API.
    $Script:WHDConnection.WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

    # Store the credentials temporarily in our state; we'll use them to get a session key
    $Script:WHDConnection.Authentication.apiKey = $ApiKey
    $Script:WHDConnection.AuthParams.Add("apiKey", $ApiKey)
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Username")) {
        $Script:WHDConnection.Authentication.username = $Username
        $Script:WHDConnection.AuthParams.Add("username", $Username)
    }

    if (-not $PersistCredentials) {
        # Get a session key and save it in our state
        $Script:WHDConnection.Session = Get-WHDSession
        $Script:WHDConnection.AuthParams.Add("sessionKey", $Script:WHDConnection.Session.sessionKey)

        # Clear the temporary credentials from our state for security; we only need the session key going forward
        $Script:WHDConnection.Authentication.apiKey   = $null
        $Script:WHDConnection.Authentication.username = $null
        $Script:WHDConnection.AuthParams.Remove("username") | Out-Null
        $Script:WHDConnection.AuthParams.Remove("apiKey") | Out-Null
    }
}