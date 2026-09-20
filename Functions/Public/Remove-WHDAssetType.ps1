<#
    .SYNOPSIS
    Remove an AssetType from WHD.
#>
function Remove-WHDAssetType {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.AssetType")] $AssetType
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($AssetType.Name)", "Remove AssetType from Web Help Desk")) {
            Remove-WHDResource -Resource $AssetType -Confirm:$false
        }
    }
}
