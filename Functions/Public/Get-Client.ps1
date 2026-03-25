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
function Get-Client {
    [CmdletBinding(DefaultParameterSetName = "Search")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory)]
        [int] $ResourceId,

        [Parameter(ParameterSetName = "Qualifier", Mandatory)]
        [string] $Qualifier,

        [Parameter(ParameterSetName = "Search")]
        [string] $Email,

        [Parameter()]
        [switch] $Expand
    )

    $ResourceType = [WHDResourceType]::Clients

    # A mapping of parameter names to WHD attribute names, used for building qualifiers in the Search parameter set
    # FIXME: Where is the best place for this?
    $ClientAttributeMap = @{
        Email  = "email"
    }

    switch ($PSCmdlet.ParameterSetName) {
        "Single" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -ResourceId   $ResourceId
        }
        "Qualifier" {
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
        "Search" {
            # Build a search qualifier for each of the provided parameters
            $Qualifiers = foreach ($Param in $PSBoundParameters.Keys) {
                if ($ClientAttributeMap.ContainsKey($Param)) {
                    New-Qualifier `
                        -Attribute $ClientAttributeMap[$Param] `
                        -Operator  ([WHDQualifierOperator]::Equals) `
                        -Value     $PSBoundParameters[$Param]
                }
            }

            # Combine qualifiers with AND, if there are any
            # If there are no qualifiers, we want to pass an empty string to get all clients
            $Qualifier = if ($Qualifiers.Count -eq 0) { [string]::Empty } else {
                Join-Qualifier `
                    -Qualifiers   $Qualifiers `
                    -JoinOperator ([WHDQualifierLogicalOperator]::AND)
            }

            # Get the clients
            $Results = Get-Resource `
                -ResourceType $ResourceType `
                -Qualifier    $Qualifier `
                -Expand:$Expand
        }
    }

    # Return the client
    return $Results
}