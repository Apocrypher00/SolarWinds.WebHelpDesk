<#
    .SYNOPSIS
    Get a department from WHD.

    .DESCRIPTION
    This function retrieves departments from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the department to retrieve.

    .PARAMETER Qualifier
    A WHD qualifier string to filter the departments to retrieve.
    This parameter is not actually supported for this ResourceType, but
    is included for consistency with other Get-WHD* functions.

    .PARAMETER Expand
    If specified, the function will expand the department details to include additional information.

    .NOTES
    This ResourceType doesn't actually support qualifiers.
#>
function Get-WHDDepartment {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [string] $Qualifier,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::Departments

    # This ResourceType doesn't actually support qualifiers, so
    # ignore the provided qualifier and use an empty string instead.
    $Qualifier = [string]::Empty

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    return $Results
}