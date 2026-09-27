<#
    .SYNOPSIS
    Assert that a ResourceType supports an expanded response.

    .DESCRIPTION
    Checks whether a ResourceType supports detailed results for a list or single-resource request.
#>
function Assert-SupportsExpand {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [switch] $Single
    )

    if ($ResourceType -eq [WHDResourceType]::Model) {
        return
    }

    if (
        (-not $Single) -and
        ($ResourceType -in @(
            [WHDResourceType]::Asset
            [WHDResourceType]::Location
            [WHDResourceType]::TicketNote
            [WHDResourceType]::Tickets
        ))
    ) {
        return
    }

    $RequestType = if ($Single) { "single-resource" } else { "list" }
    throw "The '$ResourceType' ResourceType doesn't support Expand for $RequestType requests."
}
