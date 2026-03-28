<#
    .SYNOPSIS
    Remove a resource from WHD via the API.

    .DESCRIPTION
    This function deletes a resource from WHD based on the resource type and ID.
    Except in the case of Sessions, which must be removed via sessionKey.

    .NOTES
    TODO: Extract the common logic into Invoke-WHDRequest and use that for all API calls, including deletes.
    FIXME: Once the above is added, we can delete arbitrary Sessions by replacing AuthParams with the passed sessionKey
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

        # Add the authentication parameters to the query string; this is required for all requests
        # FIXME: Switch to a copy of AuthParams
        $UriBuilder.Query = $Script:WHDConnection.AuthParams.ToString()

        # Add the ResourceType and ResourceId to the path; Sessions are an exception
        <#
            TODO: We only need /Session?sessionKey= for deleting sessions, and
            the active sessionKey is already stored in the AuthParams, unless PersistCredentials was used.
            If that's the case we actually need to replace AuthParams with the passed sessionKey.
        #>
        $UriBuilder.Path += "/$ResourceType"

        if ($ResourceType -eq [WHDResourceType]::Session) {
            $UriBuilder.Query = "sessionKey=$($Resource.sessionKey)" # FIXME: Should we use [System.Web.HttpUtility]?
            $ShouldProcessMessage = "ResourceType=$ResourceType, SessionKey=$($Resource.sessionKey)"
        } else {
            $UriBuilder.Path += "/$($Resource.id)"
            $ShouldProcessMessage = "ResourceType=$ResourceType, ResourceId=$($Resource.ResourceId)"
        }

        # Parameters for Invoke-RestMethod
        $ParameterHash = @{
            Uri         = $UriBuilder.ToString()
            Method      = [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
            ContentType = "application/json"
            WebSession  = $Script:WHDConnection.WebSession
        }

        # Send the query and return the result
        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage, "Remove resource from Web Help Desk")) {
            return Invoke-RestMethod @ParameterHash
        }
    }
}