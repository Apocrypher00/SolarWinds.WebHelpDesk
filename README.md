# SolarWinds.WebHelpDesk

PowerShell module for the SolarWinds Web Help Desk (WHD) NextGen REST API introduced in WHD 2026.4.0.

> [!IMPORTANT]
> This version does not support WHD 2026.1 and earlier.
> The final module snapshot for the legacy API is available from the
> [v0.1.0-legacy release](https://github.com/Apocrypher00/SolarWinds.WebHelpDesk/releases/tag/v0.1.0-legacy).

## Requirements

- SolarWinds Web Help Desk 2026.4.0
- Windows PowerShell 5.1 or PowerShell 7
- A Web Help Desk API key

The module has been tested against WHD 2026.4.0 build 2026.4.0.19.

## Installation

Install the published module from the PowerShell Gallery:

```powershell
Install-Module -Name SolarWinds.WebHelpDesk
```

To use the current source instead, clone the repository and import its manifest:

```powershell
git clone https://github.com/Apocrypher00/SolarWinds.WebHelpDesk.git
Import-Module .\SolarWinds.WebHelpDesk\SolarWinds.WebHelpDesk.psd1
```

## Connecting

`Connect-WebHelpDesk` exchanges an API key for a one-hour bearer Token by default.
The API key is cleared from module state after the Token is created.

```powershell
Connect-WebHelpDesk -BaseUrl "https://whd.example.com" -ApiKey $ApiKey
```

Application API keys also require the associated username:

```powershell
Connect-WebHelpDesk -BaseUrl "https://whd.example.com" -ApiKey $ApiKey -Username $Username
```

Session and direct API-key authentication are also available:

```powershell
Connect-WebHelpDesk `
    -BaseUrl "https://whd.example.com" `
    -ApiKey $ApiKey `
    -AuthenticationMode Session

Connect-WebHelpDesk `
    -BaseUrl "https://whd.example.com" `
    -ApiKey $ApiKey `
    -AuthenticationMode Direct
```

An existing Token or Session can be supplied directly:

```powershell
Connect-WebHelpDesk -BaseUrl "https://whd.example.com" -Token $Token
Connect-WebHelpDesk -BaseUrl "https://whd.example.com" -Session $Session
```

Disconnecting revokes an active Token or Session and clears the module's connection state:

```powershell
Disconnect-WebHelpDesk
```

## Examples

Retrieve a Ticket or Asset:

```powershell
$Ticket = Get-WHDTicket -ResourceId 32023
$Asset = Get-WHDAsset -AssetNumber "3614"
```

Retrieve a filtered list:

```powershell
Get-WHDTicket -Status "Open"
Get-WHDAsset -Location "Main Office" -Room "101"
```

Build more advanced qualifiers:

```powershell
$Open = New-WHDQualifier -Attribute "statustype.statusTypeName" -Operator Equals -Value "Open"
$High = New-WHDQualifier -Attribute "prioritytype.priorityTypeName" -Operator Equals -Value "High"
$Qualifier = Join-WHDQualifier -Qualifiers $Open, $High -JoinOperator And

Get-WHDTicket -Qualifier $Qualifier
```

List commands automatically retrieve every page returned by the API.

Download a Ticket attachment response:

```powershell
$Attachment = Get-WHDTicketAttachment -ResourceId 2699
[IO.File]::WriteAllBytes("$PWD\screen.jpeg", $Attachment.Response.Content)
```

Inspect the claims in a Token without displaying its access token:

```powershell
$Token.GetJwtPayload()
```

## Current scope

The module provides named Get commands for every resource that the NextGen API exposes through GET.
It also provides named Remove commands for:
Assets, Asset Types, Companies, Locations, Manufacturers, Models, Tickets, Sessions, and Tokens.

Session and Token creation are supported. General create and update commands are planned for a later release.
`Invoke-WHDMethod` and `Get-WHDResource` are exported for advanced API access.

## Known API inconsistencies

SolarWinds uses mostly singular resource paths, with two exceptions represented directly by the module:

- `Tickets` has no singular endpoint.
- `ticketAttachment` is lowercase and case-sensitive.

`-Expand` requests `style=detailed` on Asset, Location, Model, Ticket, and TicketNote list operations.
Single Asset, Location, Ticket, and TicketNote requests are always detailed. Model supports short and detailed
representations for both list and single requests.

Client deletion is not supported by the NextGen API.
Although older WHD versions accepted an undocumented Client DELETE request, WHD 2026.4.0 returns HTTP 405.

## Security

Tokens and Session keys remain accessible as object properties but are hidden from their default table displays.
Treat these objects as credentials. Direct authentication retains the supplied API key in module state until the
connection is replaced or disconnected.

## License

This project is licensed under the terms in [LICENSE](LICENSE).
