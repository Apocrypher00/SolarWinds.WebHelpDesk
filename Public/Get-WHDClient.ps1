<#
    .SYNOPSIS
    Get a WHD Client by their email address.
#>
function Get-WHDClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Email,

        [Parameter()]
        [switch] $Expand
    )

    $Qualifier = New-WHDQualifier `
        -Attribute "email" `
        -Operator  ([WHDQualifierOperator]::CaseInsensitiveLike) `
        -Value     $Email

    # Search for the Client by Email to get the ID
    $Results = Get-WHDResource `
        -ResourceType ([WHDResourceType]::Clients) `
        -Qualifier    $Qualifier `
        -Expand:$Expand

    return $Results
}