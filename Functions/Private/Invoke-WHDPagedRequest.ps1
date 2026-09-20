<#
    .SYNOPSIS
    Invoke a paged GET request and return all resources from the response envelopes.

    .DESCRIPTION
    Requests each page of a Web Help Desk list endpoint and combines the result arrays.
    Paging stops after a partial page. Repeated batches cause an error to prevent an infinite loop.

    .PARAMETER UriBuilder
    The UriBuilder for the list endpoint.

    .PARAMETER QueryParameters
    Query parameters to include with every request.

    .PARAMETER ResourceType
    The ResourceType being retrieved. Used to identify the resource in paging errors.

    .PARAMETER Body
    Optional GET parameters to pass to Invoke-WHDMethod.
#>
function Invoke-WHDPagedRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.UriBuilder] $UriBuilder,

        [Parameter(Mandatory)]
        [System.Collections.Specialized.NameValueCollection] $QueryParameters,

        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter()]
        [AllowNull()]
        [hashtable] $Body
    )

    # Use the largest documented page size. Endpoints with lower maximums cap this value.
    $QueryParameters.Remove("batch")
    $QueryParameters.Remove("batchSize")
    $QueryParameters["limit"] = 1000
    $QueryParameters["page"] = 1

    $ParameterHash = @{
        UriBuilder = $UriBuilder
        Method     = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
    }

    if ($null -ne $Body) {
        $ParameterHash["Body"] = $Body
    }

    $PagedResults = [System.Collections.Generic.List[object]]::new()
    $PreviousBatch = $null

    do {
        $UriBuilder.Query = $QueryParameters.ToString()
        $Response = Invoke-WHDMethod @ParameterHash

        $IsListEnvelope = (
            ($null -ne $Response) -and
            ($null -ne $Response.PSObject.Properties["result"]) -and
            ($null -ne $Response.PSObject.Properties["count"]) -and
            ($null -ne $Response.PSObject.Properties["batch"]) -and
            ($null -ne $Response.PSObject.Properties["batchSize"])
        )

        if (-not $IsListEnvelope) {
            return $Response
        }

        $CurrentBatch = [int] $Response.batch
        if (($null -ne $PreviousBatch) -and ($CurrentBatch -le $PreviousBatch)) {
            throw "The '$ResourceType' resource returned a repeated paging batch."
        }

        foreach ($Result in $Response.result) {
            $PagedResults.Add($Result)
        }

        $CurrentCount     = [int] $Response.count
        $CurrentBatchSize = [int] $Response.batchSize
        $HasMoreResults   = ($CurrentBatchSize -gt 0) -and ($CurrentCount -eq $CurrentBatchSize)
        $PreviousBatch    = $CurrentBatch
        $QueryParameters["page"] = ([int] $QueryParameters["page"]) + 1
    } while ($HasMoreResults)

    return $PagedResults.ToArray()
}
