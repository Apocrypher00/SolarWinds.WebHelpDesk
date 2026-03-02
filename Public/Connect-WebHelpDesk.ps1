function Connect-WebHelpDesk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $BaseUrl,

        [Parameter(Mandatory, ParameterSetName = "ApiKey")]
        [string] $ApiKey,

        [Parameter(Mandatory)]
        [string] $Username,

        [Parameter(Mandatory, ParameterSetName = "Password")]
        [string] $Password
    )

    # Ensure we have a container for WHD state and capture the BaseUrl
    if (-not $Script:WHD) { $Script:WHD = @{} }

    # Store the base URL, used by other helper functions when building endpoints
    $Script:WHD.BaseUrl  = "$BaseUrl/helpdesk/WebObjects/Helpdesk.woa/ra"

    # Pre-create a WebSession object that we can reuse for all our requests; this
    # handles cookies/caching for the REST API.
    $Script:WHD.WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

    # Get a session key and save it in our state – works with either credentials
    $Script:WHD.Session = if ($ApiKey) {
        Get-WHDSession -ApiKey $ApiKey -Username $Username
    } else {
        Get-WHDSession -Username $Username -Password $Password
    }
}