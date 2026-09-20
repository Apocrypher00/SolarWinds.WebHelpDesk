<#
    These represent top-level endpoints (a.k.a. Resources) in the Web Help Desk API
    Several Resources have subtypes that represent a second-level endpoint
    Each Resource only supports a subset of the HTTP methods (GET, POST, PUT, DELETE), that
    correspond to the available API operations for that Resource (Get, New, Set, Remove)
#>
enum WHDResourceType {
    # Resource names match singular API endpoints except Tickets, which has no singular endpoint.
    # ticketAttachment is lowercase because the endpoint path is case-sensitive.
    Asset                  # GET, POST, PUT, DELETE
    AssetStatus            # GET
    AssetType              # GET, POST, PUT, DELETE
    BillingRate            # GET
    Client                 # GET, POST, PUT (legacy DELETE appeared to work but is absent from the NextGen schema)
    Company                # GET, POST, PUT, DELETE
    CustomFieldDefinition # GET
    Department             # GET
    Email                  # POST
    Location               # GET, POST, PUT, DELETE
    Manufacturer           # GET, POST, PUT, DELETE
    Model                  # GET, POST, PUT, DELETE
    Preference             # GET
    PriorityType           # GET
    RequestType            # GET
    Room                   # GET
    Session                # GET, DELETE
    StatusType             # GET
    TechNote               # POST (This is essentially how you POST a TicketNote)
    Tech                   # GET
    ticketAttachment       # GET (POST uploads use the /upload action)
    TicketBulkAction       # GET
    TicketNote             # GET
    Tickets                # GET, POST, PUT, DELETE
}
