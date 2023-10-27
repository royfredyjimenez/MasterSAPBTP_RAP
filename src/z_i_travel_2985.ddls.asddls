@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Travels'
define root view entity Z_I_TRAVEL_2985
  as select from ztb_travel_2985 as _Travel
  composition [0..*] of Z_I_BOOK_2985     as _Booking
  association [0..1] to /DMO/I_Agency     as _Agency       on $projection.AgencyId = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer   as _Customer     on $projection.CustomerId = _Customer.CustomerID
  association [0..1] to I_Currency        as _Currency     on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to zi_fe_stat_001009 as _TravelStatus on $projection.TravelStatus = _TravelStatus.TravelStatusId
{
  key travel_id                      as TravelId,
      agency_id                      as AgencyId,
      customer_id                    as CustomerId,
      begin_date                     as BeginDate,
      end_date                       as EndDate,
      booking_fee                    as BookingFee,
      total_price                    as TotalPrice,
      currency_code                  as CurrencyCode,
      description                    as Description,
      overall_status                 as TravelStatus,
      _TravelStatus.TravelStatusText as TravelStatusText,
      case overall_status
      when 'O'  then 2    -- 'open'       | 2: yellow colour
      when 'A'  then 3    -- 'accepted'   | 3: green colour
      when 'X'  then 1    -- 'rejected'   | 1: red colour
            else 0        -- 'nothing'    | 0: unknown
      end                            as OverallStatusCriticality, 

      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                as LastChangedAt,
      /* Asociaciones */
      _Booking,
      _Agency,
      _Customer,
      _Currency,
      _TravelStatus

}
