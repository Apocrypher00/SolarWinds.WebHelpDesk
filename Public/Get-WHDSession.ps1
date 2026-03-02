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

        [Parameter(Mandatory, ParameterSetName = "ApiKey")]
        [string] $ApiKey,

        [Parameter(Mandatory, ParameterSetName = "Password")]
        [string] $Password
    )

    $Results = switch ($PSCmdlet.ParameterSetName) {
        "ApiKey" {
            Get-WHDResource `
                -Username  $Username `
                -ApiKey    $ApiKey `
                -Resource  ([WHDResourceType]::Session) `
                -Qualifier ""
        }
        "Password" {
            Get-WHDResource `
                -Username  $Username `
                -Password  $Password `
                -Resource  ([WHDResourceType]::Session) `
                -Qualifier ""
        }
    }

    return $Results
}
