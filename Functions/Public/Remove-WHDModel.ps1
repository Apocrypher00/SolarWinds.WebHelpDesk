<#
    .SYNOPSIS
    Remove a Model from WHD.
#>
function Remove-WHDModel {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Models")] $Model
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Model.Name)", "Remove Model from Web Help Desk")) {
            Remove-WHDResource -Resource $Model -Confirm:$false
        }
    }
}