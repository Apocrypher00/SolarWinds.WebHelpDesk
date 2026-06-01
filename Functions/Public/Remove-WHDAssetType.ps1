<#
    .SYNOPSIS
    Remove an AssetType from WHD.
#>
function Remove-WHDAssetType {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.AssetTypes")] $AssetType
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($AssetType.Name)", "Remove AssetType from Web Help Desk")) {
            Remove-WHDResource -Resource $AssetType -Confirm:$false
        }
    }
}