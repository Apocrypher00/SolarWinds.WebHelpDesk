<#
    .SYNOPSIS
    Create a bearer Token for the Web Help Desk API.

    .DESCRIPTION
    This function creates a bearer Token using the credentials retained by the current connection.
    Connect with AuthenticationMode Direct before calling this function.
    The returned accessToken is sensitive and isn't included in the default display.
#>
function New-WHDToken {
    [CmdletBinding()]
    param ()

    $Token = New-WHDResource -ResourceType ([WHDResourceType]::Token)

    if ($null -ne $Token) {
        $Token | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ExpirationDate" `
            -Value      ([DateTimeOffset]::UtcNow.AddSeconds($Token.expiresIn)) `
            -Force
    }

    return $Token
}
