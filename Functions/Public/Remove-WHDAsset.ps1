<#
    .SYNOPSIS
    Remove an Asset from WHD.
#>
function Remove-WHDAsset {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Assets")] $Asset
    )

    process {
        if ($PSCmdlet.ShouldProcess("AssetNumber=$($Asset.assetNumber)", "Remove Asset from Web Help Desk")) {
            Remove-WHDResource -Resource $Asset -Confirm:$false
        }
    }
}