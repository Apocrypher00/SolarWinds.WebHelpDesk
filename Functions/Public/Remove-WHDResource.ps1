<#
    .SYNOPSIS
    Remove a resource from WHD via the API.

    .DESCRIPTION
    This function deletes a resource from WHD based on the resource type and ID.
    Except in the case of Sessions, which must be removed via sessionKey.

    .NOTES
    FIXME: Add the option to pass the whole Resource to be deleted.
    FIXME: Add ValueFromPipeline
    FIXME: Once the above is added, we can delete arbitrary Sessions by replacing AuthParams with the passed sessionKey
#>
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter(Mandatory)]
        [int] $ResourceId
    )

    Assert-WHDConnection

    # Create a copy of the Module level UriBuilder
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Add the authentication parameters to the query string; this is required for all requests
    $UriBuilder.Query = $Script:WHDConnection.AuthParams.ToString()

    # Add the ResourceType and ResourceId to the path; Sessions are an exception
    <#
        TODO: We only need /Session?sessionKey= for deleting sessions, and
        the active sessionKey is already stored in the AuthParams, unless PersistCredentials was used.
        If that's the case we actually need to replace AuthParams with the passed sessionKey.
    #>
    $UriBuilder.Path += "/$ResourceType"

    if ($ResourceType -ne [WHDResourceType]::Session) {
        $UriBuilder.Path += "/$ResourceId"
    }

    # Parameters for Invoke-RestMethod
    $ParameterHash = @{
        Uri         = $UriBuilder.ToString()
        Method      = [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
        ContentType = "application/json"
        WebSession  = $Script:WHDConnection.WebSession
    }

    # Send the query and return the result
    if ($PSCmdlet.ShouldProcess("ResourceType=$ResourceType, ResourceId=$ResourceId")) {
        return Invoke-RestMethod @ParameterHash
    }
}