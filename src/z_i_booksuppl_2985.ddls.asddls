@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Booking Supplements'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_BOOKSUPPL_2985
  as select from ztb_booksup_2985 as bookingsupplement
  association        to parent Z_I_BOOK_2985  as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                 and $projection.BookingId = _Booking.BookingId
  association [1..1] to Z_I_TRAVEL_2985       as _travel         on  $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _product        on  $projection.SupplementId = _product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementTexT on  $projection.SupplementId = _SupplementTexT.SupplementID

{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'currency'
      price                 as Price,
      currency_code         as Currency,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Booking,
      _travel,
      _product,
      _SupplementTexT


}
