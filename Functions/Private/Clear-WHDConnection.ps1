<#
    .SYNOPSIS
    Clear all module state related to the Web Help Desk connection.
#>
function Clear-WHDConnection {
    [CmdletBinding()] param ()

    $Script:WHDConnection.BaseUrl                 = $null
    $Script:WHDConnection.WebSession              = $null
    $Script:WHDConnection.Session                 = $null
    $Script:WHDConnection.Authentication.apiKey   = $null
    $Script:WHDConnection.Authentication.username = $null
}