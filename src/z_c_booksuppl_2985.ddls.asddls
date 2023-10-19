@EndUserText.label: 'Consumption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPL_2985
  as projection on Z_I_BOOKSUPPL_2985
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      Price,
      Currency,
      LastChangedAt,
      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_2985,
      _Booking : redirected to parent Z_C_BOOK_2985,
      _Product,
      _SupplementText

}
