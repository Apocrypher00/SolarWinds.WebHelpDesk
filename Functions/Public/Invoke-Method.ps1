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
    Optional request body to send to the API.

    .PARAMETER AsWebResponse
    If specified, uses Invoke-WebRequest and returns the web response object.
    By default, Invoke-RestMethod is used and the JSON response body is deserialized.

    .OUTPUTS
    System.Object
    Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject

    .EXAMPLE
    $Response = Invoke-Method -UriBuilder $UriBuilder -Method Get

    Sends a GET request and returns the deserialized API response.

    .EXAMPLE
    $Response = Invoke-Method -UriBuilder $UriBuilder -Method Get -Body @{ qualifier = $QualifierString }

    Sends a GET request with a request body.

    .EXAMPLE
    $Response = Invoke-Method -UriBuilder $UriBuilder -Method Get -AsWebResponse

    Sends a GET request and returns the Invoke-WebRequest response object.
#>
function Invoke-Method {
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

    if ($null -ne $Body) {
        $ParameterHash["ContentType"] = "application/json"
        $ParameterHash["Body"] = $Body
    }

    if ($AsWebResponse) {
        return Invoke-WebRequest @ParameterHash
    } else {
        return Invoke-RestMethod @ParameterHash
    }
}