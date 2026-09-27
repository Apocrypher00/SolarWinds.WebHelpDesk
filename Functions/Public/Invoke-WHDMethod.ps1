<#
    .SYNOPSIS
    Invoke a Web Help Desk API request.

    .DESCRIPTION
    Builds and sends a request to the Web Help Desk REST API using the current module connection.
    This helper centralizes the shared web request behavior used by the *-Resource commands,
    including reuse of the current web session.

    .PARAMETER UriBuilder
    The UriBuilder for the target API endpoint.
    Any existing query is ignored; supply query parameters using QueryParameters instead.

    .PARAMETER Method
    The HTTP method to use for the request.

    .PARAMETER Body
    Optional parameters or request body to send to the API.
    POST and PUT bodies are serialized as JSON; GET hashtables are sent as query parameters.

    .PARAMETER QueryParameters
    Optional query parameters to add to the request.
    The collection is copied before authentication parameters are added.

    .PARAMETER AsWebResponse
    If specified, uses Invoke-WebRequest and returns the web response object.
    By default, Invoke-RestMethod is used and the JSON response body is deserialized.

    .PARAMETER NoAuthentication
    If specified, the current connection authentication isn't added to the request.

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
        [System.Collections.Specialized.NameValueCollection] $QueryParameters,

        [Parameter()]
        [switch] $AsWebResponse,

        [Parameter()]
        [switch] $NoAuthentication
    )

    $RequestUriBuilder = Copy-UriBuilder -UriBuilder $UriBuilder

    if ($null -eq $QueryParameters) {
        $RequestQuery = New-HttpQSCollection
    } else {
        $RequestQuery = Copy-HttpQSCollection -Source $QueryParameters
    }

    $ParameterHash = @{
        Method     = $Method
        WebSession = $Script:WHDConnection.WebSession
    }

    if (-not $NoAuthentication) {
        Assert-Connection

        switch (Get-AuthenticationType) {
            ([WHDAuthenticationType]::QueryParameters) {
                $AuthenticationParameters = Get-AuthenticationParameters

                foreach ($Key in $AuthenticationParameters.AllKeys) {
                    $RequestQuery[$Key] = $AuthenticationParameters[$Key]
                }
            }

            ([WHDAuthenticationType]::Headers) {
                $ParameterHash["Headers"] = Get-AuthenticationHeaders
            }

            ([WHDAuthenticationType]::None) {
                throw "No authentication method is available."
            }
        }
    }

    $RequestUriBuilder.Query = $RequestQuery.ToString()
    $ParameterHash["Uri"] = $RequestUriBuilder.Uri

    if ($null -ne $Body) {
        if ($Method -in @(
                [Microsoft.PowerShell.Commands.WebRequestMethod]::Post,
                [Microsoft.PowerShell.Commands.WebRequestMethod]::Put
            )
        ) {
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
