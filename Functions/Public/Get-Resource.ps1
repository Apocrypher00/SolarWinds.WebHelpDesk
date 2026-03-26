<#
    .SYNOPSIS
    Query the WHD API via REST GET

    .DESCRIPTION
    This function is a general purpose function for querying the WHD API via REST GET.
    It is used by the more specific Get-* functions, but can also be used directly if you prefer control.

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
        [WHDCustomFieldType] $SubType,

        [Parameter()]
        [WHDTicketListType] $ListType,

        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier")]
        [WHDQualifier] $Qualifier,

        [Parameter(ParameterSetName = "QualifierString")]
        [string] $QualifierString,

        [Parameter()]
        [switch] $Expand
    )

    $SubTypeSpecified  = $PSBoundParameters.ContainsKey("SubType")
    $ListTypeSpecified = $PSBoundParameters.ContainsKey("ListType")

    # If a Qualifier object was provided, convert it to a string for use in the API call
    if ($null -ne $Qualifier) { $QualifierString = $Qualifier.ToString() }
    $QualifierSpecified = (-not [string]::IsNullOrEmpty($QualifierString))


    # Only allow SubType for CustomFieldDefinitions
    if ($SubTypeSpecified -and ($ResourceType -ne [WHDResourceType]::CustomFieldDefinitions)) {
        throw "SubType is only valid for the 'CustomFieldDefinitions' resource."
    }

    # Only allow ListType for Tickets
    if ($ListTypeSpecified -and ($ResourceType -ne [WHDResourceType]::Tickets)) {
        throw "ListType is only valid for the 'Tickets' resource."
    }

    # Require ListType when searching for Tickets without a Qualifier
    if (
        ($ResourceType -eq [WHDResourceType]::Tickets) -and `
        ($PSCmdlet.ParameterSetName -ne "Single") -and `
        (-not $QualifierSpecified) -and `
        (-not $ListTypeSpecified)
    ) {
        throw "ListType is required for the 'Tickets' resource when no Qualifier is specified."
    }

    Assert-Connection

    # Create a copy of the Module level UriBuilder
    # # TODO: Is there a better way to make a copy?
    $UriBuilder = [System.UriBuilder]::new($Script:WHDConnection.UriBuilder)

    # Create a copy of the Module level authentication parameters
    $QueryParams = Copy-Authentication

    # Build the Uri, ignore Ticket SubType as it isn't used in the URI
    $UriBuilder.Path += "/$ResourceType"

    if ($SubTypeSpecified -and ($SubType -ne [WHDCustomFieldType]::Ticket)) {
        $UriBuilder.Path += "/$SubType"
    }

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        $UriBuilder.Path += "/$ResourceId"
    }

    if (($ResourceType -eq [WHDResourceType]::Tickets) -and ($ListTypeSpecified)) {
        $QueryParams.Add("list", $ListType)
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
