<#
    .SYNOPSIS
    Remove a StatusType from WHD.
#>
function Remove-StatusType {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.StatusTypes")] $StatusType
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($StatusType.Name)", "Remove StatusType from Web Help Desk")) {
            Remove-Resource -Resource $StatusType -Confirm:$false
        }
    }
}
