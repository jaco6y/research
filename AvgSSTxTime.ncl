
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

foo_plus_ten = minYear + 10
nlat = 900
gw = gaus(nlat)
nmon = (maxYear - minYear + 1) * 12 - 1
temp_time = new((/nmon/),float,0)

begin

  all_files = systemfunc( "ls /raid60/kirtman/HRC07/ocn/mo_nc4/HRC07.pop.{1942..1992}-*.nc" )

  ;begin loop here
  file_list = addfiles(all_files, "r")                  ;adding all of our files
  ListSetType(file_list, "cat")

  sst = file_list[:]->TEMP(:,0,:,:) ;importing selected years by filename

  sst_all = where(sst.gt.1.0,sst,sst@_FillValue)         ;fill NaN values
  copy_VarMeta(sst,sst_all)

  ncols = dimsizes(file_list)
  averageTemps = new((/nmon/),float)              ;creates 1dim array empty
  ;DO A FOR LOOP HERE. CALCULATING PER MONTH AVG SST, NEED TO LOOP ACROSS EVERY MONTH
  i = 0
  do while(i.lt.nmon)
    averageTemps(i) = wgt_areaave(sst_all(i,:,:),gw(:,1),1.0,0)   ;calc avg temps and put into empty array
    i = i + 1
  end do

  ;****************************************
  ; Create plot
  ;****************************************
  wks = gsn_open_wks("png","AvgAllYearsClean")           ; send graphics to PNG file
  res = True
  res@tiYAxisString  = "Average SST (Degrees C)"
  res@tiXAxisString  = "Months from " + minYear
  res@tiMainString   = "Monthly SST across Time"
  res@xyLineColors   = (/"red"/)   ; choose line colors

  res@pmLegendDisplayMode    = "Always"     ; turn on legend bar
  res@pmLegendSide           = "Bottom"     ; orient with bottom
  res@pmLegendParallelPosF   = .6          ; move legend
  res@pmLegendOrthogonalPosF = 0
  res@lgPerimFillColor       = "white"      ; fill with white
  res@lgPerimFill            = "SolidFill"
  res@pmLegendWidthF         = 0.05         ; size
  res@pmLegendHeightF        = 0.05
  res@lgLabelFontHeightF     = 0.015
  res@xyExplicitLegendLabels = (/"Global Average SST Degrees C"/)
  res@xyLineThicknesses      = (/2/)
  res@tmXTBorderOn      = False
  res@tmXTOn            = False
  res@tmXUseBottom      = False
  res@tmYRBorderOn      = False
  res@tmYROn            = False
  res@tmYUseLeft        = False
  res@xyXStyle          = "Linear"
  plot = gsn_csm_y(wks,averageTemps,res); create plot
end
