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
        $AttributeName  = $this.Attribute
        $OperatorString = [WHDQualifier]::GetOperatorToken($this.Operator)
        $ValueString    = [WHDQualifier]::FormatClauseValue($this.Value)

        return "($AttributeName $OperatorString $ValueString)"
    }
}
