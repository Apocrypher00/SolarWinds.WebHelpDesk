# When querying tickets, when no qualifier is provided, must specify a list type (list=mine|group|flagged|recent).
# These are also the valid ticket sub-types.
enum WHDTicketListType {
    mine
    group
    flagged
    recent
}