<#
    .SYNOPSIS
    Create a resource in WHD via the API.

    .DESCRIPTION
    This function creates a Resource in WHD using a JSON request body.
    It can be used directly, or indirectly through the more specific New-* functions.

    .PARAMETER ResourceType
    The type of Resource to create.

    .PARAMETER Body
    The properties to send in the JSON request body.

    .PARAMETER AdditionalParameters
    Additional query parameters to include with the request.
#>
function New-WHDResource {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [WHDResourceType] $ResourceType,

        [Parameter(Mandatory, Position = 1)]
        [hashtable] $Body,

        [Parameter()]
        [hashtable] $AdditionalParameters
    )

    Assert-Connection
    Assert-SupportsMethod -ResourceType $ResourceType -Method Post

    # Create a copy of the Module level UriBuilder
    # FIXME: We should minimize direct references to module-level state
    $UriBuilder = Copy-UriBuilder -UriBuilder $Script:WHDConnection.UriBuilder
    $UriBuilder.Path += "/$ResourceType"

    # Token credentials are sent in the JSON body rather than as authentication query parameters.
    if ($ResourceType -eq [WHDResourceType]::Token) {
        $QueryParams = New-HttpQSCollection
    } else {
        $QueryParams = Copy-Authentication
    }

    if ($AdditionalParameters) {
        foreach ($Key in $AdditionalParameters.Keys) {
            $QueryParams.Add($Key, $AdditionalParameters[$Key])
        }
    }

    $UriBuilder.Query = $QueryParams.ToString()

    $ParameterHash = @{
        UriBuilder = $UriBuilder
        Method     = [Microsoft.PowerShell.Commands.WebRequestMethod]::Post
        Body       = $Body
    }

    if ($PSCmdlet.ShouldProcess("ResourceType=$ResourceType", "Create Resource in Web Help Desk")) {
        $Result = Invoke-WHDMethod @ParameterHash
    }

    if ($null -ne $Result) {
        $Result | Add-TypeName -ResourceType $ResourceType | Out-Null
        $Result | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ResourceType" `
            -Value      $ResourceType `
            -Force
    }

    return $Result
}
