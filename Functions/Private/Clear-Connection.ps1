<#
    .SYNOPSIS
    Clear all module state related to the Web Help Desk connection.
#>
function Clear-Connection {
    [CmdletBinding()] param ()

    $Script:WHDConnection.UriBuilder = $null
    $Script:WHDConnection.WebSession = $null
    $Script:WHDConnection.Session    = $null
    $Script:WHDConnection.AuthParams.Clear()
}