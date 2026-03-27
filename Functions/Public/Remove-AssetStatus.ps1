<#
    .SYNOPSIS
    Remove an AssetStatus from WHD.
#>
function Remove-AssetStatus {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.AssetStatuses")] $AssetStatus
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($AssetStatus.name)", "Remove AssetStatus from Web Help Desk")) {
            Remove-Resource -Resource $AssetStatus -Confirm:$false
        }
    }
}
