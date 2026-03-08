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
        [string] $Qualifier = "",

        [Parameter()]
        [switch] $Expand
    )

    # Only allow SubType for CustomFieldDefinitions
    if ($SubType -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "SubType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # Start building the query parameters with our authentication; this is required for all requests
    # FIXME: This is a little messy, we can do better.
    $QueryParameters = @{}
    if ($Script:WHDConnection.Session) {
        $QueryParameters["sessionKey"] = $Script:WHDConnection.Session.sessionKey
    } elseif ($Script:WHDConnection.Authentication.apiKey) {
        $QueryParameters["apiKey"]  = $Script:WHDConnection.Authentication.apiKey

        if ($Script:WHDConnection.Authentication.username) {
            $QueryParameters["username"] = $Script:WHDConnection.Authentication.username
        }
    } else {
        throw "No authentication method available. Please connect to Web Help Desk first using Connect-WebHelpDesk."
    }

    # Add qualifier if we are using Search mode
    if ($PSCmdlet.ParameterSetName -eq "Search") { $QueryParameters["qualifier"] = $Qualifier }

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    # TODO: there must be a cleaner way to construct this string.
    $Uri = "$($Script:WHDConnection.BaseUrl)/$ResourceType"
    if (($null -ne $SubType) -and ($SubType -ne [WHDCustomFieldType]::Ticket)) { $Uri += "/$SubType" }
    if ($PSCmdlet.ParameterSetName -eq "Single") { $Uri += "/$ResourceId" }

    # Send the query
    $Results = Invoke-RestMethod `
        -Uri         $Uri `
        -Method      ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) `
        -ContentType "application/json" `
        -Body        $QueryParameters `
        -WebSession  $Script:WHDConnection.WebSession

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
