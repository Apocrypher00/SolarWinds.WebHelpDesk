<#
    .SYNOPSIS
    Query the WHD API via REST GET

    .DESCRIPTION
    This function is a general purpose function for querying the WHD API via REST GET.
    It is used by the more specific Get-WHD* functions, but can also be used directly if you prefer control.

    .PARAMETER ResourceType
    The type of resource to query, e.g. Assets, Clients, Manufacturers, etc.
    Restricted by the [WHDResourceType] enum.

    .PARAMETER SubType
    The subtype of resource to query, used for CustomFieldDefinitions.
    Restricted by the [WHDCustomFieldType] enum.

    .PARAMETER ResourceId
    The resource ID of the resource to retrieve.
    If specified, only a single resource will be returned.

    .PARAMETER Qualifier
    A WHD API qualifier string to filter the results.
    You can use New-WHDQualifier and Join-WHDQualifier to build these strings, or
        you can write them manually if you prefer.
    If not specified, all resources of the specified type will be returned.
    Qualifiers are case sensitive and support is dependant on the ResourceType.
    Full support: Assets, AssetTypes, Companies, Locations,
        Manufacturers, Models, Tickets (limited support when the list parameter is used).
    Limited support: Clients (predefined qualified is already used).

    .PARAMETER Expand
    If specified, the function will expand the resource details to include additional information.
#>
function Get-WHDResource {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [WHDCustomFieldType] $SubType,

        [Parameter()]
        [WHDTicketListType] $ListType,

        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Search")]
        [string] $Qualifier = [string]::Empty,

        [Parameter()]
        [switch] $Expand
    )

    $SubTypeSpecified  = $PSBoundParameters.ContainsKey("SubType")
    $ListTypeSpecified = $PSBoundParameters.ContainsKey("ListType")

    # Only allow SubType for CustomFieldDefinitions
    if ($SubTypeSpecified -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "SubType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # Only allow ListType for Tickets
    if ($ListTypeSpecified -and ($ResourceType -ne [WHDResourceType]::Tickets)) {
        throw "ListType is only valid for the 'Tickets' resource."
    }

    # Require ListType when querying Tickets without a qualifier
    if (($ResourceType -eq [WHDResourceType]::Tickets) -and (-not $Qualifier) -and (-not $ListTypeSpecified)) {
        throw "ListType is required for the 'Tickets' resource when no Qualifier is specified."
    }

    Assert-WHDConnection

    # Create a copy of the Module level UriBuilder
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Add the authentication parameters to the query string; this is required for all requests
    $UriBuilder.Query = $Script:WHDConnection.AuthParams.ToString()

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    $UriBuilder.Path += "/$ResourceType"

    if ($SubTypeSpecified -and ($SubType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$SubType"
    }

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        $UriBuilder.Path += "/$ResourceId"
    }

    if (($ResourceType -eq [WHDResourceType]::Tickets) -and ($ListTypeSpecified)) {
        $UriBuilder.Query += "&list=$ListType"
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

    # If we got any results, modify them with some additional properties and types to make them easier to work with
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
