<#
    .SYNOPSIS
    Get headers for the current authentication method.
#>
function Get-AuthenticationHeaders {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Headers = @{}

    if ($null -ne $Script:WHDConnection.Token) {
        $Headers["Authorization"] = `
            "$($Script:WHDConnection.Token.tokenType) $($Script:WHDConnection.Token.accessToken)"
    }

    return $Headers
}
