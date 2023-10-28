CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1  VALUE 'O', " Open
        accepted TYPE c LENGTH 1  VALUE 'A', " Accepted
        canceled TYPE c LENGTH 1  VALUE 'X', " Cancelled
      END OF travel_status.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS CalculateTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~CalculateTravelID.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.
        METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

*
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.
*
*    METHODS rejectTravel FOR MODIFY
*      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
* METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS: recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalcTotalPrice,
        createTravelByTemplate FOR MODIFY IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.


    METHODS is_update_granted IMPORTING has_before_image      TYPE abap_bool
                                        overall_status        TYPE /dmo/overall_status
                              RETURNING VALUE(update_granted) TYPE abap_bool.

    METHODS is_delete_granted IMPORTING has_before_image      TYPE abap_bool
                                        overall_status        TYPE /dmo/overall_status
                              RETURNING VALUE(delete_granted) TYPE abap_bool.

    METHODS is_create_granted RETURNING VALUE(create_granted) TYPE abap_bool.



ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.
*  METHOD get_instance_features.
*
*    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
*              ENTITY Travel
*              FIELDS ( travelid TravelStatus )
*          WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
*              RESULT DATA(lt_travel_result).
*
*    result = VALUE #( FOR ls_travel IN lt_travel_result (
*                          %key                  = ls_travel-%key
*                          %field-travelid      = if_abap_behv=>fc-f-read_only
*                          %field-TravelStatus = if_abap_behv=>fc-f-read_only
*                          %assoc-_Booking       = if_abap_behv=>fc-o-enabled
*                          %action-acceptTravel  = COND #( WHEN ls_travel-TravelStatus = 'A'
*                                                          THEN if_abap_behv=>fc-o-disabled
*                                                          ELSE if_abap_behv=>fc-o-enabled )
*                          %action-rejectTravel  = COND #( WHEN ls_travel-TravelStatus = 'X'
*                                                          THEN if_abap_behv=>fc-o-disabled
*                                                          ELSE if_abap_behv=>fc-o-enabled )
*    ) ).
*
*  ENDMETHOD.

*  METHOD get_instance_authorizations.
*
*    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980002985'
*                            THEN if_abap_behv=>auth-allowed
*                            ELSE if_abap_behv=>auth-unauthorized ).
*
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
*
*      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
*      <ls_result> = VALUE #( %key                           = <ls_keys>-%key
*                             %op-%update                    = lv_auth
*                             %action-acceptTravel           = lv_auth
*                             %action-rejectTravel           = lv_auth
*                             %action-createTravelByTemplate = lv_auth
*                             %assoc-_Booking                = lv_auth ).
*
*    ENDLOOP.
*
*  ENDMETHOD.

  METHOD acceptTravel.

*   Modify in Local Mode - BO - related updates there are not relevant autorization objects
    MODIFY ENTITIES OF z_i_travel_2985 IN LOCAL MODE
                ENTITY Travel
         UPDATE FIELDS ( TravelStatus )
            WITH VALUE #( FOR mod_row IN keys ( travelid = mod_row-travelid
                                                 TravelStatus = 'A' ) ) "Accepted
                FAILED failed
              REPORTED reported.

    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
              ENTITY Travel
              FIELDS ( agencyid
                       customerid
                       begindate
                       enddate
                       bookingfee
                       totalprice
                       currencycode
                       TravelStatus
                       description
                       createdby
                       createdat
                       LastChangedBy
                       LastChangedAt )
     WITH VALUE #( FOR read_row IN keys ( travelid = read_row-travelid ) )
                RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travelid = ls_travel-travelid
                                                   %param = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travelid.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
      APPEND VALUE #( travelid = <ls_travel>-travelid
                      %msg = new_message(
                               id       = 'Z_MC_TRAVEL_2985'
                               number   = '005'
                               severity = if_abap_behv_message=>severity-success
                               v1       = lv_travel_msg )
                      %element-travelid = if_abap_behv=>mk-on
                    ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

*  METHOD rejectTravel.
*
*   Modify in Local Mode - BO - related updates there are not relevant autorization objects
*    MODIFY ENTITIES OF z_i_travel_2985 IN LOCAL MODE
*                ENTITY Travel
*         UPDATE FIELDS ( TravelStatus )
*            WITH VALUE #( FOR mod_row IN keys ( travelid = mod_row-travelid
*                                                TravelStatus = 'X' ) ) "Rejected
*                FAILED failed
*              REPORTED reported.
* Se realiza la lectura de los datos modificados para volcarlos en un tabla interna
*    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
*              ENTITY Travel
*              FIELDS ( agencyid
*                       customerid
*                       begindate
*                       enddate
*                       bookingfee
*                       totalprice
*                       currencycode
*                       TravelStatus
*                       description
*                       createdby
*                       createdat
*                       LastChangedBy
*                       LastChangedAt )
*     WITH VALUE #( FOR read_row IN keys ( travelid = read_row-travelid ) )
*                RESULT DATA(lt_travel).
* Se realiza la asignación de datos para se visualizados en la capa de persistencia
*    result = VALUE #( FOR ls_travel IN lt_travel ( travelid = ls_travel-travelid
*                                                   %param = ls_travel ) ).
*
*    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*
*      DATA(lv_travel_msg) = <ls_travel>-travelid.
*      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.
*      APPEND VALUE #( travelid = <ls_travel>-travelid
*                      %msg = new_message(
*                               id       = 'Z_MC_TRAVEL_2985'
*                               number   = '006'
*                               severity = if_abap_behv_message=>severity-success
*                               v1       = lv_travel_msg )
*                      %element-travelid = if_abap_behv=>mk-on
*                    ) TO reported-travel.
*
*    ENDLOOP.
*
*  ENDMETHOD.

  METHOD createTravelByTemplate.

* keys[ 1 ]-
* result[ 1 ]-
* mapped-
* failed-
* reported-

    READ ENTITIES OF z_i_travel_2985
         ENTITY Travel
         FIELDS ( travelid agencyid customerid bookingfee totalprice currencycode )
         WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
         RESULT DATA(lt_entity_travel)
         FAILED failed
         REPORTED reported.
    CHECK failed IS INITIAL.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_2985\\Travel.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    SELECT MAX( travel_id ) FROM ztb_travel_2985 INTO @DATA(lv_travelid).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO lv_index
                               ( travelid      = lv_travelid + lv_index
                                 agencyid      = create_row-agencyid
                                 customerid    = create_row-customerid
                                 begindate     = lv_today
                                 enddate       = lv_today + 30
                                 bookingfee    = create_row-bookingfee
                                 totalprice    = create_row-totalprice
                                 currencycode  = create_row-currencycode
                                 description    = 'Add comments'
                                 TravelStatus = 'O' ) ).

    MODIFY ENTITIES OF z_i_travel_2985
  IN LOCAL MODE ENTITY Travel
         CREATE FIELDS ( travelid
                         agencyid
                         customerid
                         begindate
                         enddate
                         bookingfee
                         totalprice
                         currencycode
                         description
                         TravelStatus )
                  WITH lt_create_travel
                MAPPED mapped
                FAILED failed
              REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO lv_idx
                    ( %cid_ref = keys[ lv_idx ]-%cid_ref
                          %key = keys[ lv_idx ]-%key
                        %param = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
              ENTITY Travel
              FIELDS ( customerid )
                WITH CORRESPONDING #( keys )
              RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customerid EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
                  FOR ALL ENTRIES IN @lt_customer
                               WHERE customer_id = @lt_customer-customer_id
                          INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-customerid IS INITIAL OR
         NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-customerid ] ).

        APPEND VALUE #( travelid = <ls_travel>-travelid ) TO failed-travel.

        APPEND VALUE #( travelid = <ls_travel>-travelid
                        %msg = new_message(
                                 id       = 'Z_MC_TRAVEL_2985'
                                 number   = '001'
                                 severity = if_abap_behv_message=>severity-error
                                 v1       = <ls_travel>-customerid )
                        %element-customerid = if_abap_behv=>mk-on
                      ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
            ENTITY Travel
            FIELDS ( begindate enddate )
              WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
            RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-enddate LT ls_travel_result-begindate.

        APPEND VALUE #( %key      = ls_travel_result-%key
                        travelid = ls_travel_result-travelid )
                    TO failed-travel.

        APPEND VALUE #( %key      = ls_travel_result-%key
                        travelid = ls_travel_result-travelid
                        %msg = new_message(
                                 id       = 'Z_MC_TRAVEL_2985'
                                 number   = '004'
                                 severity = if_abap_behv_message=>severity-error
                                 v1       = ls_travel_result-begindate
                                 v2       = ls_travel_result-enddate
                                 v3       = ls_travel_result-travelid )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on
                      ) TO reported-travel.

      ELSEIF ls_travel_result-begindate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key      = ls_travel_result-%key
                        travelid = ls_travel_result-travelid )
                    TO failed-travel.

        APPEND VALUE #( %key      = ls_travel_result-%key
                        travelid = ls_travel_result-travelid
                        %msg = new_message(
                                 id       = 'Z_MC_TRAVEL_2985'
                                 number   = '002'
                                 severity = if_abap_behv_message=>severity-error
                                 v1       = ls_travel_result-begindate )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on
                      ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
              ENTITY Travel
              FIELDS ( TravelStatus )
          WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
              RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-TravelStatus.

        WHEN 'O'. "Open
        WHEN 'X'. "Cancelled
        WHEN 'A'. "Accepted

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.

          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message(
                                   id       = 'Z_MC_TRAVEL_2985'
                                   number   = '003'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = ls_travel_result-TravelStatus )
                          %element-TravelStatus = if_abap_behv=>mk-on
                        ) TO reported-travel.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculatetotalprice.
    MODIFY ENTITIES OF z_i_travel_2985 IN LOCAL MODE
         ENTITY travel
           EXECUTE recalcTotalPrice
           FROM CORRESPONDING #( keys )
         REPORTED DATA(execute_reported).

    reported = CORRESPONDING #( DEEP execute_reported ).
  ENDMETHOD.

  METHOD calculatetravelid.
    " Please note that this is just an example for calculating a field during onSave.
    " This approach does NOT ensure for gap free or unique travel IDs! It just helps to provide a readable ID.
    " The key of this business object is a UUID, calculated by the framework.

    " check if TravelID is already filled
    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelID ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    " remove lines where TravelID is already filled.
    DELETE travels WHERE TravelID IS NOT INITIAL.

    " anything left ?
    CHECK travels IS NOT INITIAL.

    " Select max travel ID
    SELECT SINGLE
        FROM ztb_travel_2985
        FIELDS MAX( travel_id ) AS travelID
        INTO @DATA(max_travelid).

    " Set the travel ID
    MODIFY ENTITIES OF z_i_travel_2985 IN LOCAL MODE
    ENTITY Travel
      UPDATE
        FROM VALUE #( FOR travel IN travels INDEX INTO i (
          %tky              = travel-%tky
          TravelID          = max_travelid + i
          %control-TravelID = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD get_authorizations.
    DATA: has_before_image    TYPE abap_bool,
          is_update_requested TYPE abap_bool,
          is_delete_requested TYPE abap_bool,
          update_granted      TYPE abap_bool,
          delete_granted      TYPE abap_bool.

    DATA: failed_travel LIKE LINE OF failed-travel.

    " Read the existing travels
    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED failed.

    CHECK travels IS NOT INITIAL.
*
**   In this example the authorization is defined based on the Activity + Travel Status
**   For the Travel Status we need the before-image from the database. We perform this for active (is_draft=00) as well as for drafts (is_draft=01) as we can't distinguish between edit or new drafts
*    SELECT FROM zrap_atrav_####
*      FIELDS travel_uuid,overall_status
*      FOR ALL ENTRIES IN @travels
*      WHERE travel_uuid EQ @travels-TravelUUID
*      ORDER BY PRIMARY KEY
*      INTO TABLE @DATA(travels_before_image).
*
*    is_update_requested = COND #( WHEN requested_authorizations-%update              = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%action-acceptTravel = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%action-rejectTravel = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%action-Prepare      = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%action-Edit         = if_abap_behv=>mk-on OR
*                                       requested_authorizations-%assoc-_Booking      = if_abap_behv=>mk-on
*                                  THEN abap_true ELSE abap_false ).
*
*    is_delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
*                                  THEN abap_true ELSE abap_false ).
*
*    LOOP AT travels INTO DATA(travel).
*      update_granted = delete_granted = abap_false.
*
*      READ TABLE travels_before_image INTO DATA(travel_before_image)
*       WITH KEY travel_uuid = travel-TravelUUID BINARY SEARCH.
*      has_before_image = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
*
*      IF is_update_requested = abap_true.
*        " Edit of an existing record -> check update authorization
*        IF has_before_image = abap_true.
*          update_granted = is_update_granted( has_before_image = has_before_image  overall_status = travel_before_image-overall_status ).
*          IF update_granted = abap_false.
*            APPEND VALUE #( %tky        = travel-%tky
*                            %msg        = NEW zcm_rap_####( severity = if_abap_behv_message=>severity-error
*                                                            textid   = zcm_rap_####=>unauthorized )
*                          ) TO reported-travel.
*          ENDIF.
*          " Creation of a new record -> check create authorization
*        ELSE.
*          update_granted = is_create_granted( ).
*          IF update_granted = abap_false.
*            APPEND VALUE #( %tky        = travel-%tky
*                            %msg        = NEW zcm_rap_####( severity = if_abap_behv_message=>severity-error
*                                                            textid   = zcm_rap_####=>unauthorized )
*                          ) TO reported-travel.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      IF is_delete_requested = abap_true.
*        delete_granted = is_delete_granted( has_before_image = has_before_image  overall_status = travel_before_image-overall_status ).
*        IF delete_granted = abap_false.
*          APPEND VALUE #( %tky        = travel-%tky
*                          %msg        = NEW zcm_rap_####( severity = if_abap_behv_message=>severity-error
*                                                          textid   = zcm_rap_####=>unauthorized )
*                        ) TO reported-travel.
*        ENDIF.
*      ENDIF.
*
*      APPEND VALUE #( %tky = travel-%tky
*
*                      %update              = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                      %action-acceptTravel = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                      %action-rejectTravel = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                      %action-Prepare      = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                      %action-Edit         = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                      %assoc-_Booking      = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*
*                      %delete              = COND #( WHEN delete_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
*                    )
*        TO result.
*    ENDLOOP.

  ENDMETHOD.

  METHOD get_features.

  ENDMETHOD.

  METHOD is_create_granted.
* AUTHORITY-CHECK OBJECT 'ZOSTAT####'
*      ID 'ZOSTAT####' DUMMY
*      ID 'ACTVT' FIELD '01'.
*    create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
*
*    " Simulate full access - for testing purposes only! Needs to be removed for a productive implementation.
*    create_granted = abap_true.
  ENDMETHOD.

  METHOD is_delete_granted.
* IF has_before_image = abap_true.
*      AUTHORITY-CHECK OBJECT 'ZOSTAT####'
*        ID 'ZOSTAT####' FIELD travel_status
*        ID 'ACTVT' FIELD '06'.
*    ELSE.
*      AUTHORITY-CHECK OBJECT 'ZOSTAT####'
*        ID 'ZOSTAT####' DUMMY
*        ID 'ACTVT' FIELD '06'.
*    ENDIF.
*    delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
*
*    " Simulate full access - for testing purposes only! Needs to be removed for a productive implementation.
*    delete_granted = abap_true.
  ENDMETHOD.

  METHOD is_update_granted.
* IF has_before_image = abap_true.
*      AUTHORITY-CHECK OBJECT 'ZOSTAT####'
*        ID 'ZOSTAT####' FIELD travel_status
*        ID 'ACTVT' FIELD '02'.
*    ELSE.
*      AUTHORITY-CHECK OBJECT 'ZOSTAT####'
*        ID 'ZOSTAT####' DUMMY
*        ID 'ACTVT' FIELD '02'.
*    ENDIF.
*    update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
*
*    " Simulate full access - for testing purposes only! Needs to be removed for a productive implementation.
*    update_granted = abap_true.
  ENDMETHOD.

  METHOD recalctotalprice.
    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amount_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF  z_i_travel_2985 IN LOCAL MODE
         ENTITY Travel
            FIELDS ( BookingFee CurrencyCode )
            WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    DELETE travels WHERE CurrencyCode IS INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      " Set the start for the calculation by adding the booking fee.
      amount_per_currencycode = VALUE #( ( amount        = <travel>-BookingFee
                                           currency_code = <travel>-CurrencyCode ) ).

      " Read all associated bookings and add them to the total price.
      READ ENTITIES OF  z_i_travel_2985 IN LOCAL MODE
        ENTITY Travel BY \_Booking
          FIELDS ( FlightPrice CurrencyCode )
        WITH VALUE #( ( %tky = <travel>-%tky ) )
        RESULT DATA(bookings).

      LOOP AT bookings INTO DATA(booking) WHERE CurrencyCode IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) INTO amount_per_currencycode.
      ENDLOOP.

      CLEAR <travel>-TotalPrice.
      LOOP AT amount_per_currencycode INTO DATA(single_amount_per_currencycode).
        " If needed do a Currency Conversion
        IF single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += single_amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
             EXPORTING
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF  z_i_travel_2985 IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( travels ).
  ENDMETHOD.

  METHOD setinitialstatus.
    " Read relevant travel instance data
    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    " Remove all travel instance data with defined status
    DELETE travels WHERE TravelStatus IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    " Set default travel status
    MODIFY ENTITIES OF z_i_travel_2985 IN LOCAL MODE
    ENTITY Travel
      UPDATE
        FIELDS ( TravelStatus )
        WITH VALUE #( FOR travel IN travels
                      ( %tky         = travel-%tky
                        TravelStatus = travel_status-open ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD validateagency.
    " Read relevant travel instance data
    READ ENTITIES OF z_i_travel_2985 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( AgencyID ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DATA agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    " Optimization of DB select: extract distinct non-initial agency IDs
    agencies = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING agency_id = AgencyID EXCEPT * ).
    DELETE agencies WHERE agency_id IS INITIAL.

    IF agencies IS NOT INITIAL.
      " Check if agency ID exist
      SELECT FROM /dmo/agency FIELDS agency_id
        FOR ALL ENTRIES IN @agencies
        WHERE agency_id = @agencies-agency_id
        INTO TABLE @DATA(agencies_db).
    ENDIF.

    " Raise msg for non existing and initial agencyID
    LOOP AT travels INTO DATA(travel).
      " Clear state messages that might exist
      APPEND VALUE #(  %tky               = travel-%tky
                       %state_area        = 'VALIDATE_AGENCY' )
        TO reported-travel.

      IF travel-AgencyID IS INITIAL OR NOT line_exists( agencies_db[ agency_id = travel-AgencyID ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY'
                        %msg        = NEW zcm_validate_agency(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_validate_agency=>agency_unknown
                                          agencyid = travel-AgencyID )
                        %element-AgencyID = if_abap_behv=>mk-on )
          TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2985 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS:
      gc_create TYPE string VALUE 'CREATE',
      gc_update TYPE string VALUE 'UPDATE',
      gc_delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2985 IMPLEMENTATION.

  METHOD save_modified.
    DATA: lt_travel_log   TYPE STANDARD TABLE OF ztb_log_2985,
          lt_travel_log_u TYPE STANDARD TABLE OF ztb_log_2985.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

* Create
    IF NOT create-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_create>).

* Se obtiene fecha y hora para la creación del registro en auditoria.
        GET TIME STAMP FIELD <fs_create>-created_at.

* Se le indica la operación realizada
        <fs_create>-changing_operation = lsc_Z_I_TRAVEL_2985=>gc_create.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS TravelId = <fs_create>-travel_id
        INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.

            <fs_create>-changed_field_name = 'BookingFee'.
            <fs_create>-changed_value      = ls_travel-BookingFee.
            <fs_create>-user_mod           = lv_user.

            TRY.
                <fs_create>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <fs_create> TO lt_travel_log_u.

          ENDIF.

        ENDIF.


      ENDLOOP.

    ENDIF.

* Update
    IF NOT update-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travel_id = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<fs_update>).

* Se obtiene fecha y hora para la modificación del registro en auditoria.
        GET TIME STAMP FIELD <fs_update>-created_at.

* Se le indica la operación realizada
        <fs_update>-changing_operation = lsc_Z_I_TRAVEL_2985=>gc_update.

        IF ls_update_travel-%control-CustomerId EQ cl_abap_behv=>flag_changed.

          <fs_update>-changed_field_name = 'CustomerId'.
          <fs_update>-changed_value      = ls_update_travel-CustomerId.
          <fs_update>-user_mod           = lv_user.

          TRY.
              <fs_update>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <fs_update> TO lt_travel_log_u.
         ENDIF.
    ENDLOOP.
 ENDIF.

* Delete
    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_delete>).
* Se obtiene fecha y hora para la eliminación del registro en auditoria.
        GET TIME STAMP FIELD <fs_delete>-created_at.
* Se le indica la operación realizada
        <fs_delete>-changing_operation = lsc_Z_I_TRAVEL_2985=>gc_delete.
        <fs_delete>-user_mod           = lv_user.
        TRY.
            <fs_delete>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <fs_delete> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT ztb_log_2985 FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.


ENDCLASS.
