<#
    .SYNOPSIS
    Get a WHD Client by their email address.
#>
function Get-WHDClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Email,

        [Parameter()]
        [switch] $Expand
    )

    # Search for the Client by Email to get the ID
    $Results = Get-WHDResource `
        -Resource  ([WHDResourceType]::Clients) `
        -Qualifier "(email caseInsensitiveLike '$Email')" `
        -Expand:$Expand

    return $Results
}