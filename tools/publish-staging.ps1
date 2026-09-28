[CmdletBinding()]
param(
    [string] $ModuleRoot,

    [string] $ModuleName,

    [string[]] $IncludePaths = @(
        'Classes',
        'Enums',
        'Formats',
        'Functions',
        'Types',
        'LICENSE',
        'README.md'
    ),

    [string] $StagePath,

    [string] $LocalRepositoryPath,

    [string] $LocalRepositoryName,

    [switch] $PublishToPSGallery,

    [string] $NuGetApiKey,

    [switch] $KeepStage,

    [switch] $SkipLocalPublishTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DefaultModuleRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($ModuleRoot)) {
    $ModuleRoot = $DefaultModuleRoot
}

$ModuleRoot = (Resolve-Path -LiteralPath $ModuleRoot).Path

if ([string]::IsNullOrWhiteSpace($StagePath)) {
    $StagePath = Join-Path $ModuleRoot 'artifacts\stage'
}

if ([string]::IsNullOrWhiteSpace($LocalRepositoryPath)) {
    $LocalRepositoryPath = Join-Path $ModuleRoot 'artifacts\localrepo'
}

$ManifestCandidates = @(Get-ChildItem -LiteralPath $ModuleRoot -Filter '*.psd1' -File)
if ([string]::IsNullOrWhiteSpace($ModuleName)) {
    if ($ManifestCandidates.Count -eq 1) {
        $ManifestPath = $ManifestCandidates[0].FullName
    } else {
        throw 'Unable to determine the module manifest automatically. Specify -ModuleName or use a module root that contains exactly one .psd1 file.'
    }
}
else {
    $ManifestPath = Join-Path $ModuleRoot ("{0}.psd1" -f $ModuleName)
    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Module manifest not found: $ManifestPath"
    }
}

$ManifestInfo = Test-ModuleManifest -Path $ManifestPath
if ([string]::IsNullOrWhiteSpace($ModuleName)) {
    $ModuleName = $ManifestInfo.Name
}

if ([string]::IsNullOrWhiteSpace($LocalRepositoryName)) {
    $LocalRepositoryName = ('{0}LocalTest{1}' -f ($ModuleName -replace '[^a-zA-Z0-9]', ''), $PID)
}

function Resolve-OutputPath {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $ModuleRoot $Path
    }

    [System.IO.Path]::GetFullPath($Path).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
}

function Assert-SafeOutputPath {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    $PathRoot = [System.IO.Path]::GetPathRoot($Path).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    if ($Path -eq $PathRoot -or $Path -eq $ModuleRoot -or
        $ModuleRoot.StartsWith($Path + [System.IO.Path]::DirectorySeparatorChar,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to use unsafe output path: $Path"
    }
}

$StagePath = Resolve-OutputPath -Path $StagePath
$LocalRepositoryPath = Resolve-OutputPath -Path $LocalRepositoryPath
Assert-SafeOutputPath -Path $StagePath
Assert-SafeOutputPath -Path $LocalRepositoryPath

if ($StagePath -eq $LocalRepositoryPath) {
    throw 'StagePath and LocalRepositoryPath must be different.'
}

$ModuleStagePath = Join-Path $StagePath $ModuleName
$ItemsToStage = [System.Collections.Generic.List[string]]::new()

foreach ($IncludePath in $IncludePaths) {
    $ResolvedIncludePath = Join-Path $ModuleRoot $IncludePath
    if (Test-Path -LiteralPath $ResolvedIncludePath) {
        $ItemsToStage.Add($IncludePath)
    } else {
        throw "Include path not found: $ResolvedIncludePath"
    }
}

$ItemsToStage.Add((Split-Path -Leaf $ManifestPath))

$RootModulePath = $null
if (-not [string]::IsNullOrWhiteSpace($ManifestInfo.RootModule)) {
    $RootModulePath = Join-Path $ModuleRoot ([string] $ManifestInfo.RootModule)
    if (-not (Test-Path -LiteralPath $RootModulePath)) {
        throw "RootModule file not found: $RootModulePath"
    }

    $RootModuleLeaf = Split-Path -Leaf $RootModulePath
    if (-not $ItemsToStage.Contains($RootModuleLeaf)) {
        $ItemsToStage.Add($RootModuleLeaf)
    }
}

function New-Directory {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Path | Out-Null
}

function Test-StagedModule {
    param(
        [Parameter(Mandatory)]
        [string] $ManifestPath
    )

    $ValidationScriptPath = Join-Path $StagePath 'test-staged-module.ps1'
    @(
        'param([Parameter(Mandatory)][string] $ManifestPath)'
        '$ErrorActionPreference = ''Stop'''
        '$Manifest = Test-ModuleManifest -Path $ManifestPath'
        '$Module = Import-Module -Name $ManifestPath -Force -PassThru'
        'if ($Module.Name -ne $Manifest.Name) {'
        '    throw "Imported module name does not match the staged manifest."'
        '}'
        'Remove-Module -Name $Module.Name -Force'
    ) | Set-Content -LiteralPath $ValidationScriptPath -Encoding UTF8

    $PowerShellCommands = @(Get-Command -Name 'powershell.exe', 'pwsh.exe' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Source -Unique)

    if ($PowerShellCommands.Count -eq 0) {
        throw 'Neither Windows PowerShell nor PowerShell was found for staged-module validation.'
    }

    foreach ($PowerShellCommand in $PowerShellCommands) {
        Write-Host "Testing staged module with $PowerShellCommand"
        & $PowerShellCommand -NoLogo -NoProfile -NonInteractive -File $ValidationScriptPath `
            -ManifestPath $ManifestPath

        if ($LASTEXITCODE -ne 0) {
            throw "Staged-module validation failed in $PowerShellCommand."
        }
    }
}

Write-Host "Validating module manifest..."
$null = $ManifestInfo
Write-Host "Using module root: $ModuleRoot"
Write-Host "Using manifest: $ManifestPath"

Write-Host "Preparing staging directory at $StagePath"
New-Directory -Path $StagePath
New-Item -ItemType Directory -Path $ModuleStagePath | Out-Null

foreach ($Item in $ItemsToStage) {
    $SourcePath = Join-Path $ModuleRoot $Item
    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Required item not found: $SourcePath"
    }

    Copy-Item -LiteralPath $SourcePath -Destination $ModuleStagePath -Recurse -Force
}

$StagedManifestPath = Join-Path $ModuleStagePath (Split-Path -Leaf $ManifestPath)
$Manifest = Test-ModuleManifest -Path $StagedManifestPath

Write-Host "Staged module version: $($Manifest.Version)"
Write-Host "Staged files:"
Get-ChildItem -LiteralPath $ModuleStagePath -Recurse -File |
    ForEach-Object { $_.FullName.Substring($ModuleStagePath.Length + 1) } |
    Sort-Object |
    ForEach-Object { Write-Host "  $_" }

Test-StagedModule -ManifestPath $StagedManifestPath

if (-not $SkipLocalPublishTest) {
    Write-Host "Preparing local test repository at $LocalRepositoryPath"
    New-Directory -Path $LocalRepositoryPath

    if (Get-PSRepository -Name $LocalRepositoryName -ErrorAction SilentlyContinue) {
        throw "A PowerShell repository named '$LocalRepositoryName' is already registered."
    }

    $RepositoryParameters = @{
        Name               = $LocalRepositoryName
        SourceLocation     = $LocalRepositoryPath
        PublishLocation    = $LocalRepositoryPath
        InstallationPolicy = 'Trusted'
    }

    try {
        Register-PSRepository @RepositoryParameters

        if (-not (Get-PSRepository -Name $LocalRepositoryName -ErrorAction SilentlyContinue)) {
            throw "The local PowerShell repository '$LocalRepositoryName' could not be registered."
        }

        Write-Host "Publishing staged module to local test repository..."
        Publish-Module -Path $ModuleStagePath -Repository $LocalRepositoryName -Force -ErrorAction Stop

        $PackagePath = Join-Path $LocalRepositoryPath ("{0}.{1}.nupkg" -f $ModuleName, $Manifest.Version)
        if (-not (Test-Path -LiteralPath $PackagePath)) {
            throw "Local package was not created: $PackagePath"
        }

        Write-Host "Created package: $PackagePath"

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $Archive = [System.IO.Compression.ZipFile]::OpenRead($PackagePath)
        try {
            $PackageFiles = $Archive.Entries |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.Name) } |
                ForEach-Object { $_.FullName }

            Write-Host "Package contents:"
            $PackageFiles |
                Sort-Object |
                ForEach-Object { Write-Host "  $_" }
        } finally {
            $Archive.Dispose()
        }
    } finally {
        Unregister-PSRepository -Name $LocalRepositoryName -ErrorAction SilentlyContinue
    }
}

if ($PublishToPSGallery) {
    if ([string]::IsNullOrWhiteSpace($NuGetApiKey)) {
        $NuGetApiKey = $env:PSGALLERY_API_KEY
    }

    if ([string]::IsNullOrWhiteSpace($NuGetApiKey)) {
        throw 'NuGetApiKey or the PSGALLERY_API_KEY environment variable is required when using -PublishToPSGallery.'
    }

    Write-Host 'Publishing staged module to PSGallery...'
    Publish-Module -Path $ModuleStagePath -Repository PSGallery -NuGetApiKey $NuGetApiKey
}

if (-not $KeepStage) {
    Write-Host "Removing staging directory $StagePath"
    Remove-Item -LiteralPath $StagePath -Recurse -Force
}

Write-Host 'Done.'