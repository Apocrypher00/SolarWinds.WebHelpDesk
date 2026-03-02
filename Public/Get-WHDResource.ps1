<#
    .SYNOPSIS
    Query the WHD API via REST GET

    .NOTES
    Qualifiers are case sensitive.
    Not all Resources support qualifiers. Use the more specific functions when possible.
#>
function Get-WHDResource {
    [CmdletBinding(DefaultParameterSetName = "SessionSearch")]
    param (
        # credential sets: provide either username+password, username+apiKey,
        # or nothing and rely on the saved sessionKey.  Each pair is combined
        # with a "Single" or "Search" suffix to keep ResourceId/Qualifier
        # mutually exclusive.
        [Parameter(ParameterSetName = "PasswordSingle", Mandatory)]
        [Parameter(ParameterSetName = "PasswordSearch", Mandatory)]
        [Parameter(ParameterSetName = "ApiKeySingle", Mandatory)]
        [Parameter(ParameterSetName = "ApiKeySearch", Mandatory)]
        [string] $Username,

        [Parameter(ParameterSetName = "ApiKeySingle", Mandatory)]
        [Parameter(ParameterSetName = "ApiKeySearch", Mandatory)]
        [string] $ApiKey,

        [Parameter(ParameterSetName = "PasswordSingle", Mandatory)]
        [Parameter(ParameterSetName = "PasswordSearch", Mandatory)]
        [string] $Password,

        # always required
        [Parameter(Mandatory)]
        [WHDResourceType] $Resource,

        [Parameter()]
        [WHDCustomFieldType] $SubType,

        [Parameter()]
        [switch] $Expand,

        # mutually exclusive selectors
        [Parameter(ParameterSetName = "PasswordSingle")]
        [Parameter(ParameterSetName = "ApiKeySingle")]
        [Parameter(ParameterSetName = "SessionSingle")]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "PasswordSearch")]
        [Parameter(ParameterSetName = "ApiKeySearch")]
        [Parameter(ParameterSetName = "SessionSearch")]
        [string] $Qualifier
    )

    # Only allow SubType for CustomFieldDefinitions
    if ($SubType -and ($Resource -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "SubType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # verify a saved session exists when we're not passing credentials
    if ($PSCmdlet.ParameterSetName -like "Session*" -and -not $Script:WHDConnection.Session) {
        throw "No active session. Please connect to Web Help Desk first using Connect-WebHelpDesk."
    }

    # Base Parameters
    $QueryParameters = @{}
    if ($PSCmdlet.ParameterSetName -like "ApiKey*") {
        $QueryParameters["apiKey"]  = $ApiKey
        $QueryParameters["username"] = $Username
    }
    elseif ($PSCmdlet.ParameterSetName -like "Password*") {
        $QueryParameters["username"] = $Username
        $QueryParameters["password"] = $Password
    }
    else {
        $QueryParameters["sessionKey"] = $Script:WHDConnection.Session.sessionKey
    }

    # Add qualifier if we are using Search mode
    if ($PSCmdlet.ParameterSetName -like "*Search") { $QueryParameters["qualifier"] = $Qualifier }

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    # TODO: there must be a cleaner way to construct this string.
    $Uri = "$($Script:WHDConnection.BaseUrl)/$Resource"
    if (($null -ne $SubType) -and ($SubType -ne [WHDCustomFieldType]::Ticket)) { $Uri += "/$SubType" }
    if ($PSCmdlet.ParameterSetName -like "*Single") { $Uri += "/$ResourceId" }

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
        $Results | Set-WHDTypeName -ResourceType $Resource

        # Add a type field with the types we use
        $Results | Add-Member -MemberType NoteProperty -Name "ResourceType" -Value $Resource -Force

        # Expand if requested
        if ($Expand) { $Results = $Results | Expand-WHDResource }
    }

    return $Results
}
