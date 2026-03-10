<#
    .SYNOPSIS
    Remove a resource from WHD via the API.

    .DESCRIPTION
    This function deletes a resource from WHD based on the resource type and ID.
    Except in the case of Sessions, which must be removed via sessionKey.

    .NOTES
    FIXME: Add the option to pass the whole Resource to be deleted.
    FIXME: Add ValueFromPipeline
    FIXME: Once the above is added, we can delete arbitrary Sessions by replacing AuthString with the passed sessionKey
#>
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter(Mandatory)]
        [int] $ResourceId
    )

    # Build the authentication string; this is required for all requests
    # FIXME: This is a little messy, we can do better.
    if ($Script:WHDConnection.Session) {
        # Check if we have a valid session key, if so use it for authentication
        if (-not $Script:WHDConnection.Session.IsExpired) {
            $AuthString = "sessionKey=$($Script:WHDConnection.Session.sessionKey)"
        } else {
            throw "Session key has expired. Please connect to Web Help Desk again using Connect-WebHelpDesk."
        }
    } elseif ($Script:WHDConnection.Authentication.apiKey) {
        if ($Script:WHDConnection.Authentication.username) {
            $AuthString = "username=$($Script:WHDConnection.Authentication.username)&"
        }

        $AuthString += "apiKey=$($Script:WHDConnection.Authentication.apiKey)"
    } else {
        throw "No authentication method provided. Please connect to Web Help Desk first using Connect-WebHelpDesk."
    }

    # Build the Uri
    # FIXME: Clean this up! I found out the hard way that if the check is wrong, you can delete mutliple objects
    $Uri = "$($WHDConnection.BaseUrl)/$ResourceType"
    if ($ResourceType -ne [WHDResourceType]::Session) { $Uri += "/$ResourceId" }
    $Uri += "?$AuthString"

    # Send the query and return the result
    if ($PSCmdlet.ShouldProcess("ResourceType=$ResourceType, ResourceId=$ResourceId")) {
        return Invoke-RestMethod `
            -Uri         $Uri `
            -Method      ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) `
            -ContentType "application/json" `
            -WebSession  $Script:WHDConnection.WebSession
    }
}