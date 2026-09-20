<#
    .SYNOPSIS
    Remove a Location from WHD.
#>
function Remove-WHDLocation {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Location")] $Location
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Location.Name)", "Remove Location from Web Help Desk")) {
            Remove-WHDResource -Resource $Location -Confirm:$false
        }
    }
}
