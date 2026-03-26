<#
    .SYNOPSIS
    Query the WHD API via REST GET

    .DESCRIPTION
    This function is a general purpose function for querying the WHD API via REST GET.
    It is used by the more specific Get-* functions, but can also be used directly if you prefer control.

    .PARAMETER ResourceType
    The type of resource to query, e.g. Assets, Clients, Manufacturers, etc.
    Restricted by the [WHDResourceType] enum.

    .PARAMETER CustomFieldType
    The subtype of CustomFieldDefinition to query, e.g. Asset, Location, or Ticket.
    Restricted by the [WHDCustomFieldType] enum.

    .PARAMETER ResourceId
    The resource ID of the resource to retrieve.
    If specified, only a single resource will be returned.

    .PARAMETER Qualifier
    A WHD API qualifier string to filter the results.
    You can use New-Qualifier and Join-Qualifier to build these strings, or
        you can write them manually if you prefer.
    If not specified, all resources of the specified type will be returned.
    Qualifiers are case sensitive and support is dependant on the ResourceType.
    Full support: Assets, AssetTypes, Companies, Locations,
        Manufacturers, Models, Tickets (limited support when the list parameter is used).
    Limited support: Clients (predefined qualified is already used).

    .PARAMETER Expand
    If specified, the function will expand the resource details to include additional information.
#>
function Get-Resource {
    [CmdletBinding(DefaultParameterSetName = "Qualifier")]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [WHDCustomFieldType] $CustomFieldType,

        [Parameter()]
        [WHDTicketListType] $TicketListType,

        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
        [string] $QualifierString,

        [Parameter()]
        [switch] $Expand
    )

    $CustomFieldTypeSpecified  = $PSBoundParameters.ContainsKey("CustomFieldType")
    $TicketListTypeSpecified = $PSBoundParameters.ContainsKey("TicketListType")

    # If a Qualifier object was provided, convert it to a string for use in the API call
    if ($null -ne $Qualifier) { $QualifierString = $Qualifier.ToString() }
    $QualifierSpecified = (-not [string]::IsNullOrEmpty($QualifierString))


    # Only allow CustomFieldType for CustomFieldDefinitions
    if ($CustomFieldTypeSpecified -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "CustomFieldType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # Only allow TicketListType for Tickets
    if ($TicketListTypeSpecified -and ($ResourceType -ne [WHDResourceType]::Tickets)) {
        throw "TicketListType is only valid for the 'Tickets' resource."
    }

    # Require TicketListType when searching for Tickets without a Qualifier
    if (
        ($ResourceType -eq [WHDResourceType]::Tickets) -and `
        ($PSCmdlet.ParameterSetName -ne "Single") -and `
        (-not $QualifierSpecified) -and `
        (-not $TicketListTypeSpecified)
    ) {
        throw "TicketListType is required for the 'Tickets' resource when no Qualifier is specified."
    }

    Assert-Connection

    # Create a copy of the Module level UriBuilder
    # # TODO: Is there a better way to make a copy?
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Create a copy of the Module level authentication parameters
    $QueryParams = Copy-Authentication

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    $UriBuilder.Path += "/$ResourceType"

    if ($CustomFieldTypeSpecified -and ($CustomFieldType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$CustomFieldType"
    }

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        $UriBuilder.Path += "/$ResourceId"
    }

    if (($ResourceType -eq [WHDResourceType]::Tickets) -and ($TicketListTypeSpecified)) {
        $QueryParams.Add("list", $TicketListType)
    }

    # Choose to retrieve detailed objects or short objects based on the Expand switch
    <#
        TODO: This deserves a bit more attention.
        The API guide says that if style=short or not provided, it returns short objects.
        If ANY OTHER style is provided, it returns long objects, but the guide uses style=details.
        The guide also specifies which ResourceTypes support the style parameter.
    #>
    if ($Expand) {
        # $QueryParams.Add("style", "details")
        $QueryParams.Add("style", "long")
    } else {
        # $QueryParams.Add("style", "short")
    }

    # Add the query parameters to the UriBuilder, this will handle encoding and formatting for us
    $UriBuilder.Query = $QueryParams.ToString()

    # Parameters for Invoke-RestMethod
    $ParameterHash = @{
        Uri         = $UriBuilder.ToString()
        Method      = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        ContentType = "application/json"
        WebSession  = $Script:WHDConnection.WebSession
    }

    if ($QualifierSpecified) {
        $ParameterHash["Body"] = @{ qualifier = $QualifierString }
    }

    # Send the query
    $Results = Invoke-RestMethod @ParameterHash

    # If we got any results, modify them with some additional properties and types to make them easier to work with
    if ($null -ne $Results) {
        # Modify the resulting objects with a custom type
        $Results | Set-TypeName -ResourceType $ResourceType

        # Add a type field with the types we use
        $Results | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ResourceType" `
            -Value      $ResourceType `
            -Force

    }

    return $Results
}
