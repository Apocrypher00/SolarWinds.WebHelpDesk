<#
    .SYNOPSIS
    Get a model from WHD.

    .DESCRIPTION
    This function retrieves models from WHD based on a provided search parameter.

    .PARAMETER Expand
    If specified, the function will expand the model details to include additional.

    .NOTES
    This can return 0, 1, or multiple Models!
#>
function Get-WHDModel {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType ([WHDResourceType]::Models) `
                -ResourceId   $ResourceId
        }
    }

    # Return the models
    return $Results
}