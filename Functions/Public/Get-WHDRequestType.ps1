<#
    .SYNOPSIS
    Get a RequestType from WHD.

    .DESCRIPTION
    This function retrieves a specific RequestType from WHD, or a list of all RequestTypes.

    .PARAMETER ResourceId
    The id of the RequestType to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDRequestType {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::RequestType
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
