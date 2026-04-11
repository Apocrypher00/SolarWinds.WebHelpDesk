<#
    .SYNOPSIS
    Creates a copy of a System.UriBuilder object.
#>
function Copy-UriBuilder {
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param (
        [Parameter(Mandatory)]
        [System.UriBuilder] $UriBuilder
    )

    return [System.UriBuilder]::new($UriBuilder.Uri)
}