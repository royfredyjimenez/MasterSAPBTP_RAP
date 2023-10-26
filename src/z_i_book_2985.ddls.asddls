@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Bookings'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity Z_I_BOOK_2985
  as select from ztb_booking_2985 as Booking
  composition [0..*] of Z_I_BOOKSUPPL_2985 as _bookingSupplement
  association        to parent Z_I_TRAVEL_2985    as _Travel on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer    as _Customer      on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier     as _Carrier       on  $projection.carrier_id = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection  as _Connection    on  $projection.ConnectionId = _Connection.ConnectionID
  association [0..1] to /dmo/flight        as _Flight        on  $projection.ConnectionId = _Flight.connection_id
                                                             and $projection.carrier_id   = _Flight.carrier_id
                                                             and $projection.FlightDate   = _Flight.flight_date
{
  key Booking.travel_id       as TravelId,
  key Booking.booking_id      as BookingId,
      Booking.booking_date    as BookingDate,
      Booking.customer_id     as CustomerId,
      Booking.carrier_id,
      Booking.connection_id   as ConnectionId,
      Booking.flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Booking.flight_price    as FlightPrice,
      Booking.currency_code   as CurrencyCode,
      Booking.booking_status  as BookingStatus,
      Booking.last_changed_at as LastChangedAt,
      /* asociaciones */
      _Travel,
      _bookingSupplement,
      _Customer,
      _Carrier,
      _Connection,
      _Flight

}
