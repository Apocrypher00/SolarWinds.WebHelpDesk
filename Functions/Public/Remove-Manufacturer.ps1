<#
    .SYNOPSIS
    Remove a Manufacturer from WHD.
#>
function Remove-Manufacturer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Manufacturers")] $Manufacturer
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Manufacturer.name)", "Remove Manufacturer from Web Help Desk")) {
            Remove-Resource -Resource $Manufacturer -Confirm:$false
        }
    }
}