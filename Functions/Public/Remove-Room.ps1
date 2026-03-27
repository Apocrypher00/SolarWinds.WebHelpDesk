<#
    .SYNOPSIS
    Remove a Room from WHD.
#>
function Remove-Room {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Rooms")] $Room
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Room.Name)", "Remove Room from Web Help Desk")) {
            Remove-Resource -Resource $Room -Confirm:$false
        }
    }
}
