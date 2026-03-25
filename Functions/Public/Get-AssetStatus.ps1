<#
    .SYNOPSIS
    Get an AssetStatus from WHD.

    .DESCRIPTION
    This function retrieves all asset statuses from WHD.

    .PARAMETER ResourceId
    The resource ID of the asset status to retrieve.

    .PARAMETER Qualifier
    A WHD qualifier string to filter the asset statuses to retrieve.
    This parameter is not actually supported for this ResourceType, but
    is included for consistency with other Get-WHD* functions.

    .PARAMETER Expand
    If specified, the function will expand the asset status details to include additional information.

    .NOTES
    This ResourceType doesn't actually support qualifiers.
#>
function Get-AssetStatus {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [string] $Qualifier,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::AssetStatuses

    # This ResourceType doesn't actually support qualifiers, so
    # ignore the provided qualifier and use an empty string instead.
    $Qualifier = [string]::Empty

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    return $Results
}