<#
    .SYNOPSIS
    Remove a resource from WHD via the API.

    .DESCRIPTION
    This function deletes a resource from WHD based on the resource type and ID.
    Sessions and Tokens are removed without a resource ID.
#>
function Remove-WHDResource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName("SolarWinds.WebHelpDesk.Resource")] $Resource
    )

    process {
        Assert-Connection

        $ResourceType = $Resource.ResourceType
        Assert-SupportsMethod -ResourceType $ResourceType -Method Delete

        # Create a copy of the Module level UriBuilder
        # FIXME: We should minimize direct references to module-level state
        $UriBuilder = Copy-UriBuilder -UriBuilder $Script:WHDConnection.UriBuilder

        # Add the ResourceType to the path
        $UriBuilder.Path += "/$ResourceType"

        $QueryParams = New-HttpQSCollection
        $NoAuthentication = $false

        # Add the ResourceId to the path; Sessions and Tokens are exceptions
        if ($ResourceType -eq [WHDResourceType]::Session) {
            $QueryParams.Add("sessionKey", $Resource.sessionKey)
            $NoAuthentication = $true
            $ShouldProcessMessage = "ResourceType=$ResourceType"
        } elseif ($ResourceType -eq [WHDResourceType]::Token) {
            $ShouldProcessMessage = "ResourceType=$ResourceType"
        } else {
            $UriBuilder.Path += "/$($Resource.id)"
            $ShouldProcessMessage = "ResourceType=$ResourceType, ResourceId=$($Resource.id)"
        }

        # Build the parameter hash for Invoke-WHDMethod
        $ParameterHash = @{
            UriBuilder       = $UriBuilder
            Method           = [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
            QueryParameters  = $QueryParams
            NoAuthentication = $NoAuthentication
        }

        # Send the request and return the result
        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage, "Remove Resource from Web Help Desk")) {
            return Invoke-WHDMethod @ParameterHash
        }
    }
}
