<#
    .SYNOPSIS
    Remove a client from WHD based on their email.
#>
function Remove-WHDClient {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [string] $Email
    )

    # Search for the Client by Email to get the ID
    $Client = Get-WHDClient @PSBoundParameters

    # Validate we got exactly 1 result back, otherwise we don't know what to delete
    if ($Client.Count -eq 0) {
        throw "No results!"
    } elseif ($Client.Count -gt 1) {
        throw "More than 1 result!"
    }

    # Delete the Client by ID
    if ($PSCmdlet.ShouldProcess("Email=$Email")) {
        Remove-WHDResource `
            -Resource   ([WHDResourceType]::Client) `
            -ResourceId $Client[0].id `
            -Confirm:$false
    }
}
