@EndUserText.label: 'Consumption - Travel Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity Z_C_ATRAVEL_2985
  as projection on Z_I_TRAVEL_2985
{
  key TravelId,
      @ObjectModel.text.element: ['AgencyName']
      AgencyId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      Description,
      TravelStatus,
      TravelStatusText,
      OverallStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking,
      _Currency,
      _Customer,
      _TravelStatus
}
