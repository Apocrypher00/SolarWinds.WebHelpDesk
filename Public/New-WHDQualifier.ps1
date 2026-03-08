<#
    .SYNOPSIS


    .DESCRIPTION
    We will use this to build qualifiers that are syntactically correct and properly escaped.

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
        - When using the Like or CaseInsensitiveLike operators, you can use * as a wildcard placeholder in the value.
        - String and date values must be enclosed with single quotes (for example, 'some string value').

    .EXAMPLE
    $Qualifier = New-WHDQualifier -Attribute "email" -Operator CaseInsensitiveLike -Value "*@example.com"

    .EXAMPLE
    $Qualifier = New-WHDQualifier "assetNumber" Equals "12345"

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
function New-WHDQualifier {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Attribute,

        [Parameter(Mandatory, Position = 1)]
        [WHDQualifierOperator] $Operator,

        [Parameter(Mandatory, Position = 2)]
        [string] $Value
    )

    $OpString = switch ($Operator) {
        ([WHDQualifierOperator]::Equals)              { "=" }
        ([WHDQualifierOperator]::NotEquals)           { "!=" }
        ([WHDQualifierOperator]::LessThan)            { "<" }
        ([WHDQualifierOperator]::GreaterThan)         { ">" }
        ([WHDQualifierOperator]::LessThanOrEqual)     { "<=" }
        ([WHDQualifierOperator]::GreaterThanOrEqual)  { ">=" }
        ([WHDQualifierOperator]::Like)                { "like" }
        ([WHDQualifierOperator]::CaseInsensitiveLike) { "caseInsensitiveLike" }
    }

    # FIXME: This is very naive, but it matches how we currently use it.
    # FIXME: Find out when escaping is actually necessary and implement it properly.
    # FIXME: Do we need to wrap the attribute in quotes?
    # FIXME: WWHEN do we need to wrap the value in quotes?
    return "($Attribute $OpString '$Value')"
}