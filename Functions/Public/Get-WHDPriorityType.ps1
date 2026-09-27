<#
    .SYNOPSIS
    Get a PriorityType from WHD.

    .DESCRIPTION
    This function retrieves a specific PriorityType from WHD, or a list of all PriorityTypes.

    .PARAMETER ResourceId
    The id of the PriorityType to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDPriorityType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::PriorityType
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
