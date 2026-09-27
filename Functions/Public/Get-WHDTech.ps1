<#
    .SYNOPSIS
    Get a Tech from WHD.

    .DESCRIPTION
    This function retrieves a specific Tech from WHD, or a list of all Techs.

    .PARAMETER ResourceId
    The id of the Tech to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDTech {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Tech
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
