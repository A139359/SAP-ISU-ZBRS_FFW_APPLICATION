class ZCL_IBA_FFW_BRF_TOOLS definition
  public
  create private .

public section.

  class-methods GET_INSTANCE
    returning
      value(RO_RESULT) type ref to ZCL_IBA_FFW_BRF_TOOLS .
  methods IS_FEATURE_ON
    importing
      !IV_ID type IF_FDT_TYPES=>ID
      !IT_GNV type ZIF_IBA_FFW_BRF_FACTORY=>TT_GNV optional
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods IS_TRANSPORT_REQUIRED
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods GET_MAPPED_ACTIVITY
    importing
      !IV_ACTIVITY type IF_FDT_TYPES=>ACTIVITY
    returning
      value(RV_RESULT) type ACTIV_AUTH .
  methods GET_LOCKED_MESSAGE
    returning
      value(RT_RESULT) type IF_FDT_TYPES=>T_MESSAGE .
  methods GET_TEMPLATE_CHANGE_MESSAGE
    returning
      value(RT_RESULT) type IF_FDT_TYPES=>T_MESSAGE .
  methods IS_TEMPLATE
    importing
      !IV_APPLICATION_ID type IF_FDT_TYPES=>ID
    returning
      value(RV_RESULT) type ABAP_BOOL .
protected section.
private section.

  class-data GO_SELF type ref to ZCL_IBA_FFW_BRF_TOOLS .
ENDCLASS.



CLASS ZCL_IBA_FFW_BRF_TOOLS IMPLEMENTATION.


  method GET_INSTANCE.
*======================================================================*
* Name.......... Cast your eye 2 lines above near the method statment.
* Reference..... Bolt On
*======================================================================*
* OVERVIEW
* This method facilitates the singleton pattern.
*
*======================================================================*
*
* CHANGE HISTORY
*
* Date        Name         Reference   Description
* 18/03/2020  R.Marr       NA          Initial implementation
*
*======================================================================*
*    IF go_self IS NOT BOUND.
*      CREATE OBJECT go_self.
*    ENDIF.
    CREATE OBJECT go_self. " Alway create a new object as buffering BRF is most likely not required. i.e. BRF+ is buffered.
    ro_result = go_self.
  endmethod.


  METHOD get_locked_message.
    rt_result = VALUE if_fdt_types=>t_message( ( msgid = '00' msgno = '208' msgty = 'W' msgv1 = |Obsolete please use New Feature Framework.| ) ).
  ENDMETHOD.


  method GET_MAPPED_ACTIVITY.
*   Map BRF+ activity to the ACTIV_AUTH activities.
    CASE iv_activity.
      WHEN 1.
        rv_result = '01'.
      WHEN 2.
        rv_result = '02'.
      WHEN 3.
        rv_result = '03'.
      WHEN 4.
        rv_result = '06'.
      WHEN 5.
        rv_result = '63'.
      WHEN OTHERS.
        rv_result = '03'.
    ENDCASE.
  endmethod.


  method GET_TEMPLATE_CHANGE_MESSAGE.
    rt_result = VALUE if_fdt_types=>t_message( ( msgid = '00'
                                                 msgno = '001'
                                                 msgty = 'W'
                                                 msgv1 = |You are changing a FFW3 Template are you|
                                                 msgv2 = | sure you want to do this?|
                                               )
                                             ).
  endmethod.


  METHOD is_feature_on.
    DATA:
      lo_fdt_data  TYPE REF TO data,
      lo_flat_data TYPE REF TO data,
      lo_factory   TYPE REF TO cl_fdt_factory,
      lo_function  TYPE REF TO if_fdt_function,
      lo_context   TYPE REF TO if_fdt_context,
      lo_result    TYPE REF TO if_fdt_result,
      lv_result_id TYPE if_fdt_types=>id.

    lo_factory  ?= cl_fdt_factory=>get_instance( ).
    lo_function ?= lo_factory->if_fdt_factory~get_function( iv_id ).

    lo_context  ?= lo_function->get_process_context( ).

    lo_context->set_value( iv_name  = 'IT_GNV'
                           ir_value = REF #( it_gnv ) ).

    CLEAR lo_result.
    lo_function->process( EXPORTING io_context = lo_context
                          IMPORTING eo_result  = lo_result ).

    IF lo_result IS NOT BOUND.
      RETURN.
    ENDIF.

    CLEAR lv_result_id.
    lv_result_id = lo_function->get_result_data_object( ).

    IF lv_result_id IS INITIAL.
      RETURN.
    ENDIF.

    FIELD-SYMBOLS <lv_result> TYPE  data.
    lo_result->get_value( IMPORTING er_value = lo_fdt_data ).
    ASSIGN lo_fdt_data->* TO <lv_result>.
    rv_result = <lv_result>.

  ENDMETHOD.


  METHOD is_template.
    DATA:
      lt_templates   TYPE RANGE OF if_fdt_types=>id.

    REFRESH:
      lt_templates.

*   Only transports for Project landscapes.
    APPEND 'IEQ000D3AD1916A1EEA9CE0741613DA6A93' TO lt_templates.

    IF iv_application_id IN lt_templates.
      rv_result = abap_true.
    ELSE.
      rv_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD is_transport_required.
    DATA:
      lt_systems   TYPE RANGE OF syst_sysid.

    REFRESH:
      lt_systems.

*   Only transports for Project landscapes.
    APPEND 'IEQCD2' TO lt_systems.
    APPEND 'IEQID2' TO lt_systems.

    IF sy-sysid IN lt_systems.
      rv_result = abap_true.
    ELSE.
      rv_result = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
