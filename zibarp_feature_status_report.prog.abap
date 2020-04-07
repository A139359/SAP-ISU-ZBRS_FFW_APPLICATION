*&---------------------------------------------------------------------*
*& Report  ZIBARP_FEATURE_STATUS_REPORT
*&
*&---------------------------------------------------------------------*
*& Display Feature Framework and which features are active or deactive.
*&
*&---------------------------------------------------------------------*
REPORT zibarp_feature_status_report.

*-------------------------------------------------------------------------------
DEFINE add_selection.
* &1: field selection table
* &2: field_name
* &3: value
  clear gs_selection.
*    if &3 is not initial.
  if &3 ca '?'.
    replace all occurrences of '?' in &3 with '+'.
  endif.
  gs_selection-queryfield = &2.
  gs_selection-sign   = 'I'.
  if &3 ca '*+'.
    gs_selection-option = 'CP'.
  else.
    gs_selection-option = 'EQ'.
  endif.
  gs_selection-low    = &3.
  insert gs_selection into table &1.
*    endif.
END-OF-DEFINITION.
*-------------------------------------------------------------------------------

TYPES:
  BEGIN OF ts_output,
    status        TYPE  icon_d,
    feature_desc  TYPE  string,
    name          TYPE  string,
    fn_id         TYPE  string, " this is the feature ID
    id            TYPE  string,
    fn_name       TYPE  string,
*    valid_from                  TYPE  string,
*    valid_to                    TYPE  string,
*    dependent_id                TYPE  string,
*    dependent_version           TYPE  string,
*    dependent_relation_category TYPE  string,
*    document_narration          TYPE  string,
*    document_version            TYPE  string,
*    document_type               TYPE  string,
*    document_url                TYPE  string,
    changed_by    TYPE  string,
    changed_on    TYPE  string,
    created_by    TYPE  string,
    created_on    TYPE  string,
    days_inactive TYPE  string,
  END OF ts_output.

DATA go_function_query TYPE REF TO cl_fdt_query.
DATA:
              gt_s_selection TYPE if_fdt_query=>ts_selection,
              gs_selection   TYPE if_fdt_query=>s_selection,
              gt_functions   TYPE STANDARD TABLE OF if_fdt_query=>s_object_type.
DATA:
  gv_id       TYPE          fdt_uuid,
  gv_name     TYPE          fdt_name,
  gv_devclass TYPE          fdt_appl_0000-devel_package,
  BEGIN OF gs_repo,
    name TYPE          string,
    id   TYPE          string,
  END OF gs_repo,
  gt_repo       LIKE TABLE OF gs_repo,
  gt_output     TYPE TABLE OF ts_output,
  gs_output     LIKE LINE OF  gt_output,
  go_alv        TYPE REF TO   cl_salv_table ##NEEDED,
  go_display    TYPE REF TO   cl_salv_display_settings ##NEEDED,
  go_columns    TYPE REF TO   cl_salv_columns_table ##NEEDED,
  go_column     TYPE REF TO   cl_salv_column_table ##NEEDED,
  go_root       TYPE REF TO   cx_root ##NEEDED.

*DATA: lts_foae TYPE if_fdt_query=>ts_foae_cond,
*      ls_foae  TYPE if_fdt_query=>s_foae_cond.
**      lt_appln_list TYPE STANDARD TABLE OF s_appln_list,
**      ls_appln_list TYPE          s_appln_list.

SELECT-OPTIONS:
  s_ffid        FOR gv_id       NO INTERVALS,
  s_name        FOR gv_name     NO INTERVALS,
  s_pkge        FOR gv_devclass NO INTERVALS DEFAULT 'ZBRS_FFW_APPLICATION'.

START-OF-SELECTION.

  FREE:
    gt_output.
* ******************************************************************************************************************************** *
* Should be some sort of API to BRF+ to do this but can't find it. Whe I do or someone else does this code can be simplified.      *
* if_fdt_query~select_data looks like the way. But it looks like you cannot search on Package in the query...... Still trying      *
  SELECT name, fdt_appl_0000~id
    FROM fdt_appl_0000
   INNER JOIN fdt_admn_0000 ON fdt_admn_0000~id EQ fdt_appl_0000~id
   WHERE devel_package IN @s_pkge
    AND  fdt_appl_0000~id IN @s_ffid
    AND  fdt_admn_0000~name IN @s_name
    INTO TABLE @DATA(gt_0000).
  SELECT name, fdt_appl_0000a~id
    INTO TABLE @DATA(gt_0000a)
    FROM fdt_appl_0000a
    INNER JOIN fdt_admn_0000a ON fdt_admn_0000a~id EQ fdt_appl_0000a~id
   WHERE devel_package IN @s_pkge
         AND  fdt_admn_0000a~name IN @s_name
     AND  fdt_appl_0000a~id IN @s_ffid.
  SELECT name, fdt_appl_0000s~id
    INTO TABLE @DATA(gt_0000s)
    FROM fdt_appl_0000s
    INNER JOIN fdt_admn_0000s ON fdt_admn_0000s~id EQ fdt_appl_0000s~id
   WHERE devel_package IN @s_pkge
        AND  fdt_admn_0000s~name IN @s_name
     AND  fdt_appl_0000s~id IN @s_ffid.
  SELECT name, fdt_appl_0000t~id
    INTO TABLE @DATA(gt_0000t)
    FROM fdt_appl_0000t
    INNER JOIN fdt_admn_0000t ON fdt_admn_0000t~id EQ fdt_appl_0000t~id
   WHERE devel_package IN @s_pkge
        AND  fdt_admn_0000t~name IN @s_name
     AND  fdt_appl_0000t~id IN @s_ffid.

  LOOP AT gt_0000 INTO DATA(gs_0000).
    MOVE-CORRESPONDING gs_0000 TO gs_repo.
    APPEND gs_repo TO gt_repo.
  ENDLOOP.

  LOOP AT gt_0000a INTO DATA(gs_0000a).
    MOVE-CORRESPONDING gs_0000a TO gs_repo.
    APPEND gs_repo TO gt_repo.
  ENDLOOP.

  LOOP AT gt_0000s INTO DATA(gs_0000s).
    MOVE-CORRESPONDING gs_0000s TO gs_repo.
    APPEND gs_repo TO gt_repo.
  ENDLOOP.

  LOOP AT gt_0000t INTO DATA(gs_0000t).
    MOVE-CORRESPONDING gs_0000t TO gs_repo.
    APPEND gs_repo TO gt_repo.
  ENDLOOP.

  SORT gt_repo BY name id.
  DELETE ADJACENT DUPLICATES FROM gt_repo.
* ******************************************************************************************************************************** *

* Build Output Table.
  LOOP AT gt_repo INTO gs_repo.
    TRY.
        FREE gt_functions.
        FREE gt_s_selection.
        add_selection gt_s_selection if_fdt_admin_data_query=>gc_fn_application_id gs_repo-id.
        go_function_query ?= cl_fdt_query=>get_instance( iv_object_type    = if_fdt_constants=>gc_object_type_function ).

        go_function_query->if_fdt_query~select_data(
                           EXPORTING its_selection  = gt_s_selection
                           IMPORTING eta_data       = gt_functions ).
*       Add all function in application. Ok for performanc because noramllt there will be 1 not expecting more than 10.
        LOOP AT gt_functions INTO DATA(gs_functions).
          MOVE-CORRESPONDING gs_repo TO gs_output.
          gs_output-fn_id = gs_functions-id.
          cl_fdt_factory=>get_id_information( EXPORTING iv_id   = gs_functions-id
                                              IMPORTING ev_name = DATA(gv_fn_name) ).
          gs_output-fn_name = gv_fn_name.
          APPEND gs_output TO gt_output.
        ENDLOOP.
      CATCH cx_fdt_input .
        CONTINUE.
    ENDTRY.

  ENDLOOP.

  DATA go_admin_data TYPE REF TO if_fdt_admin_data.

* Check status.
  LOOP AT gt_output ASSIGNING FIELD-SYMBOL(<gs_output>).

    go_admin_data = cl_fdt_wd_service=>get_admin_data( iv_id = |{ <gs_output>-id }| ).

    go_admin_data->get_change_info( IMPORTING ev_change_user        = DATA(gv_change_user)
                                              ev_change_timestamp   = DATA(gv_change_timestamp)
                                              ev_creation_user      = DATA(gv_created_user)
                                              ev_creation_timestamp = DATA(gv_created_timestamp)
                                  ).

    go_admin_data->get_texts( IMPORTING ev_short_text = DATA(gv_short_text)
                                        ev_text       = DATA(gv_text)
                            ).
    <gs_output>-feature_desc = COND string( WHEN gv_text IS NOT INITIAL THEN gv_text
                                            ELSE gv_short_text
                                          ).
    <gs_output>-changed_by = gv_change_user.
    CALL FUNCTION 'CONVERSION_EXIT_TSTPS_OUTPUT'
      EXPORTING
        input  = gv_change_timestamp
      IMPORTING
        output = <gs_output>-changed_on.
    <gs_output>-created_by = gv_created_user.
    CALL FUNCTION 'CONVERSION_EXIT_TSTPS_OUTPUT'
      EXPORTING
        input  = gv_created_timestamp
      IMPORTING
        output = <gs_output>-created_on.
    IF zcl_iba_ffw_brf_factory=>is_feature_active( |{ <gs_output>-fn_id }| ) = abap_true.
      <gs_output>-status = icon_led_green.
    ELSE.
      <gs_output>-status = icon_led_red.
    ENDIF.
  ENDLOOP.

END-OF-SELECTION.

  TRY.

      CALL METHOD cl_salv_table=>factory
*    EXPORTING
*      r_container  = cl_gui_container=>screen0
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_output.

*     Set Report Header details
      PERFORM f_set_report_header.

      go_columns = go_alv->get_columns( ).
      go_columns->set_optimize( ).

*     Set column attributes
      PERFORM f_set_column_heading.
      PERFORM f_hide_columns.

      go_display = go_alv->get_display_settings( ).
      go_display->set_striped_pattern( value = 'X' ).

      go_alv->display( ).
    CATCH cx_root ##NO_HANDLER ##CATCH_ALL.
  ENDTRY.

*&---------------------------------------------------------------------*
*&      Form  F_SET_COLUMN_HEADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_column_heading .
  TRY.
      TRY.
          go_column ?= go_columns->get_column( 'STATUS' ).
          go_column->set_long_text( text-h01 ).
          go_column->set_alignment( if_salv_c_alignment=>centered ).
          go_column ?= go_columns->get_column( 'ID' ).
          go_column->set_long_text( text-h11 ).
          go_column ?= go_columns->get_column( 'NAME' ).
          go_column->set_long_text( text-h10 ).
          go_column ?= go_columns->get_column( 'FN_ID' ).
          go_column->set_long_text( text-h02 ).
          go_column ?= go_columns->get_column( 'FN_NAME' ).
          go_column->set_long_text( text-h12 ).
          go_column ?= go_columns->get_column( 'CHANGED_BY' ).
          go_column->set_long_text( text-h13 ).
          go_column ?= go_columns->get_column( 'CHANGED_ON' ).
          go_column->set_alignment( if_salv_c_alignment=>centered ).
          go_column->set_long_text( text-h14 ).
          go_column ?= go_columns->get_column( 'CREATED_BY' ).
          go_column->set_long_text( text-h15 ).
          go_column ?= go_columns->get_column( 'CREATED_ON' ).
          go_column->set_long_text( text-h16 ).
          go_column->set_alignment( if_salv_c_alignment=>centered ).
          go_column ?= go_columns->get_column( 'FEATURE_DESC' ).
          go_column->set_long_text( text-h03 ).
*          go_column ?= go_columns->get_column( 'VALIDTO-DATE' ).
*          go_column->set_long_text( text-h04 ).
*          go_column ?= go_columns->get_column( 'VALIDTO-TIME' ).
*          go_column->set_long_text( text-h05 ).
*          go_column ?= go_columns->get_column( 'VALIDFROM-DATE' ).
*          go_column->set_long_text( text-h06 ).
*          go_column ?= go_columns->get_column( 'VALIDFROM-TIME' ).
*          go_column->set_long_text( text-h07 ).
*          go_column ?= go_columns->get_column( 'DEPENDID' ).
*          go_column->set_long_text( text-h08 ).
*          go_column ?= go_columns->get_column( 'DEPENDDESC' ).
*          go_column->set_long_text( text-h09 ).
        CATCH cx_salv_not_found  ##NO_HANDLER.
      ENDTRY.
    CATCH cx_salv_not_found ##NO_HANDLER.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_HIDE_COLUMNS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hide_columns .
  TRY.
*     Hide the application ID.
      go_column ?= go_columns->get_column( 'ID' ).
      go_column->set_visible( abap_false ).
    CATCH cx_salv_not_found  ##NO_HANDLER.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SET_REPORT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_report_header .
  DATA:
    lo_top_element TYPE REF TO cl_salv_form_layout_grid,
    lv_date        TYPE        string,
    lv_time        TYPE        char10.

  CREATE OBJECT lo_top_element
    EXPORTING
      columns = 1.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal = sy-datum
    IMPORTING
      date_external = lv_date.

  WRITE sy-uzeit TO lv_time USING EDIT MASK '__:__:__'.
  lo_top_element->create_header_information(
      row = 1
      column = 1
      text     = |{ text-001 } { lv_date } { lv_time }| ).
  TRY.
      go_alv->set_top_of_list( lo_top_element ).
    CATCH cx_root  ##NO_HANDLER ##CATCH_ALL.
  ENDTRY.
ENDFORM.
