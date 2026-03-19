<#
    .SYNOPSIS
    Remove a Company from WHD.
#>
function Remove-WHDCompany {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PSTypeName("SolarWinds.WebHelpDesk.Companies")] $Company
    )

    process {
        if ($PSCmdlet.ShouldProcess("CompanyName=$($Company.companyName)", "Remove Company from Web Help Desk")) {
            Remove-WHDResource -Resource $Company -Confirm:$false
        }
    }
}