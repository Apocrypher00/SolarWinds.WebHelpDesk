<#
    .SYNOPSIS
    Creates a copy of an existing HttpQSCollection object.
#>
function Copy-HttpQSCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Collections.Specialized.NameValueCollection] $Source
    )

    $Copy = New-HttpQSCollection

    foreach ($Key in $Source.AllKeys) {
        $Copy.Add($Key, $Source[$Key])
    }

    # The leading comma prevents unwrapping the collection when returned
    return ,$Copy
}