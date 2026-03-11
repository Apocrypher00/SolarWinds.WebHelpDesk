<#
    .SYNOPSIS
    Query the WHD API via REST GET

    .NOTES
    Qualifiers are case sensitive.
    Not all Resources support qualifiers. Use the more specific functions when possible.
#>
function Get-WHDResource {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [WHDCustomFieldType] $SubType,

        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Search")]
        [string] $Qualifier = [string]::Empty,

        [Parameter()]
        [switch] $Expand
    )

    # Only allow SubType for CustomFieldDefinitions
    if ($SubType -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "SubType is only valid for the 'CustomFieldDefinitions' resource."
    }

    Assert-WHDConnection

    # Create a copy of the Module level UriBuilder
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Add the authentication parameters to the query string; this is required for all requests
    $UriBuilder.Query = $Script:WHDConnection.AuthParams.ToString()

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    $UriBuilder.Path += "/$ResourceType"

    if (($null -ne $SubType) -and ($SubType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$SubType"
    }

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        $UriBuilder.Path += "/$ResourceId"
    }

    # Parameters for Invoke-RestMethod
    $ParameterHash = @{
        Uri         = $UriBuilder.ToString()
        Method      = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        ContentType = "application/json"
        WebSession  = $Script:WHDConnection.WebSession
    }

    # Add qualifier to the body if we are using Search mode
    if ($PSCmdlet.ParameterSetName -eq "Search") {
        $ParameterHash["Body"] = @{
            qualifier = $Qualifier
        }
    }

    # Send the query
    $Results = Invoke-RestMethod @ParameterHash

    # If we got a result, modify it with some additional properties and types to make it easier to work with
    if ($null -ne $Results) {
        # Modify the resulting objects with a custom type
        $Results | Set-WHDTypeName -ResourceType $ResourceType

        # Add a type field with the types we use
        $Results | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ResourceType" `
            -Value      $ResourceType `
            -Force

        # Expand if requested, but if this is a single resource query, it's already expanded
        if ($Expand -and ($PSCmdlet.ParameterSetName -ne "Single")) { $Results = $Results | Expand-WHDResource }
    }

    return $Results
}
