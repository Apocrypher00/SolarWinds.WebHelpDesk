<#
    .SYNOPSIS
    Get a manufacturer from WHD.

    .DESCRIPTION
    This function retrieves manufacturers from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the manufacturer to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the manufacturer details to include additional.

    .NOTES
    This can return 0, 1, or multiple Manufacturers!
#>
function Get-WHDManufacturer {
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
                -ResourceType ([WHDResourceType]::Manufacturers) `
                -ResourceId   $ResourceId
        }
    }

    # Return the manufacturers
    return $Results
}