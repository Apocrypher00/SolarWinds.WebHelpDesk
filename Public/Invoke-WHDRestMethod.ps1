function Invoke-WHDRestMethod {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet(
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Post,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Put,
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
        )]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Uri,

        [Parameter(Mandatory = $false, Position = 2)]
        [hashtable] $Body
    )


}