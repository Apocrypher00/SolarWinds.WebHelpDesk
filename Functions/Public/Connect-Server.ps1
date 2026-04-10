<#
    .SYNOPSIS
    Connect to the WebHelpDesk API.

    .DESCRIPTION
    This function establishes a connection to the WHD API by obtaining a session key using the provided credentials.
    The session key and base URL are stored in a global variable for use in subsequent API calls.

    .PARAMETER BaseUrl
    The base URL of the WebHelpDesk instance (e.g., "https://whd.mydomain.com").
    This can include the "/helpdesk/WebObjects/Helpdesk.woa/ra" or some other suffix, as it will be replaced anyway.

    .PARAMETER ApiKey
    The API key for authentication.

    .PARAMETER Username
    The username associated with the API key.
    This is required for Application API keys but optional for User API keys.

    .PARAMETER PersistCredentials
    If set, the API key and username will be stored in the module's state for future use.
    By default, credentials are only used to obtain a session key and are not stored.
#>
function Connect-Server {
    [CmdletBinding()]
    [OutputType([void])]
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
    Disconnect-Server -Confirm:$false

    # Store the base URL, used by other helper functions when building endpoints
    $Script:WHDConnection.UriBuilder          = [System.UriBuilder]::new($BaseUrl)
    $Script:WHDConnection.UriBuilder.Path     = "helpdesk/WebObjects/Helpdesk.woa/ra"
    $Script:WHDConnection.UriBuilder.UserName = $null
    $Script:WHDConnection.UriBuilder.Password = $null
    $Script:WHDConnection.UriBuilder.Query    = $null
    $Script:WHDConnection.UriBuilder.Fragment = $null

    # Pre-create a WebSession object that we can reuse for all our requests
    # This handles cookies/caching for the REST API
    $Script:WHDConnection.WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

    # Store the credentials temporarily in our state; we'll use them to get a session key
    $Script:WHDConnection.AuthParams.Add("apiKey", $ApiKey)
    if ($PSBoundParameters.ContainsKey("Username")) {
        $Script:WHDConnection.AuthParams.Add("username", $Username)
    }

    if (-not $PersistCredentials) {
        # Get a session key and save it in our state
        $Script:WHDConnection.Session = Get-Session
        $Script:WHDConnection.AuthParams.Add("sessionKey", $Script:WHDConnection.Session.sessionKey)

        # Clear the temporary credentials from our state for security; we only need the session key going forward
        $Script:WHDConnection.AuthParams.Remove("username") | Out-Null
        $Script:WHDConnection.AuthParams.Remove("apiKey") | Out-Null
    }
}