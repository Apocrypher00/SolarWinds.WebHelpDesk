<#
    These represent top-level endpoints (a.k.a. Resources) in the Web Help Desk API
    Several Resources have subtypes that represent a second-level endpoint
    Supported HTTP methods are defined in Assert-SupportsMethod.ps1.
#>
enum WHDResourceType {
    # Resource names match singular API endpoints except Tickets, which has no singular endpoint.
    # ticketAttachment is lowercase because the endpoint path is case-sensitive.
    Asset
    AssetStatus
    AssetType
    BillingRate
    Client
    Company
    CustomFieldDefinition
    Department
    Email
    Location
    Manufacturer
    Model
    Preference
    PriorityType
    RequestType
    Room
    Session
    StatusType
    TechNote
    Tech
    ticketAttachment
    Token
    TicketBulkAction
    TicketNote
    Tickets
}
