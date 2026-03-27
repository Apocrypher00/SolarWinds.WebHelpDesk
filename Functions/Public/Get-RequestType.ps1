<#
    .SYNOPSIS
    Get a RequestType from WHD.

    .DESCRIPTION
    This function retrieves a specific RequestType from WHD, or a list of all RequestTypes.

    .PARAMETER ResourceId
    The id of the RequestType to be retrieved.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-RequestType {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::RequestTypes
        Expand       = $Expand.IsPresent
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-Resource @QueryParameters
}