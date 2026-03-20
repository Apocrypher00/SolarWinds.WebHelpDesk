<#
.SYNOPSIS
    Creates a new empty HttpQSCollection object.
#>
function New-HttpQSCollection {
    [CmdletBinding()] param ()

    return [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
}