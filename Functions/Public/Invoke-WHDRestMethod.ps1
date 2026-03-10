<#
    .SYNOPSIS

    .DESCRIPTION
    This will be a combined function for all types of requests

    .NOTES
    FIXME: This is a w.i.p.
#>
function Invoke-WHDRestMethod {
    param (
        [Parameter(Mandatory)]
        [ValidateSet(
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Post,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Put,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
        )]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Parameter()]
        [hashtable] $Body
    )


}