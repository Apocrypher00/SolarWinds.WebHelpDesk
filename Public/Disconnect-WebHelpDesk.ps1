<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear session state.

    .NOTES
    FIXME: This is a w.i.p.
#>
function Disconnect-WebHelpDesk {
    [CmdletBinding()] param ()

    # Remove the actual sesson from WHD
    Remove-WHDSession -Session $Script:WHDConnection.Session -Confirm:$false

    #Remove the session from our state
    # $Script:WHDConnection.BaseUrl = $null
    # $Script:WHDConnection.Session = $null
    # $Script:WHDConnection.WebSession = $null
}