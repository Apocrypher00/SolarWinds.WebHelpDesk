# External Imports
Add-Type -AssemblyName "System.Web" -ErrorAction Stop

# Import all enums in the Enums folder
$EnumPath = Join-Path -Path $PSScriptRoot -ChildPath "Enums"
$Enums = Get-ChildItem -Path $EnumPath -Filter "*.ps1" -File
foreach ($Enum in $Enums) { . $Enum.FullName }

# Import classes in dependency order
$ClassPath = Join-Path -Path $PSScriptRoot -ChildPath "Classes"
. (Join-Path -Path $ClassPath -ChildPath "WHDQualifier.ps1")
. (Join-Path -Path $ClassPath -ChildPath "WHDClauseQualifier.ps1")
. (Join-Path -Path $ClassPath -ChildPath "WHDGroupQualifier.ps1")

# Import all functions in the Private and Public folders
$FunctionPath        = Join-Path -Path $PSScriptRoot -ChildPath "Functions"

$PrivateFunctionPath = Join-Path -Path $FunctionPath -ChildPath "Private"
$PrivateFunctions = Get-ChildItem -Path $PrivateFunctionPath -Filter "*.ps1" -File
foreach ($Function in $PrivateFunctions) { . $Function.FullName }

$PublicFunctionPath  = Join-Path -Path $FunctionPath -ChildPath "Public"
$PublicFunctions = Get-ChildItem -Path $PublicFunctionPath -Filter "*.ps1" -File
foreach ($Function in $PublicFunctions) { . $Function.FullName }

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
