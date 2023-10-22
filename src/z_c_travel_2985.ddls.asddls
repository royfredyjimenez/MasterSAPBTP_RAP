@EndUserText.label: 'Consumption View - Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity Z_C_TRAVEL_2985
  provider contract transactional_query
  as projection on Z_I_TRAVEL_2985
{
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Travel_M', element: 'travel_id' } } ]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Travel'
  key TravelId,
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Agency', element: 'AgencyID' } } ]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Agencia'
      AgencyId,
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Customer', element: 'CustomerID' } } ]
      @Search.defaultSearchElement: true
      CustomerId,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency', element: 'Currency' } } ]
      CurrencyCode,
      Description,
      @EndUserText.label: 'Status'
      @ObjectModel.text.element: ['TravelStatusText']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FE_STAT_000044', element: 'TravelStatusId'  } }]
      TravelStatus,
      _TravelStatus.TravelStatusText as TravelStatusText,
      OverallStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      @EndUserText.label: 'Last Changed At'
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_C_BOOK_2985,
      _Agency,
      _Currency,
      _Customer
}
