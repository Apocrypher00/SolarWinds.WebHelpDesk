<#
    .SYNOPSIS
    Remove a Department from WHD.
#>
function Remove-Department {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Departments")] $Department
    )

    process {
        if ($PSCmdlet.ShouldProcess("Name=$($Department.name)", "Remove Department from Web Help Desk")) {
            Remove-Resource -Resource $Department -Confirm:$false
        }
    }
}