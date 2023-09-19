@EndUserText.label: 'Consumption - Booking Approval'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define  view entity Z_C_ABOOKING_2985
  as projection on Z_I_BOOKING_2985
{

  key travel_id       as TravelID,
  key booking_id      as BookingID,
      booking_date    as BookingDate,
      customer_id     as CustomerID,
      @ObjectModel.text.element: ['CarrierName']
      carrier_id      as CarrierID,
      _Carrier.Name   as CarrierName,
      connection_id   as ConnectionID,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      @Semantics.currencyCode: true
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,
      /* Associations */
      _Travel : redirected to parent Z_C_ATRAVEL_2985,
      _Customer,
      _Carrier

}
