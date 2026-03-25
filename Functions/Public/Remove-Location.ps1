<#
    .SYNOPSIS
    Remove a Location from WHD.
#>
function Remove-Location {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Locations")] $Location
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Location.Name)", "Remove Location from Web Help Desk")) {
            Remove-Resource -Resource $Location -Confirm:$false
        }
    }
}