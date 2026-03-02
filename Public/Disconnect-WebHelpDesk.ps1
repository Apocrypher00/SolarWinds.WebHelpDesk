<#
    .SYNOPSIS
    Disconnect from Web Help Desk and clear session state.
#>
function Disconnect-WebHelpDesk {
    [CmdletBinding(SupportsShouldProcess)] param ()
    #
    Remove-WHDSession

    #
    # $Script:WHDConnection.BaseUrl = $null
    # $Script:WHDConnection.Session = $null
    # $Script:WHDConnection.WebSession = $null
}