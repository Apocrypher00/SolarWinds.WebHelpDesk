<#
    .SYNOPSIS
    Clear all module state related to the Web Help Desk connection.
#>
function Clear-Connection {
    [CmdletBinding()] param ()

    try {
        # Dispose of the WebSession to clear cookies/caching and free resources.
        # PowerShell 7's WebRequestSession implements IDisposable; Windows PowerShell 5.1's does not.
        if ($Script:WHDConnection.WebSession -is [System.IDisposable]) {
            $Script:WHDConnection.WebSession.Dispose()
        }
    } finally {
        $Script:WHDConnection.UriBuilder = $null
        $Script:WHDConnection.WebSession = $null
        $Script:WHDConnection.Session    = $null
        $Script:WHDConnection.Token      = $null
        $Script:WHDConnection.AuthParams.Clear()
        $Script:WHDConnection.AuthHeaders.Clear()
    }
}
