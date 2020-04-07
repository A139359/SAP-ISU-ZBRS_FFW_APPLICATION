interface ZIF_IBA_FFW_BRF_FACTORY
  public .


  types:
    BEGIN OF ts_gnv,
      group TYPE text255,
      name  TYPE text255,
      value TYPE text255,
    END OF ts_gnv .
  types:
    tt_gnv TYPE STANDARD TABLE OF ts_gnv WITH NON-UNIQUE DEFAULT KEY .

  class-methods IS_FEATURE_ACTIVE
    importing
      !IV_ID type IF_FDT_TYPES=>ID
      !IT_GNV type ZIF_IBA_FFW_BRF_FACTORY=>TT_GNV optional
    returning
      value(RV_RESULT) type ABAP_BOOL .
  class-methods IS_FEATURE_ACTIVE_ALL
    importing
      !IV_ID type IF_FDT_TYPES=>ID
      !IV_VER type STRING default '1'
      !IT_GNV type ZIF_IBA_FFW_BRF_FACTORY=>TT_GNV optional
    returning
      value(RV_RESULT) type ABAP_BOOL .
endinterface.
