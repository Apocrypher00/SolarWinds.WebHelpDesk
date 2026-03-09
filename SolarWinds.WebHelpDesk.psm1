# Module state
$Script:WHDConnection = @{
    BaseUrl        = $null
    WebSession     = $null
    Session        = $null
    Authentication = @{
        apiKey   = $null
        username = $null
    }
    Cache          = @{ # TODO: We will store data here that replaces stub fields
        AssetStatus = @{
            Map     = @{}                           # [int] -> [string]
            Fetched = $null                         # [datetime]
            Ttl     = [timespan]::FromMinutes(5)    # default TTL
        }
    }
}

# Import everything in the Private and Public folders
$Private = Join-Path $PSScriptRoot 'Private'
$Public  = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path $Private -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $Public  -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }

# Register type accelerators for enums?
# $accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
# $accelerators::Add("WHDResourceType", [WHDResourceType])
# $accelerators::Add("WHDCustomFieldType", [WHDCustomFieldType])
# $accelerators::Add("WHDQualifierOperator", [WHDQualifierOperator])
# $accelerators::Add("WHDQualifierLogicalOperator", [WHDQualifierLogicalOperator])

# Export all functions in the Public folder
# Export-ModuleMember -Function (Get-ChildItem $Public -Filter '*.ps1' -File | ForEach-Object { $_.BaseName })
