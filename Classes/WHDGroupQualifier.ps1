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
        $JoinToken = [string] $this.JoinOperator
        $ChildStrings = foreach ($Qualifier in $this.Qualifiers) {
            $Qualifier.ToString()
        }

        return "($($ChildStrings -join " $JoinToken "))"
    }
}
