<#
    .SYNOPSIS
    Remove an AssetStatus from WHD.
#>
function Remove-WHDAssetStatus {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.AssetStatus")] $AssetStatus
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($AssetStatus.name)", "Remove AssetStatus from Web Help Desk")) {
            Remove-WHDResource -Resource $AssetStatus -Confirm:$false
        }
    }
}
