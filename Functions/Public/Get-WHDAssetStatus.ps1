<#
    .SYNOPSIS
    Get an AssetStatus from WHD.

    .DESCRIPTION
    This function retrieves all asset statuses from WHD.

    .NOTES
    WARNING: AssetStatuses don't support qualifiers, so they are actually ignored.
#>
function Get-WHDAssetStatus {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [string] $Qualifier = [string]::Empty,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::AssetStatuses

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-WHDResource `
                -ResourceType $ResourceType `
                -Qualifier    ([string]::Empty) `
                -Expand:$Expand
        }
    }

    # Return the asset statuses
    return $Results
}