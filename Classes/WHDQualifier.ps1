class WHDQualifier {
    [bool] $Negate = $false

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

    hidden static [string] EscapeValue([string] $Value) {
        if ($null -eq $Value) {
            return ""
        }

        return $Value.Replace("'", "''")
    }
}

class WHDClauseQualifier : WHDQualifier {
    [string] $Attribute
    [WHDQualifierOperator] $Operator
    [string] $Value

    WHDClauseQualifier([string] $Attribute, [WHDQualifierOperator] $Operator, [string] $Value) {
        $this.Attribute = $Attribute
        $this.Operator = $Operator
        $this.Value = $Value
    }

    hidden [string] RenderCore() {
        $opString = [WHDQualifier]::GetOperatorToken($this.Operator)
        $escapedValue = [WHDQualifier]::EscapeValue($this.Value)
        return "($($this.Attribute) $opString '$escapedValue')"
    }
}

class WHDGroupQualifier : WHDQualifier {
    [WHDQualifier[]] $Qualifiers = @()
    [WHDQualifierLogicalOperator] $JoinOperator

    WHDGroupQualifier([WHDQualifier[]] $Qualifiers, [WHDQualifierLogicalOperator] $JoinOperator) {
        if ($null -eq $Qualifiers -or $Qualifiers.Count -eq 0) {
            throw "A qualifier group must include at least one child qualifier."
        }

        $this.Qualifiers = $Qualifiers
        $this.JoinOperator = $JoinOperator
    }

    hidden [string] RenderCore() {
        if ($this.Qualifiers.Count -eq 1) {
            return $this.Qualifiers[0].ToString()
        }

        $joinToken = [string] $this.JoinOperator
        $childStrings = foreach ($Qualifier in $this.Qualifiers) {
            $Qualifier.ToString()
        }

        return "($($childStrings -join " $joinToken "))"
    }
}
