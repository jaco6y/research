
print("Script by Jake Robertson")

;*****************************************
;* This Script Graphs Incriments of 10 years
;*   starting from the minYear (set by the user)
;*   to the maxYear (set by the user), usually
;*   set by the range of your data
;*****************************************



;************************************************
;get ncl functions
;************************************************
;get ncl basic ccsm functions
load "$NCLSCR/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCLSCR/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLSCR/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCLSCR/lib/ncarg/nclscripts/csm/shea_util.ncl"
;get ncl ccsm remap functions
load "$NCLSCR/lib/ncarg/nclscripts/csm/popRemap.ncl"

maxYear = 1972

;;;;;;;;;
;  USER INPUT FOR MIN YEAR.
;;;;;;;;;
minYear = 1942

if (((maxYear - minYear) % 10).ne.0) then
  print("ERROR: Please make sure your maxYear and minYear values are 10 years apart.")
  exit
end if

i = 1

begin
  do while (minYear.lt.maxYear)    

    if (minYear.gt.maxYear) then
      break
    end if

    print("Beginning graph " + i + " of years "+ minYear + "to " + (minYear + 10) +"... \n")

    all_files = systemfunc ( "ls /raid60/kirtman/HRC07/ocn/mo_nc4/HRC07.pop.{" + minYear + ".." + (minYear + 10) + "}-*.nc" )    ;
    fall = addfiles(all_files,"r")
    ListSetType (fall, "cat" )
    foo_temp      = fall[:]->TEMP(:,0,:,:)                                                         
    foo_all	= where(foo_temp.gt.1.0,foo_temp,foo_temp@_FillValue)                               ;
    copy_VarMeta(foo_temp,foo_all)                                                                  ;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INPUT FROM USER BELOW
    nmons = ( (minYear + 10) - minYear + 1) * 12 - 1 ;;; number of year * 12 - 1                    ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END INPUT FROM USER

    foo_clim     = clmMonTLL(foo_all(0:nmons,:,:))                                                  ; 
    foo_anom     = calcMonAnomTLL(foo_all(0:nmons,:,:),foo_clim)                                    ;
    foo 	 = foo_anom(nmons,:,:)

;;;;;;;;;;;;;;
    res                            = True       ; plot mods desired

    res@mpFillOn                   = True        ; color contentinents
    res@mpLandFillColor            = "gray55"
;   res@mpFillColors               = (/0,9,28,9/); colors to draw
    res@mpOutlineOn                = True        ; turn on continental outlines
    res@mpOutlineBoundarySets      = "Geophysical"  
    res@mpGridLineDashPattern      = 2           ; make lat/lon lines dash
	
	
    res@vpXF                       = 0.1         ; size of plot
    res@vpYF                       = 0.9
    res@vpWidthF                   = 0.8
    res@vpHeightF                  = 0.7
    res@cnLineThicknessF          = 1.10            ; change line thickness

    res@tiMainString    = "Monthly Mean Anomaly" ; add title

    wks = gsn_open_wks("png","fig_" + minYear + "-" + maxYear)
    colors = (/"white", "firebrick","peachpuff","orangered","navyblue","peru",\
             "yellow","wheat1","gray55","thistle","coral","dodgerblue", \
             "seagreen","maroon","gold","turquoise","mediumorchid"/)
;   gsn_define_colormap(wks,"cosam")
;   gsn_define_colormap(wks,"amwg")
;   gsn_define_colormap(wks,"BrownBlue12")
;   gsn_define_colormap(wks,"BlueDarkRed18")
    res@gsnSpreadColors = True
;   gsn_define_colormap(wks,colors)
    gsn_define_colormap(wks,"BlWhRe")

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
    res@cnLevels = (/ -2., -1.5, -1.0, -0.5, 0.5, 1.0, 1.5, 2.0 /)
;   res@cnMinLevelValF       	= 240               ; min lev
;   res@cnMaxLevelValF	        = 330              ; max lev
;   res@cnLevelSpacingF         = 1000		    ; spacing
    map = gsn_csm_contour_map(wks,foo,res)
    
    print("Graph " + 1 + " finished.")

    minYear = minYear + 10
    
  end do

print("Process Completed.")

end 
  

  
