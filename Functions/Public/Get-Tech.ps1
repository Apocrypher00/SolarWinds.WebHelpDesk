<#
    .SYNOPSIS
    Get a Tech from WHD.

    .DESCRIPTION
    This function retrieves a specific Tech from WHD, or a list of all Techs.

    .PARAMETER ResourceId
    The id of the Tech to be retrieved.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-Tech {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Techs
        Expand       = $Expand.IsPresent
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-Resource @QueryParameters
}