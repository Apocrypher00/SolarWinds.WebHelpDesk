<#
    .SYNOPSIS
    Get a session from WHD.

    .DESCRIPTION
    This function retrieves a session key from WHD based on the provided credentials.
#>
function Get-WHDSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Username,

        [Parameter(ParameterSetName = "ApiKey", Mandatory)]
        [string] $ApiKey,

        [Parameter(ParameterSetName = "Password", Mandatory)]
        [string] $Password
    )

    $Results = switch ($PSCmdlet.ParameterSetName) {
        "ApiKey" {
            Get-WHDResource `
                -Username  $Username `
                -ApiKey    $ApiKey `
                -ResourceType  ([WHDResourceType]::Session) `
                -Qualifier ""
        }
        "Password" {
            Get-WHDResource `
                -Username  $Username `
                -Password  $Password `
                -ResourceType  ([WHDResourceType]::Session) `
                -Qualifier ""
        }
    }

    return $Results
}
