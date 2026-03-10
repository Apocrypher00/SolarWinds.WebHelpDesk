<#
    .SYNOPSIS
    Expand a partial WHD Resource

    .DESCRIPTION
    This is meant to expand the objects returned by a search, since the results don't contain the entire resource.
#>
function Expand-WHDResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Resource")] $Resource
    )

    process {
        return Get-WHDResource `
            -ResourceType $Resource.ResourceType `
            -ResourceId   $Resource.id
    }
}