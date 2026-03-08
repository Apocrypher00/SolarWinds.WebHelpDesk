<#
    .SYNOPSIS
    Get a session from WHD.

    .DESCRIPTION
    This function retrieves a session key from WHD based on the provided credentials.
#>
function Get-WHDSession {
    [CmdletBinding()] param ()

    $Results = Get-WHDResource -ResourceType ([WHDResourceType]::Session)

    return $Results
}
