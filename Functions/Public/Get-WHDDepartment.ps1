<#
    .SYNOPSIS
    Get a Department from WHD.

    .DESCRIPTION
    This function retrieves a specific Department from WHD, or a list of all Departments.

    .PARAMETER ResourceId
    The id of the Department to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDDepartment {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::Department
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
