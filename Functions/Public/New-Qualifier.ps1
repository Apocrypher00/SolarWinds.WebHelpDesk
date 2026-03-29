<#
    .SYNOPSIS
    Create a WHD API qualifier string.

    .DESCRIPTION
    This function helps build qualifiers that are syntactically correct and properly escaped.

    .PARAMETER Attribute
    The attribute name to filter on.

    .PARAMETER Operator
    The operator to use for the filter. This can be one of the following:
     - Equals: =
     - NotEquals: !=
     - LessThan: <
     - GreaterThan: >
     - LessThanOrEqual: <=
     - GreaterThanOrEqual: >=
     - Like: like (supports * as a wildcard)
     - CaseInsensitiveLike: caseInsensitiveLike (supports * as a wildcard)

    .PARAMETER Value
    The value to filter on.
    When using the Like or CaseInsensitiveLike operators, you can use * as a wildcard placeholder in the value.

    .EXAMPLE
    $Qualifier = New-Qualifier -Attribute "email" -Operator CaseInsensitiveLike -Value "*@example.com"

    .EXAMPLE
    $Qualifier = New-Qualifier "assetNumber" Equals "12345"

    .NOTES
    Snippet from the docs:

        Qualifier clauses are in the following format:
        (<attribute> <op> <value>)
        where:
        - <attribute> is the attribute name.
        - <op> is one of the following operations: =, !=, <, >, <=, >=, like, or caseInsensitiveLike.
        When like or caseInsensitiveLike is used, <value> may contain asterisks (*) as wildcard
        placeholders.
        - <value> is the attribute value. It could be a number, string, date, and so on. String and date
        values must be enclosed with single quotes (for example, 'some string value').
        Qualifier clauses can be joined and nested with the keywords and, or, and not. Additionally, left and
        right brackets - '(' and ')' - can be used to create more complex qualifiers.
        To reference nested attributes, use a period to join the components of the attribute path (for example,
        location.locationName).
        When providing the qualifier as a GET query parameter, remember to percent-encode it:
        https://en.wikipedia.org/wiki/Percent-encoding#Percent-encoding_reserved_characters
#>
function New-Qualifier {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Attribute,

        [Parameter(Mandatory, Position = 1)]
        [WHDQualifierOperator] $Operator,

        [Parameter(Mandatory, Position = 2)]
        [psobject] $Value,

        [Parameter()]
        [switch] $Negate
    )

    $Qualifier = [WHDClauseQualifier]::new($Attribute, $Operator, $Value)

    # FIXME: Let's add an option that only negates the passed qualifier
    # FIXME: Maybe we should have another constructor with negate built-in?
    if ($Negate) { $Qualifier.Negate = $true }

    return $Qualifier
}