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

# Qualifier binary operators (AND, OR), used to combine multiple qualifiers into a single query
# Note: "NOT" is a unary operator and is not included here, it should be handled separately.
enum WHDQualifierLogicalOperator {
    AND
    OR
}
