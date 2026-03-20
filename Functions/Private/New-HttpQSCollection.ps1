<#
.SYNOPSIS
    Creates a new empty HttpQSCollection object.
#>
function New-HttpQSCollection {
    [CmdletBinding()] param ()

    # The leading comma prevents unwrapping the collection when returned
    return ,[System.Web.HttpUtility]::ParseQueryString([string]::Empty)
}