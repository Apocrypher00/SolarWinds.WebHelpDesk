<#
    .SYNOPSIS
    Clear all module state related to the Web Help Desk connection.
#>
function Clear-WHDConnection {
    [CmdletBinding()] param ()

    $Script:WHDConnection.BaseUrl                 = $null
    $Script:WHDConnection.UriBuilder              = $null
    $Script:WHDConnection.WebSession              = $null #FIXME: We should dispose of this object if it exists
    $Script:WHDConnection.Session                 = $null
    $Script:WHDConnection.Authentication.apiKey   = $null
    $Script:WHDConnection.Authentication.username = $null
    $Script:WHDConnection.AuthParams.Clear()
}