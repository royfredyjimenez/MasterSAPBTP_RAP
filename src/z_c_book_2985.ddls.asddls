@EndUserText.label: 'Consumption-Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOK_2985 as projection on Z_I_BOOK_2985
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    carrier_id,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _bookingSupplement: redirected to composition child Z_C_BOOKSUPPL_2985,
    _Carrier,
    _Connection,
    _Customer,
    _Flight,
    _Travel  : redirected to parent Z_C_TRAVEL_2985
}
