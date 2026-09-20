@{

    # Script module or binary module file associated with this manifest.
    RootModule           = "SolarWinds.WebHelpDesk.psm1"

    # Version number of this module.
    ModuleVersion        = "0.1.0"

    # Supported PSEditions
    CompatiblePSEditions = @("Desktop", "Core")

    # ID used to uniquely identify this module
    GUID                 = "DC2E5E21-FC26-4AE2-80BD-A6D310C9BA34"

    # Author of this module
    Author               = "Apocrypher00"

    # Company or vendor of this module
    CompanyName          = "Community"

    # Copyright statement for this module
    Copyright            = "(c) Apocrypher00. All rights reserved."

    # Description of the functionality provided by this module
    Description          = "Final legacy snapshot for SolarWinds Web Help Desk 2026.1 and earlier. Unmaintained; does not support the 2026.4.0 NextGen API."

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = "5.1"

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ""

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ""

    # Minimum version of Microsoft .NET Framework required by this module.
    # This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ""

    # Minimum version of the common language runtime (CLR) required by this module.
    # This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ""

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ""

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies   = @("System.Web")

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess     = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess       = @(
        "Types\Asset.Types.ps1xml"
        "Types\AssetStatus.Types.ps1xml"
        "Types\AssetType.Types.ps1xml"
        "Types\BillingRate.Types.ps1xml"
        "Types\Client.Types.ps1xml"
        "Types\Company.Types.ps1xml"
        "Types\CustomFieldDefinition.Types.ps1xml"
        "Types\Department.Types.ps1xml"
        "Types\Location.Types.ps1xml"
        "Types\Manufacturer.Types.ps1xml"
        "Types\Model.Types.ps1xml"
        "Types\PriorityType.Types.ps1xml"
        "Types\RequestType.Types.ps1xml"
        "Types\Room.Types.ps1xml"
        "Types\Session.Types.ps1xml"
        "Types\StatusType.Types.ps1xml"
        "Types\Tech.Types.ps1xml"
        "Types\ticketAttachment.Types.ps1xml"
        "Types\TicketBulkAction.Types.ps1xml"
        "Types\TicketNote.Types.ps1xml"
        "Types\Tickets.Types.ps1xml"
    )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @(
        "Formats\Asset.Format.ps1xml"
        "Formats\AssetStatus.Format.ps1xml"
        "Formats\AssetType.Format.ps1xml"
        "Formats\BillingRate.Format.ps1xml"
        "Formats\Client.Format.ps1xml"
        "Formats\Company.Format.ps1xml"
        "Formats\CustomFieldDefinition.Format.ps1xml"
        "Formats\Department.Format.ps1xml"
        "Formats\Location.Format.ps1xml"
        "Formats\Manufacturer.Format.ps1xml"
        "Formats\Model.Format.ps1xml"
        "Formats\PriorityType.Format.ps1xml"
        "Formats\RequestType.Format.ps1xml"
        "Formats\Room.Format.ps1xml"
        "Formats\Session.Format.ps1xml"
        "Formats\StatusType.Format.ps1xml"
        "Formats\Tech.Format.ps1xml"
        "Formats\ticketAttachment.Format.ps1xml"
        "Formats\TicketBulkAction.Format.ps1xml"
        "Formats\TicketNote.Format.ps1xml"
        "Formats\Tickets.Format.ps1xml"
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance,
    # do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        "Connect-WHDServer"
        "Disconnect-WHDServer"
        "Get-WHDResource"
        "Get-WHDAsset"
        "Get-WHDAssetStatus"
        "Get-WHDAssetType"
        "Get-WHDBillingRate"
        "Get-WHDClient"
        "Get-WHDCompany"
        "Get-WHDCustomFieldDefinition"
        "Get-WHDDepartment"
        "Get-WHDLocation"
        "Get-WHDManufacturer"
        "Get-WHDModel"
        "Get-WHDPreference"
        "Get-WHDPriorityType"
        "Get-WHDRequestType"
        "Get-WHDRoom"
        "Get-WHDSession"
        "Get-WHDStatusType"
        "Get-WHDTech"
        "Get-WHDTicket"
        "Get-WHDTicketAttachment"
        "Get-WHDTicketBulkAction"
        "Get-WHDTicketNote"
        "Invoke-WHDMethod"
        "Join-WHDQualifier"
        "New-WHDQualifier"
        "Remove-WHDResource"
        "Remove-WHDAsset"
        "Remove-WHDAssetType"
        "Remove-WHDClient"
        "Remove-WHDCompany"
        "Remove-WHDLocation"
        "Remove-WHDManufacturer"
        "Remove-WHDModel"
        "Remove-WHDSession"
        "Remove-WHDTicket"
    )

    # Cmdlets to export from this module, for best performance,
    # do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance,
    # do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @(
        "Connect-WebHelpDesk"
        "Disconnect-WebHelpDesk"
        "Get-WHDSetup"
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags                     = @("SolarWinds", "WHD", "WebHelpDesk", "REST", "API")

            # A URL to the license for this module.
            LicenseUri               = "https://github.com/Apocrypher00/SolarWinds.WebHelpDesk/blob/master/LICENSE"

            # A URL to the main website for this project.
            ProjectUri               = "https://github.com/Apocrypher00/SolarWinds.WebHelpDesk"

            # A URL to an icon representing this module.
            # IconUri = ""

            # ReleaseNotes of this module
            # ReleaseNotes = ""

            # Prerelease string of this module
            # Prerelease = ""

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ""

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = "WHD"
}
