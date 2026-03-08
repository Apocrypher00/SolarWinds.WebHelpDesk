<#
    .SYNOPSIS
    Remove a client from WHD based on their email.
#>
function Remove-WHDClient {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(ParameterSetName = "Client", Mandatory)]
        [PSTypeName("SolarWinds.WebHelpDesk.Clients")] $Client,

        [Parameter(ParameterSetName = "Email", Mandatory)]
        [string] $Email
    )

    if ($PSCmdlet.ParameterSetName -eq "Email") {
        # Search for the Client by Email to get the ID
        $Client = Get-WHDClient -Email $Email

        # Validate we got exactly 1 result back, otherwise we don't know what to delete
        if ($Client.Count -eq 0) {
            throw "No results!"
        } elseif ($Client.Count -gt 1) {
            throw "More than 1 result!"
        }
    } else {
        $Email = $Client.email
    }

    # Delete the Client by ID
    if ($PSCmdlet.ShouldProcess("Email=$Email")) {
        Remove-WHDResource `
            -ResourceType   ([WHDResourceType]::Clients) `
            -ResourceId $Client[0].id `
            -Confirm:$false
    }
}
