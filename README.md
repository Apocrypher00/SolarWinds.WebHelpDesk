# SolarWinds.WebHelpDesk

PowerShell module for the legacy SolarWinds Web Help Desk (WHD) REST API.

## Final legacy snapshot

Version **0.1.0**, preserved by the **v0.1.0-legacy** tag, targets **WHD 2026.1 and earlier**. It does not support the NextGen API introduced in WHD 2026.4.0.

This is an archived development snapshot provided as-is. No further development or maintenance is planned for this legacy version. Future development in this repository will target the NextGen API. Use the tag or release below to obtain the legacy code; the default branch will change.

[Download the final legacy snapshot](https://github.com/Apocrypher00/SolarWinds.WebHelpDesk/releases/tag/v0.1.0-legacy)

## Installation

Download the source ZIP from the release, extract it, and import the manifest from the extracted directory:

```powershell
Import-Module 'C:\path\to\SolarWinds.WebHelpDesk\SolarWinds.WebHelpDesk.psd1'
```

Alternatively, obtain the exact snapshot using Git:

```powershell
git clone --branch v0.1.0-legacy --depth 1 https://github.com/Apocrypher00/SolarWinds.WebHelpDesk.git
Import-Module .\SolarWinds.WebHelpDesk\SolarWinds.WebHelpDesk.psd1
```

The manifest declares PowerShell 5.1 or later and Desktop/Core editions. This snapshot has not undergone a new cross-edition or live-server validation for this release. No PowerShell Gallery package is being published as part of this release.

## Known limitations

- Resource retrieval does not automatically traverse all result pages. Results can be limited to the server's default page size, despite existing command help describing retrieval of all resources.
- API coverage is incomplete; this snapshot is not a claim of support for every operation in the legacy API guide.
- Authentication uses legacy query parameters and, by default, session keys. Protect credentials and session keys in request URLs and logs.
- This release preserves existing runtime behavior. It is not a stabilization or compatibility certification release.
