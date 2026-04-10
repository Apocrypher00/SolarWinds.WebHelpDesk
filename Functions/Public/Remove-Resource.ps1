<#
    .SYNOPSIS
    Remove a resource from WHD via the API.

    .DESCRIPTION
    This function deletes a resource from WHD based on the resource type and ID.
    Except in the case of Sessions, which must be removed via sessionKey.
#>
function Remove-Resource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Resource")] $Resource
    )

    process {
        Assert-Connection

        $ResourceType = $Resource.ResourceType

        # The API guide doesn't indicate whether these can/can't be deleted
        # But it explicitly states that others can be, so we'll assume these can't
        if ($ResourceType -in @(
                [WHDResourceType]::AssetStatuses
                [WHDResourceType]::BillingRates
                [WHDResourceType]::CustomFieldDefinitions
                [WHDResourceType]::Departments
                [WHDResourceType]::Email
                [WHDResourceType]::Preferences
                [WHDResourceType]::PriorityTypes
                [WHDResourceType]::RequestTypes
                [WHDResourceType]::Rooms
                [WHDResourceType]::StatusTypes
                [WHDResourceType]::TechNotes
                [WHDResourceType]::Techs
                [WHDResourceType]::TicketAttachments
                [WHDResourceType]::TicketBulkActions
                [WHDResourceType]::TicketNotes
            )
        ) {
            throw "The '$($Resource.ResourceType)' ResourceType doesn't support DELETE."
        }

        # Create a copy of the Module level UriBuilder
        $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

        # Add the ResourceType to the path
        $UriBuilder.Path += "/$ResourceType"

        # Add the ResourceId to the path; Sessions are an exception
        if ($ResourceType -eq [WHDResourceType]::Session) {
            $QueryParams = New-HttpQSCollection
            $QueryParams.Add("sessionKey", $Resource.sessionKey)
            $ShouldProcessMessage = "ResourceType=$ResourceType, SessionKey=$($Resource.sessionKey)"
        } else {
            $QueryParams = Copy-Authentication
            $UriBuilder.Path += "/$($Resource.id)"
            $ShouldProcessMessage = "ResourceType=$ResourceType, ResourceId=$($Resource.id)"
        }

        $UriBuilder.Query = $QueryParams.ToString()

        # Send the request and return the result
        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage, "Remove Resource from Web Help Desk")) {
            return Invoke-Method `
                -UriBuilder $UriBuilder `
                -Method     [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
        }
    }
}