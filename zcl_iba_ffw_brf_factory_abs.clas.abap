class ZCL_IBA_FFW_BRF_FACTORY_ABS definition
  public
  abstract
  create public .

public section.

  interfaces ZIF_IBA_FFW_BRF_FACTORY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IBA_FFW_BRF_FACTORY_ABS IMPLEMENTATION.


  METHOD zif_iba_ffw_brf_factory~is_feature_active.
*======================================================================*
* Name.......... Cast your eye 2 lines above near the method statment.
* Reference..... FFW
*======================================================================*
* OVERVIEW
* This method calls the FFW check.
*
*======================================================================*
*
* CHANGE HISTORY
*
* Date        Name         Reference   Description
* 30/03/2020  R.Marr       NA          Initial implementation
*
*======================================================================*
*   Check FFW3
    TRY.
        rv_result = zcl_iba_ffw_brf_tools=>get_instance( )->is_feature_on( iv_id  = iv_id
                                                                           it_gnv = it_gnv ).
      CATCH cx_root.
        rv_result = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD zif_iba_ffw_brf_factory~is_feature_active_all.
*======================================================================*
* Name.......... Cast your eye 2 lines above near the method statment.
* Reference..... FFW
*======================================================================*
* OVERVIEW
* This method calls the FFW for version 1 2 and 3. NB - There is a small
* performance impact for executing all checks.
*
*======================================================================*
*
* CHANGE HISTORY
*
* Date        Name         Reference   Description
* 30/03/2020  R.Marr       NA          Initial implementation
*
*======================================================================*
    DATA lv_ffw1 TYPE boole_d.
    DATA lv_ffw2 TYPE boole_d.

    DATA lv_system TYPE c.
    lv_system = sy-sysid.

*   Check FFW3
    TRY.
        DATA(lv_ffw3) = zcl_iba_ffw_brf_tools=>get_instance( )->is_feature_on( iv_id  = iv_id
                                                                               it_gnv = it_gnv ).
      CATCH cx_root.
*       Check In FFW2
        TRY.
            DATA(lv_ffw2_class) = |ZCL_{ lv_system }BA_FFW_RULES_FACTORY|.
            CALL METHOD (lv_ffw2_class)=>is_feature_on
              EXPORTING
                iv_id         = |{ iv_id }|
                iv_id_version = CONV dec6_2( iv_ver )
              RECEIVING
                rv_result     = lv_ffw2.
*          DATA(lv_ffw2) = zcl_iba_ffw_rules_factory=>is_feature_on( iv_id         = CONV #( iv_id )
*                                                                    iv_id_version = CONV dec6_2( iv_ver ) ).
          CATCH cx_root.
        ENDTRY.
        IF lv_ffw2 EQ abap_false.
*         Check In FFW1
          TRY.
              DATA(lv_ffw1_class) = |ZCL_{ lv_system }BA_FFW_RULES_FACTORY|.
              CALL METHOD (lv_ffw1_class)=>is_feature_active
                EXPORTING
                  iv_id     = |{ iv_id }|
                RECEIVING
                  rv_result = lv_ffw1.
*        DATA(lv_ffw1) = zcl_iba_ffw_rules_factory=>is_feature_active( CONV #( iv_id ) ).
            CATCH cx_root.
          ENDTRY.
        ENDIF.
    ENDTRY.
*   Check all the flags and if any are true set the return to true.
    rv_result = COND abap_bool( WHEN lv_ffw3 = abap_true THEN abap_true
                                WHEN lv_ffw2 = abap_true THEN abap_true
                                WHEN lv_ffw1 = abap_true THEN abap_true
                                ELSE abap_false ).
  ENDMETHOD.


  method ZIF_IBA_FFW_BRF_FACTORY~IS_FEATURE_ACTIVE_FFW123.
*======================================================================*
* Name.......... Cast your eye 2 lines above near the method statment.
* Reference..... FFW
*======================================================================*
* OVERVIEW
* This method calls the FFW for Versions 1,2 & 3. NB - There is a small
* performance impact to do this.
*
*======================================================================*
*
* CHANGE HISTORY
*
* Date        Name         Reference   Description
* 01/04/2020  R.Marr       NA          Initial implementation
*
*======================================================================*
    CASE iv_check_type.
      WHEN 'FFW1'.
*       Check In FFW1
        TRY.
            DATA(lv_ffw1) = zcl_iba_ffw_rules_factory=>is_feature_active( CONV #( iv_id ) ).
          CATCH cx_root.
        ENDTRY.
      WHEN 'FFW2'.
*       Check In FFW2
        TRY.
            IF iv_ver IS SUPPLIED.
              DATA(lv_ffw2) = zcl_iba_ffw_rules_factory=>is_feature_on( iv_id         = CONV #( iv_id )
                                                                        iv_id_version = CONV dec6_2( iv_ver ) ).
            ENDIF.
          CATCH cx_root.
        ENDTRY.
      WHEN 'FFW3'.
*       Check FFW3
        TRY.
            DATA(lv_ffw3) = zcl_iba_ffw_brf_tools=>get_instance( )->is_feature_on( iv_id  = iv_id
                                                                                   it_gnv = it_gnv ).
          CATCH cx_root.
        ENDTRY.
      WHEN 'ALL'.
*       Check In FFW1
        TRY.
            lv_ffw1 = zcl_iba_ffw_rules_factory=>is_feature_active( CONV #( iv_id ) ).
          CATCH cx_root.
        ENDTRY.
*       Check In FFW2
        TRY.
            IF iv_ver IS SUPPLIED.
              lv_ffw2 = zcl_iba_ffw_rules_factory=>is_feature_on( iv_id         = CONV #( iv_id )
                                                                  iv_id_version = CONV dec6_2( iv_ver ) ).
            ENDIF.
          CATCH cx_root.
        ENDTRY.
*       Check FFW3
        TRY.
            lv_ffw3 = zcl_iba_ffw_brf_tools=>get_instance( )->is_feature_on( iv_id  = iv_id
                                                                             it_gnv = it_gnv ).
          CATCH cx_root.
        ENDTRY.
    ENDCASE.

*   Check all the flags and if any are true set the return to true.
    rv_result = COND abap_bool( WHEN lv_ffw3 = abap_true THEN abap_true
                                WHEN lv_ffw2 = abap_true THEN abap_true
                                WHEN lv_ffw1 = abap_true THEN abap_true
                                ELSE abap_false ).
  endmethod.
ENDCLASS.
