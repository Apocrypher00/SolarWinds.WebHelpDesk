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
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Resource")] $Resource
    )

    process {
        Assert-WHDConnection

        # Create a copy of the Module level UriBuilder
        $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

        # Add the authentication parameters to the query string; this is required for all requests
        $UriBuilder.Query = $Script:WHDConnection.AuthParams.ToString()

        $ResourceType = $Resource.ResourceType

        # Add the ResourceType and ResourceId to the path; Sessions are an exception
        <#
            TODO: We only need /Session?sessionKey= for deleting sessions, and
            the active sessionKey is already stored in the AuthParams, unless PersistCredentials was used.
            If that's the case we actually need to replace AuthParams with the passed sessionKey.
        #>
        $UriBuilder.Path += "/$ResourceType"

        if ($Resource.ResourceType -ne [WHDResourceType]::Session) {
            $UriBuilder.Path += "/$($Resource.ResourceId)"
            $ShouldProcessMessage = "ResourceType=$ResourceType, ResourceId=$($Resource.ResourceId)"
        } else {
            $UriBuilder.Query = "sessionKey=$($Resource.sessionKey)" # FIXME: Should we use [System.Web.HttpUtility]?
            $ShouldProcessMessage = "ResourceType=$ResourceType, SessionKey=$($Resource.sessionKey)"
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