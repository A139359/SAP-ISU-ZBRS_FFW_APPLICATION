class ZCL_IBA_FFW_BRF_EXIT definition
  public
  create public .

public section.

  interfaces IF_FDT_APPLICATION_SETTINGS .

  class-methods CLASS_CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IBA_FFW_BRF_EXIT IMPLEMENTATION.


  method CLASS_CONSTRUCTOR.
*   Add flags here to turn on the methods.
    if_fdt_application_settings~gv_get_changeability = abap_true.
    if_fdt_application_settings~gv_authority_check   = abap_false.
  endmethod.


  method IF_FDT_APPLICATION_SETTINGS~ACTIVATION_VETO.
  endmethod.


  METHOD if_fdt_application_settings~authority_check.
*    De-activated due to possibility of using Std Object.
*    DATA(lv_activity) = zcl_iba_ffw_brf_tools=>get_instance( )->get_mapped_activity( iv_activity ).
*    AUTHORITY-CHECK OBJECT 'Z_FFW'
*      ID 'ACTVT' FIELD lv_activity.
*    IF sy-subrc EQ 0.
*      ev_passed     = abap_true.
*      ev_skip_check = abap_true. "Need this to skip generic BRF check.
*    ELSE.
*      ev_passed     = abap_false.
*      ev_skip_check = abap_false.
*    ENDIF.

  ENDMETHOD.


  METHOD IF_FDT_APPLICATION_SETTINGS~GET_CHANGEABILITY.
*   Check if transport is required.
    IF zcl_iba_ffw_brf_tools=>get_instance( )->is_transport_required( ) EQ abap_true.
      cv_changeable       = abap_true.
      cv_change_recording = abap_true.
    ELSE.
      cv_changeable       = abap_true.
      cv_change_recording = abap_false.
    ENDIF.

*   Check if template if so display a message warning.
    IF zcl_iba_ffw_brf_tools=>get_instance( )->is_template( iv_application_id ) EQ abap_true.
      APPEND LINES OF zcl_iba_ffw_brf_tools=>get_instance( )->get_template_change_message( ) TO ct_message.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
