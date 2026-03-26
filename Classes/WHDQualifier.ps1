class WHDQualifier {
    [bool] $Negate = $false

    hidden static [string] $DateTimeOffsetFormat = "yyyy-MM-ddTHH:mm:sszzz"

    hidden [string] RenderCore() {
        throw "WHDQualifier.RenderCore() must be implemented by a derived qualifier type."
    }

    [string] Render() {
        $rendered = $this.RenderCore()

        if ($this.Negate) {
            return "(not $rendered)"
        }

        return $rendered
    }

    [string] ToString() {
        return $this.Render()
    }

    hidden static [string] GetOperatorToken([WHDQualifierOperator] $Operator) {
        $op = switch ($Operator) {
            ([WHDQualifierOperator]::Equals)              { "=" }
            ([WHDQualifierOperator]::NotEquals)           { "!=" }
            ([WHDQualifierOperator]::LessThan)            { "<" }
            ([WHDQualifierOperator]::GreaterThan)         { ">" }
            ([WHDQualifierOperator]::LessThanOrEqual)     { "<=" }
            ([WHDQualifierOperator]::GreaterThanOrEqual)  { ">=" }
            ([WHDQualifierOperator]::Like)                { "like" }
            ([WHDQualifierOperator]::CaseInsensitiveLike) { "caseInsensitiveLike" }
        }

        return $op
    }

    hidden static [void] ValidateClauseValue([psobject] $Value) {
        if ($null -eq $Value) {
            throw "Qualifier value cannot be null."
        }

        if (
            ($Value -is [array]) -or
            ($Value -is [System.Collections.IDictionary]) -or
            (($Value -is [System.Collections.IEnumerable]) -and ($Value -isnot [string]))
        ) {
            throw "Qualifier value must be a scalar/basic type, not a collection or complex object."
        }
    }

    hidden static [string] FormatClauseValue([psobject] $Value) {
        $BaseValue = $Value.PSObject.BaseObject
        $BaseType = $BaseValue.GetType()

        if ($BaseType -eq [bool]) {
            return [int] $BaseValue
        }

        if (($BaseType -eq [datetime]) -or ($BaseType -eq [datetimeoffset])) {
            $DateOffset = [datetimeoffset] $BaseValue
            $DateString = $DateOffset.ToString(
                [WHDQualifier]::DateTimeOffsetFormat,
                [System.Globalization.CultureInfo]::InvariantCulture
            )

            return "'$DateString'"
        }

        $StringValue = [string] $BaseValue

        # Escape backslashes and single quotes for the qualifier syntax
        $EscapedValue = $StringValue.Replace('\\', '\\\\').Replace("'", "\'")

        return "'$EscapedValue'"
    }
}

class WHDClauseQualifier : WHDQualifier {
    [string] $Attribute
    [WHDQualifierOperator] $Operator
    [psobject] $Value

    WHDClauseQualifier([string] $Attribute, [WHDQualifierOperator] $Operator, [psobject] $Value) {
        $this.Attribute = $Attribute
        $this.Operator  = $Operator
        [WHDQualifier]::ValidateClauseValue($Value)
        $this.Value     = $Value
    }

    hidden [string] RenderCore() {
        $attributeName  = $this.Attribute
        $OperatorString = [WHDQualifier]::GetOperatorToken($this.Operator)
        $ValueString    = [WHDQualifier]::FormatClauseValue($this.Value)

        return "($attributeName $OperatorString $ValueString)"
    }
}

class WHDGroupQualifier : WHDQualifier {
    [WHDQualifier[]] $Qualifiers = @()
    [WHDQualifierLogicalOperator] $JoinOperator

    WHDGroupQualifier([WHDQualifier[]] $Qualifiers, [WHDQualifierLogicalOperator] $JoinOperator) {
        if ($Qualifiers.Count -lt 2) {
            throw "A qualifier group must include at least two child qualifiers."
        }

        $this.Qualifiers = $Qualifiers
        $this.JoinOperator = $JoinOperator
    }

    hidden [string] RenderCore() {
        $joinToken = [string] $this.JoinOperator
        $childStrings = foreach ($Qualifier in $this.Qualifiers) {
            $Qualifier.ToString()
        }

        return "($($childStrings -join " $joinToken "))"
    }
}
