<#
    .SYNOPSIS
    Create a Session in WHD.

    .DESCRIPTION
    This function creates a session key in WHD using the stored API-key credentials.

    .NOTES
    This is typically used internally by Connect-WebHelpDesk, but
    can be used directly if you want to manage session keys yourself.
    You can't create new sessions if using session-based authentication.
    WARNING: Sessions expire after 30 minutes and can't be queried after creation, so use with caution!
#>
function New-WHDSession {
    [CmdletBinding()] param ()

    if ($Script:WHDConnection.Session) {
        throw "You are using session-based authentication, which only allows one active session at a time."
    }

    $Authentication = Get-AuthenticationParameters
    if ([string]::IsNullOrWhiteSpace($Authentication["apiKey"])) {
        throw "Creating a Session requires an API key. Reconnect using Connect-WebHelpDesk -AuthenticationMode Direct."
    }

    $Session = Get-WHDResource -ResourceType ([WHDResourceType]::Session)

    if ($Session.Count -ne 0) {
        $Session | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ExpirationDate" `
            -Value      ([DateTime]::Now.AddMinutes(30)) `
            -Force
    }

    return $Session
}
