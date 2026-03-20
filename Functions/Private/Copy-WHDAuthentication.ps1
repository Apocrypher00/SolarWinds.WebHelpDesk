<#
    .SYNOPSIS
    Copy the current authentication parameters.
#>
function Copy-WHDAuthentication {
    [CmdletBinding()] param ()

    $NewCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    foreach ($key in $Script:WHDConnection.AuthParams.Keys) {
        $NewCollection.Add($key, $Script:WHDConnection.AuthParams[$key])
    }

    # The leading comma forces this to be returned as a single object rather than unrolling the collection
    return ,$NewCollection
}