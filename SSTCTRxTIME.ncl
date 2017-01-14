
;************************************************
;get ncl functions
;************************************************
;get ncl basic ccsm functions
load "$NCLSCR/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCLSCR/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLSCR/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLSCR/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;get ncl ccsm remap functions
load "$NCLSCR/lib/ncarg/nclscripts/csm/popRemap.ncl"

;****************
;** USER INPUT **
;****************
minYear = 1942
maxYear = 1997
;****ENDINPUT****

nmon = (maxYear - minYear + 1) * 12 - 1

begin
  all_files = systemfunc( "ls /raid60/kirtman/HRC07/ocn/mo_nc4/HRC07.pop.{" + minYear +".." + maxYear + "}-*.nc" )
  file_list = addfiles(all_files, "r")                  ;adding all of our files
  ListSetType(file_list, "cat")

  sst = file_list[:]->TEMP(:,0,:,:)
  sst_all = where(sst.gt.1.0,sst,sst@_FillValue)
  copy_VarMeta(sst,sst_all)

  res                            = True       ; plot mods desired

  res@mpFillOn                   = False       ; color contentinents
  ;res@mpLandFillColor            = "gray55"
  ; res@mpFillColors               = (/0,9,28,9/); colors to draw
  res@mpOutlineOn                = True        ; turn on continental outlines
  res@mpOutlineBoundarySets      = "Geophysical"
  res@mpGridLineDashPattern      = 2           ; make lat/lon lines dash


  res@vpXF                       = 0.1         ; size of plot
  res@vpYF                       = 0.9
  res@vpWidthF                   = 0.8
  res@vpHeightF                  = 0.7
  res@cnLineThicknessF          = 1.10            ; change line thickness

  res@tiMainString    = "Monthly Average Sea Surface Temp x Time (C)" ; add title

  colors = (/"white", "firebrick","peachpuff","orangered","navyblue","peru",\
           "yellow","wheat1","gray55","thistle","coral","dodgerblue", \
           "seagreen","maroon","gold","turquoise","mediumorchid"/)
;   gsn_define_colormap(wks,"cosam")
;   gsn_define_colormap(wks,"amwg")
;   gsn_define_colormap(wks,"BrownBlue12")
;   gsn_define_colormap(wks,"BlueDarkRed18")
  res@gsnSpreadColors = True
  res@mpCenterLonF = 180.0 ; center the map on the date line
  ;   res@mpMinLonF = -100.0
  ;   res@mpMaxLonF = -55.0
  res@mpMinLatF = -60.0
  res@mpMaxLatF = 60.0
  ;
  res@lbLabelFontHeightF = 0.008 ; changing font size on color bar
  ;
  res@cnFillOn = True
  res@cnLinesOn = True
  res@cnLevelSelectionMode 	= "ExplicitLevels"  ; manually set cont levels
  res@cnLevels = (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34/)
  ;   res@cnMinLevelValF       	= 240               ; min lev
  ;   res@cnMaxLevelValF	        = 330              ; max lev
  ;   res@cnLevelSpacingF         = 1000		    ; spacing

  i=0
  do while(i.lt.nmon)
    wks = gsn_open_wks("png","map_plot_" + i)

    map = gsn_csm_contour_map(wks,sst_all(i,:,:),res)
    i = i + 1
    print("map " + i + " of " + nmon + " generated.")
  end do



end
