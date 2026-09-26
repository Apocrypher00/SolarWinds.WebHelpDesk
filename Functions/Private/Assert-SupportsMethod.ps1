# Initialized once when this private function file is imported.
$Script:WHDResourceMethods = & {
    $Resource = [WHDResourceType]
    $Method   = [Microsoft.PowerShell.Commands.WebRequestMethod]

    return @{
        ($Resource::Asset)                 = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::AssetStatus)           = @($Method::Get)
        ($Resource::AssetType)             = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::BillingRate)           = @($Method::Get)
        # Legacy DELETE isn't documented but appears to work.
        ($Resource::Client)                = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::Company)               = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::CustomFieldDefinition) = @($Method::Get)
        ($Resource::Department)            = @($Method::Get)
        ($Resource::Email)                 = @($Method::Post)
        ($Resource::Location)              = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::Manufacturer)          = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::Model)                 = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
        ($Resource::Preference)            = @($Method::Get)
        ($Resource::PriorityType)          = @($Method::Get)
        ($Resource::RequestType)           = @($Method::Get)
        ($Resource::Room)                  = @($Method::Get)
        ($Resource::Session)               = @($Method::Get, $Method::Delete)
        ($Resource::StatusType)            = @($Method::Get)
        # This is essentially how you POST a TicketNote.
        ($Resource::TechNote)              = @($Method::Post)
        ($Resource::Tech)                  = @($Method::Get)
        # POST uses the /upload action.
        ($Resource::ticketAttachment)      = @($Method::Get)
        ($Resource::Token)                 = @($Method::Post, $Method::Delete)
        ($Resource::TicketBulkAction)      = @($Method::Get)
        ($Resource::TicketNote)            = @($Method::Get)
        ($Resource::Tickets)               = @($Method::Get, $Method::Post, $Method::Put, $Method::Delete)
    }
}

<#
    .SYNOPSIS
    Assert that a ResourceType supports an HTTP method.

    .DESCRIPTION
    Checks the module's resource method map and throws when the requested operation isn't supported.
#>
function Assert-SupportsMethod {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [WHDResourceType] $ResourceType,

        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method
    )

    if ($Method -notin $Script:WHDResourceMethods[$ResourceType]) {
        throw "The '$ResourceType' ResourceType doesn't support $($Method.ToString().ToUpperInvariant())."
    }
}
