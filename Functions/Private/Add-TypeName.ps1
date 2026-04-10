<#
    .SYNOPSIS
    Add a custom type name to the input object based on the WHD Resource type.

    .DESCRIPTION
    This function is used to add a custom type name to the input object based on the WHD Resource type.
    As well as the generic "SolarWinds.WebHelpDesk.Resource" type name.
    This allows for easier filtering and processing of the objects in later stages of the pipeline.

    .PARAMETER InputObject
    The object to which the custom type name will be added.

    .PARAMETER ResourceType
    The type of WHD resource that the input object represents.
    This should be one of the values from the WHDResourceType enum.
#>

function Add-TypeName {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject] $InputObject,

        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType
    )
    process {
        $InputObject.PSObject.TypeNames.Insert(0, "SolarWinds.WebHelpDesk.Resource")
        $InputObject.PSObject.TypeNames.Insert(0, "SolarWinds.WebHelpDesk.$ResourceType")
        return $InputObject
    }
}
