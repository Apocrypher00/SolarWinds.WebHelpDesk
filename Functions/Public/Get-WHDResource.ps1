<#
    .SYNOPSIS
    Retrieve Resources from the WHD API.

    .DESCRIPTION
    This function retrieves Resources from the WHD API. It can be used directly for advanced queries,
    or indirectly through the more specific Get-* functions (Get-WHDAsset, Get-WHDTicket, etc.).

    .PARAMETER ResourceType
    The type of Resource to retrieve (Asset, Client, Manufacturer, Tickets, etc.).

    .PARAMETER CustomFieldType
    The subtype of CustomFieldDefinition to query, e.g. Asset, Location, or Ticket.
    Restricted by the [WHDCustomFieldType] enum.

    .PARAMETER ResourceId
    The id of a specific Resource to retrieve.
    For Clients, this can also be a username or email address.
    When specified, only that single Resource will be returned.

    .PARAMETER Qualifier
    A WHDQualifier object to filter the results.
    Use New-WHDQualifier and Join-WHDQualifier to build these objects.

    .PARAMETER QualifierString
    A WHD API qualifier string to filter the results.
    This is an alternative to using the Qualifier parameter if you prefer to build the qualifier string manually.
    Qualifiers are case sensitive and support is dependant on the ResourceType.
    Full support: Asset, AssetType, Company, Location,
        Manufacturer, Model, Tickets (limited support when the list parameter is used).
    Limited support: Client (predefined Qualifier is already applied).

    .PARAMETER Expand
    Requests the detailed representation for supported ResourceTypes.
    Asset, Location, TicketNote, and Tickets support this only for list requests.
    Model supports it for both list and single requests.

    .NOTES
    If no ResourceId or Qualifier/QualifierString is provided, all resources of the specified type will be returned.
    List responses are automatically paged until all matching resources have been retrieved.
#>
function Get-WHDResource {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [WHDTicketListType] $TicketListType,

        [Parameter()]
        [WHDCustomFieldType] $CustomFieldType,

        [Parameter(ParameterSetName = "Single", Mandatory, Position = 1)]
        [string] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
        [string] $QualifierString,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [switch] $Expand
    )

    $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get

    Assert-Connection
    Assert-SupportsMethod -ResourceType $ResourceType -Method $Method

    # Only allow TicketListType for Tickets
    $TicketListTypeSpecified = $PSBoundParameters.ContainsKey("TicketListType")
    if ($TicketListTypeSpecified -and ($ResourceType -ne [WHDResourceType]::Tickets)) {
        throw "TicketListType is only valid for the 'Tickets' resource."
    }

    # Only allow CustomFieldType for CustomFieldDefinition
    $CustomFieldTypeSpecified = $PSBoundParameters.ContainsKey("CustomFieldType")
    if ($CustomFieldTypeSpecified -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinition)) {
        throw "CustomFieldType is only valid for the 'CustomFieldDefinition' resource."
    }

    # If a Qualifier object was provided, convert it to a string for use in the API call
    if ($null -ne $Qualifier) { $QualifierString = $Qualifier.ToString() }
    $QualifierSpecified = (-not [string]::IsNullOrEmpty($QualifierString))

    # Create a copy of the Module level UriBuilder
    # FIXME: We should minimize direct references to module-level state
    $UriBuilder = Copy-UriBuilder -UriBuilder $Script:WHDConnection.UriBuilder

    # Create an empty collection for resource-specific query parameters
    $QueryParams = New-HttpQSCollection

    # Add the ResourceType to the UriBuilder path to build the endpoint URI
    $UriBuilder.Path += "/$ResourceType"

    # Tickets have a second-level endpoint for the TicketListType.
    if ($TicketListTypeSpecified) {
        $UriBuilder.Path += "/$TicketListType"
    }

    # CustomFieldDefinition has a second-level endpoint for the CustomFieldType, except for the Ticket sub-type.
    if ($CustomFieldTypeSpecified -and ($CustomFieldType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$CustomFieldType"
    }

    # If a ResourceId was provided, add it to the UriBuilder path to target that specific resource.
    # Some ResourceTypes don't support retrieval by id, so throw an error if that's the case.
    if ($PSCmdlet.ParameterSetName -eq "Single") {
        if ($ResourceType -in @(
                [WHDResourceType]::CustomFieldDefinition
                [WHDResourceType]::Session
            )
        ) {
            throw "The '$ResourceType' ResourceType doesn't support retrieval by id."
        } else {
            $UriBuilder.Path += "/$ResourceId"
        }
    }

    # If any additional parameters were provided, add them to the query parameters
    if ($AdditionalParameters) {
        foreach ($Key in $AdditionalParameters.Keys) {
            $QueryParams.Add($Key, $AdditionalParameters[$Key])
        }
    }

    $SingleResource = ($PSCmdlet.ParameterSetName -eq "Single")

    if ($Expand) {
        Assert-SupportsExpand -ResourceType $ResourceType -Single:$SingleResource
        $QueryParams.Add("style", "detailed")
    }

    $ReturnsPagedResults = Test-ReturnsPagedResults -ResourceType $ResourceType -Single:$SingleResource

    # Parameters for Invoke-WHDMethod
    $ParameterHash = @{
        UriBuilder      = $UriBuilder
        Method          = $Method
        QueryParameters = $QueryParams
    }

    # If a qualifier was specified, add it to the body of the request as JSON.
    if ($QualifierSpecified) {
        $ParameterHash["Body"] = @{ qualifier = $QualifierString }
    }

    # Send the query to the API and store the results
    # ticketAttachment returns application/octet-stream binary data, not JSON.
    # Use Invoke-WebRequest, but continue through the shared type augmentation below.
    if ($ResourceType -eq [WHDResourceType]::ticketAttachment) {
        $Results = [PSCustomObject]@{
            Id       = $ResourceId
            Response = (Invoke-WHDMethod @ParameterHash -AsWebResponse)
        }
    } elseif ($ReturnsPagedResults) {
        $Results = Invoke-WHDPagedRequest `
            -UriBuilder      $UriBuilder `
            -QueryParameters $QueryParams `
            -ResourceType    $ResourceType `
            -Body            $ParameterHash["Body"]
    } else {
        $Results = Invoke-WHDMethod @ParameterHash
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
