<#
    .SYNOPSIS
    Remove a Model from WHD.
#>
function Remove-Model {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Models")] $Model
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Model.Name)", "Remove Model from Web Help Desk")) {
            Remove-Resource -Resource $Model -Confirm:$false
        }
    }
}