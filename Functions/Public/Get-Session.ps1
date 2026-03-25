<#
    .SYNOPSIS
    Get a session from WHD.

    .DESCRIPTION
    This function retrieves a session key from WHD based on the stored credentials.

    .NOTES
    This is typically used internally by Connect-WebHelpDesk, but
    can be used directly if you want to manage session keys yourself.
    You can't get new sessions if using session-based authentication.
    WARNING: Sessions expire after 30 minutes and can't be queried after creation, so use with caution!
#>
function Get-Session {
    [CmdletBinding()] param ()

    if ($Script:WHDConnection.Session) {
        throw "You are using session-based authentication, which only allows one active session at a time."
    }

    $Session = Get-Resource -ResourceType ([WHDResourceType]::Session)

    if ($Session.Count -ne 0) {
        $Session | Add-Member `
            -MemberType ([System.Management.Automation.PSMemberTypes]::NoteProperty) `
            -Name       "ExpirationDate" `
            -Value      ([DateTime]::Now.AddMinutes(30)) `
            -Force
    }

    return $Session
}
