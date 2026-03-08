# Valid Resource types
enum WHDResourceType {
    Assets
    AssetStatuses
    Clients
    CustomFieldDefinitions
    Departments
    Locations
    Session
    Techs
    Tickets
}

# Valid CustomFieldDefinitions sub-types
enum WHDCustomFieldType {
    Asset
    Location
    Ticket
}

# Qualifier operators (=, !=, <, >, <=, >=, like, or caseInsensitiveLike)
enum WHDQualifierOperator {
    Equals
    NotEquals
    LessThan
    GreaterThan
    LessThanOrEqual
    GreaterThanOrEqual
    Like
    CaseInsensitiveLike
}
