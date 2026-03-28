<#
    .SYNOPSIS
    Get the BillingRates from WHD.

    .DESCRIPTION
    This function retrieves a list of BillingRates from WHD.

    .NOTES
    This ResourceType doesn't support retrieving a single BillingRate by id.
    This ResourceType doesn't support Qualifiers.
    The detailed format for this ResourceType is identical to the short format.
#>
function Get-BillingRate {
    [CmdletBinding()] param ()

    return Get-Resource -ResourceType ([WHDResourceType]::BillingRates)
}