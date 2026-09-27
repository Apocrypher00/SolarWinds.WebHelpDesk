<#
    .SYNOPSIS
    Test whether a ResourceType request returns paged results.

    .DESCRIPTION
    Returns true for list requests that use the standard paged response envelope.
#>
function Test-ReturnsPagedResults {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [switch] $Single
    )

    return (
        (-not $Single) -and
        ($ResourceType -notin @(
            [WHDResourceType]::Preference
            [WHDResourceType]::Session
            [WHDResourceType]::ticketAttachment
        ))
    )
}
