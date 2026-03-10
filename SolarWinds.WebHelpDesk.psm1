# Module state
$Script:WHDConnection = @{
    BaseUrl        = $null
    WebSession     = $null
    Session        = $null
    Authentication = @{
        apiKey   = $null
        username = $null
    }
    # Cache          = @{ # TODO: We will store data here that replaces stub fields
    #     AssetStatus = @{
    #         Map     = @{}                           # [int] -> [string]
    #         Fetched = $null                         # [datetime]
    #         Ttl     = [timespan]::FromMinutes(5)    # default TTL
    #     }
    # }
}

# Import all functions in the Private and Public folders
$Functions        = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
$PrivateFunctions = Join-Path -Path $Functions -ChildPath 'Private'
$PublicFunctions  = Join-Path -Path $Functions -ChildPath 'Public'
Get-ChildItem -Path $PrivateFunctions -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $PublicFunctions  -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }

# Import all enums in the Enums folder
$Enums = Join-Path -Path $PSScriptRoot -ChildPath 'Enums'
Get-ChildItem -Path $Enums -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }

# Register type accelerators for enums?
# $accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
# $accelerators::Add("WHDResourceType", [WHDResourceType])
# $accelerators::Add("WHDCustomFieldType", [WHDCustomFieldType])
# $accelerators::Add("WHDQualifierOperator", [WHDQualifierOperator])
# $accelerators::Add("WHDQualifierLogicalOperator", [WHDQualifierLogicalOperator])
