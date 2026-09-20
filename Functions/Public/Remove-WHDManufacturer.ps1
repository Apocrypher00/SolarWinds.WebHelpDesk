<#
    .SYNOPSIS
    Remove a Manufacturer from WHD.
#>
function Remove-WHDManufacturer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Manufacturer")] $Manufacturer
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Manufacturer.name)", "Remove Manufacturer from Web Help Desk")) {
            Remove-WHDResource -Resource $Manufacturer -Confirm:$false
        }
    }
}
