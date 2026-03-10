<#
    .SYNOPSIS
    Get a client from WHD.

    .DESCRIPTION
    This function retrieves clients from WHD based on a provided search parameter.

    .PARAMETER ResourceId
    The resource ID of the client to retrieve.

    .PARAMETER Email
    The email address of the client to retrieve.

    .PARAMETER Expand
    If specified, the function will expand the client details to include additional information.
#>
function Get-WHDClient {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Search")]
        [string] $Email,

        [Parameter()]
        [switch] $Expand
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-WHDResource `
                -ResourceType ([WHDResourceType]::Clients) `
                -ResourceId   $ResourceId
        }
        "Search" {
            # Build a search qualifier based on the provided parameters
            # FIXME: I wanted this to be a loop, but the attribute names don't match the parameter names
            $Qualifiers = [System.Collections.ArrayList]::new()
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("AssetNumber")) {
                $Qualifiers.Add(
                    (
                        New-WHDQualifier `
                            -Attribute "email" `
                            -Operator  ([WHDQualifierOperator]::CaseInsensitiveLike) `
                            -Value     $Email
                    )
                )
            }

            # Combine qualifiers with AND, if there are any
            # Otherwise, if there are no qualifiers, we want to pass an empty string to get all clienta
            $Qualifier = if ($Qualifiers.Count -eq 0) { "" } else {
                Join-WHDQualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the assets
            $Results = Get-WHDResource `
                -ResourceType ([WHDResourceType]::Clients) `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the asset
    return $Results
}