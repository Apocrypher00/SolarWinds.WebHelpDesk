<#
    .SYNOPSIS
    Build a WHDQualifier from bound parameters and an attribute map.

    .DESCRIPTION
    This function converts matching bound parameters into clause qualifiers and joins them with AND.
    If no mapped parameters are present, it returns $null.
#>
function ConvertTo-Qualifier {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable] $BoundParameters,

        [Parameter(Mandatory)]
        [hashtable] $AttributeMap
    )

    $Qualifiers = foreach ($Param in $BoundParameters.Keys) {
        if ($AttributeMap.ContainsKey($Param)) {
            New-Qualifier `
                -Attribute $AttributeMap[$Param] `
                -Operator  ([WHDQualifierOperator]::Equals) `
                -Value     $BoundParameters[$Param]
        }
    }

    if ($Qualifiers.Count -eq 0) {
        return $null
    }

    $Qualifier = Join-Qualifier `
        -Qualifiers   $Qualifiers `
        -JoinOperator ([WHDQualifierLogicalOperator]::AND)

    return $Qualifier
}