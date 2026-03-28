<#
    .SYNOPSIS
    Get a TicketBulkAction from WHD.

    .DESCRIPTION
    This function retrieves a specific TicketBulkAction from WHD, or a list of all TicketBulkActions.

    .PARAMETER ResourceId
    The id of the TicketBulkAction to be retrieved.

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-TicketBulkAction {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int] $ResourceId,

        [Parameter()]
        [switch] $Expand
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::TicketBulkActions
        Expand       = $Expand.IsPresent
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-Resource @QueryParameters
}