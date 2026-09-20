<#
    .SYNOPSIS
    Invoke a Web Help Desk API request.

    .DESCRIPTION
    Builds and sends a request to the Web Help Desk REST API using the current module connection.
    This helper centralizes the shared web request behavior used by the *-Resource commands,
    including reuse of the current web session.

    .PARAMETER UriBuilder
    The fully prepared UriBuilder for the target API endpoint.

    .PARAMETER Method
    The HTTP method to use for the request.

    .PARAMETER Body
    Optional parameters or request body to send to the API.
    POST and PUT bodies are serialized as JSON; GET hashtables are sent as query parameters.

    .PARAMETER AsWebResponse
    If specified, uses Invoke-WebRequest and returns the web response object.
    By default, Invoke-RestMethod is used and the JSON response body is deserialized.

    .OUTPUTS
    System.Object
    Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject

    .EXAMPLE
    $Response = Invoke-WHDMethod -UriBuilder $UriBuilder -Method Get

    Sends a GET request and returns the deserialized API response.

    .EXAMPLE
    $Response = Invoke-WHDMethod -UriBuilder $UriBuilder -Method Get -Body @{ qualifier = $QualifierString }

    Sends a GET request with qualifier query parameters.

    .EXAMPLE
    $Response = Invoke-WHDMethod -UriBuilder $UriBuilder -Method Get -AsWebResponse

    Sends a GET request and returns the Invoke-WebRequest response object.
#>
function Invoke-WHDMethod {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.UriBuilder] $UriBuilder,

        [Parameter(Mandatory)]
        [ValidateSet("Get", "Post", "Put", "Delete")]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method,

        [Parameter()]
        [hashtable] $Body,

        [Parameter()]
        [switch] $AsWebResponse
    )

    $ParameterHash = @{
        Uri        = $UriBuilder.Uri
        Method     = $Method
        WebSession = $Script:WHDConnection.WebSession
    }

    if ($Script:WHDConnection.AuthHeaders.Count -gt 0) {
        $ParameterHash["Headers"] = $Script:WHDConnection.AuthHeaders.Clone()
    }

    if ($null -ne $Body) {
        if ($Method -in @("Post", "Put")) {
            $ParameterHash["ContentType"] = "application/json"
            # FIXME: Revisit the serialization depth when create/update payloads are implemented.
            $ParameterHash["Body"] = ConvertTo-Json -InputObject $Body -Depth 10 -Compress
        } else {
            $ParameterHash["Body"] = $Body
        }
    }

    if ($AsWebResponse) {
        $Response = Invoke-WebRequest @ParameterHash
    } else {
        $Response = Invoke-RestMethod @ParameterHash
    }

    # Session keys expire after 30 minutes of inactivity, so extend the local estimate after a successful request.
    if ($null -ne $Script:WHDConnection.Session) {
        $Script:WHDConnection.Session.ExpirationDate = [DateTime]::Now.AddMinutes(30)
    }

    return $Response
}
