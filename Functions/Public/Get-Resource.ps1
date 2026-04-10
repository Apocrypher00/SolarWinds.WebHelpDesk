<#
    .SYNOPSIS
    Retrieve Resources from the WHD API.

    .DESCRIPTION
    This function retrieves Resources from the WHD API. It can be used directly for advanced queries,
    or indirectly through the more specific Get-* functions (Get-Asset, Get-Ticket, etc.).

    .PARAMETER ResourceType
    The type of Resource to retrieve (Assets, Clients, Manufacturers, Tickets, etc.).

    .PARAMETER CustomFieldType
    The subtype of CustomFieldDefinition to query, e.g. Asset, Location, or Ticket.
    Restricted by the [WHDCustomFieldType] enum.

    .PARAMETER ResourceId
    The id of a specific Resource to retrieve.
    When specified, only that single Resource will be returned.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-Qualifier and Join-Qualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.
    Qualifiers are case sensitive and support is dependant on the ResourceType.
    Full support: Assets, AssetTypes, Companies, Locations,
        Manufacturers, Models, Tickets (limited support when the list parameter is used).
    Limited support: Clients (predefined Qualifier is already applied).

    .PARAMETER Expand
    If specified, all results will be in the detailed format.

    .NOTES
    If no ResourceId or Qualifier/QualifierString is provided, all resources of the specified type will be returned.
#>
function Get-Resource {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [WHDCustomFieldType] $CustomFieldType,

        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
        [string] $QualifierString,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [switch] $Expand
    )

    Assert-Connection

    # The API guide doesn't indicate whether these can/can't be fetched
    # But it explicitly states that others can be, so we'll assume these can't
    if ($ResourceType -in @(
            [WHDResourceType]::Email
            [WHDResourceType]::TechNotes
        )
    ) {
        throw "The '$($ResourceType)' ResourceType doesn't support GET."
    }

    # Only allow CustomFieldType for CustomFieldDefinitions
    $CustomFieldTypeSpecified = $PSBoundParameters.ContainsKey("CustomFieldType")
    if ($CustomFieldTypeSpecified -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "CustomFieldType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # If a Qualifier object was provided, convert it to a string for use in the API call
    if ($null -ne $Qualifier) { $QualifierString = $Qualifier.ToString() }
    $QualifierSpecified = (-not [string]::IsNullOrEmpty($QualifierString))

    # Create a copy of the Module level UriBuilder
    # # TODO: Is there a better way to make a copy?
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Create a copy of the Module level authentication parameters
    $QueryParams = Copy-Authentication

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    $UriBuilder.Path += "/$ResourceType"

    # CustomFieldDefinitions have a second-level endpoint for the CustomFieldType, except for the Ticket type.
    if ($CustomFieldTypeSpecified -and ($CustomFieldType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$CustomFieldType"
    }

    if ($PSCmdlet.ParameterSetName -eq "Single" -and `
        ($ResourceType -notin @(
                [WHDResourceType]::CustomFieldDefinitions
                [WHDResourceType]::Session
                [WHDResourceType]::TicketNotes
            )
        )
    ) {
        $UriBuilder.Path += "/$ResourceId"
    }

    if ($AdditionalParameters) {
        foreach ($Key in $AdditionalParameters.Keys) {
            $QueryParams.Add($Key, $AdditionalParameters[$Key])
        }
    }

    # Omit style unless Expand is requested; the API defaults to short.
    if ($Expand) { $QueryParams.Add("style", "details") }

    # Add the query parameters to the UriBuilder, this will handle encoding and formatting for us
    $UriBuilder.Query = $QueryParams.ToString()

    # Parameters for Invoke-Method
    $ParameterHash = @{
        UriBuilder = $UriBuilder
        Method     = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
    }

    if ($QualifierSpecified) {
        $ParameterHash["Body"] = @{ qualifier = $QualifierString }
    }

    # Send the query to the API and store the results
    # TicketAttachments returns application/octet-stream binary data, not JSON.
    # Use Invoke-WebRequest, but continue through the shared type augmentation below.
    if ($ResourceType -eq [WHDResourceType]::TicketAttachments) {
        $Results = [PSCustomObject]@{
            Id       = $ResourceId
            Response = (Invoke-Method @ParameterHash -AsWebResponse)
        }
    } else {
        $Results = Invoke-Method @ParameterHash
    }

    # If we got any results, modify them with some additional properties and types to make them easier to work with
    if ($null -ne $Results) {
        # Modify the resulting objects with a custom type
        $Results | Add-TypeName -ResourceType $ResourceType | Out-Null

        # Add a type field with the types we use
        $Results | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ResourceType" `
            -Value      $ResourceType `
            -Force
    }

    return $Results
}
