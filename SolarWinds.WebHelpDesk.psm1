# Module state
$Script:WHDConnection = @{
    BaseUrl    = $null
    Session    = $null
    WebSession = $null
    Cache      = @{ # TODO: We will store data here that replaces stub fields, such as the AssetStatus field on Tickets
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

# Export all functions in the Public folder
# Export-ModuleMember -Function (Get-ChildItem $Public -Filter '*.ps1' -File | ForEach-Object { $_.BaseName })
