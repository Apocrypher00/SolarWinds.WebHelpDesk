<#
    .SYNOPSIS
    Get the transport used by the current authentication method.
#>
function Get-AuthenticationType {
    [CmdletBinding()]
    [OutputType([WHDAuthenticationType])]
    param ()

    if ($null -ne $Script:WHDConnection.Token) {
        return [WHDAuthenticationType]::Headers
    }

    if (
        ($null -ne $Script:WHDConnection.Session) -or
        (-not [string]::IsNullOrWhiteSpace($Script:WHDConnection.ApiKey))
    ) {
        return [WHDAuthenticationType]::QueryParameters
    }

    return [WHDAuthenticationType]::None
}
