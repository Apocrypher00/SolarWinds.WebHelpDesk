# External Imports
Add-Type -AssemblyName "System.Web" -ErrorAction Stop

# Import all enums in the Enums folder
$Enums = Join-Path -Path $PSScriptRoot -ChildPath 'Enums'
Get-ChildItem -Path $Enums -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }

# Import all functions in the Private and Public folders
$Functions        = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
$PrivateFunctions = Join-Path -Path $Functions -ChildPath 'Private'
$PublicFunctions  = Join-Path -Path $Functions -ChildPath 'Public'
Get-ChildItem -Path $PrivateFunctions -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $PublicFunctions  -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }

# Module State
$Script:WHDConnection = [PSCustomObject]@{
    UriBuilder = $null
    WebSession = $null
    Session    = $null
    AuthParams = New-HttpQSCollection
}

# Register type accelerators for enums?
# $accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
# $accelerators::Add("WHDResourceType", [WHDResourceType])
# $accelerators::Add("WHDCustomFieldType", [WHDCustomFieldType])
# $accelerators::Add("WHDQualifierOperator", [WHDQualifierOperator])
# $accelerators::Add("WHDQualifierLogicalOperator", [WHDQualifierLogicalOperator])
