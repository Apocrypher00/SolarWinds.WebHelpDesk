<#
    .SYNOPSIS
    Get a TicketBulkAction from WHD.

    .DESCRIPTION
    This function retrieves a specific TicketBulkAction from WHD, or a list of all TicketBulkActions.

    .PARAMETER ResourceId
    The id of the TicketBulkAction to be retrieved.

    .NOTES
    This ResourceType doesn't support Qualifiers.
#>
function Get-WHDTicketBulkAction {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int] $ResourceId
    )

    $QueryParameters = @{
        ResourceType = [WHDResourceType]::TicketBulkAction
    }

    if ($PSBoundParameters.ContainsKey("ResourceId")) {
        $QueryParameters["ResourceId"] = $ResourceId
    }

    return Get-WHDResource @QueryParameters
}
