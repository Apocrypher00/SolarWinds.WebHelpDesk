<#
    These represent top-level endpoints (a.k.a. Resources) in the Web Help Desk API
    Several Resources have subtypes that represent a second-level endpoint
    Each Resource only supports a subset of the HTTP methods (GET, POST, PUT, DELETE), that
    correspond to the available API operations for that Resource (Get, New, Set, Remove)
#>
enum WHDResourceType {
    Assets                 # GET, POST, PUT, DELETE
    AssetStatuses          # GET
    AssetTypes             # GET, POST, PUT, DELETE
    BillingRates           # GET
    Clients                # GET, POST, PUT, DELETE (DELETE not indicated in API documentation but appears to work)
    Companies              # GET, POST, PUT, DELETE
    CustomFieldDefinitions # GET
    Departments            # GET
    Email                  # POST
    Locations              # GET, POST, PUT, DELETE
    Manufacturers          # GET, POST, PUT, DELETE
    Models                 # GET, POST, PUT, DELETE
    Preferences            # GET
    PriorityTypes          # GET
    RequestTypes           # GET
    Rooms                  # GET
    Session                # GET, DELETE
    StatusTypes            # GET
    TechNotes              # POST (This is essentially how you POST TicketNotes)
    Techs                  # GET
    TicketAttachments      # GET
    TicketBulkActions      # GET
    TicketNotes            # GET
    Tickets                # GET, POST, PUT, DELETE
}
