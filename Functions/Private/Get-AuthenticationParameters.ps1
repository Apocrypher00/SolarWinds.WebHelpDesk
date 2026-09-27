<#
    .SYNOPSIS
    Get query parameters for the current authentication method.
#>
function Get-AuthenticationParameters {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.NameValueCollection])]
    param ()

    $Parameters = New-HttpQSCollection

    if ($null -ne $Script:WHDConnection.Session) {
        $Parameters.Add("sessionKey", $Script:WHDConnection.Session.sessionKey)
    } elseif (-not [string]::IsNullOrWhiteSpace($Script:WHDConnection.ApiKey)) {
        $Parameters.Add("apiKey", $Script:WHDConnection.ApiKey)

        if (-not [string]::IsNullOrWhiteSpace($Script:WHDConnection.Username)) {
            $Parameters.Add("username", $Script:WHDConnection.Username)
        }
    }

    # The leading comma forces this to be returned as a single object rather than unrolling the collection
    return , $Parameters
}
