<#
    .SYNOPSIS
    Get a StatusType from WHD.

    .DESCRIPTION
    This function retrieves a specific StatusType from WHD, or a list of all StatusTypes.

    .PARAMETER ResourceId
    The id of the StatusType to be retrieved.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-StatusType {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::StatusTypes
        Expand       = $Expand.IsPresent
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-Resource @QueryParameters
}