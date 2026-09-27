<#
    .SYNOPSIS
    Get a StatusType from WHD.

    .DESCRIPTION
    This function retrieves a specific StatusType from WHD, or a list of all StatusTypes.

    .PARAMETER ResourceId
    The id of the StatusType to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDStatusType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::StatusType
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
