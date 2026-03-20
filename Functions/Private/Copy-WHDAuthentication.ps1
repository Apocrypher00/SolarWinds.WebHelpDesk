<#
    .SYNOPSIS
    Copy the current authentication parameters.
#>
function Copy-WHDAuthentication {
    [CmdletBinding()] param ()

    $Copy = Copy-HttpQSCollection -Source $Script:WHDConnection.AuthParams

    # The leading comma forces this to be returned as a single object rather than unrolling the collection
    return ,$Copy
}