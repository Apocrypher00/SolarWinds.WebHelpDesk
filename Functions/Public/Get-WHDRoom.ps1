<#
    .SYNOPSIS
    Get a Room from WHD.

    .DESCRIPTION
    This function retrieves a specific Room from WHD, or a list of all Rooms.

    .PARAMETER ResourceId
    The id of the Room to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDRoom {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Room
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
