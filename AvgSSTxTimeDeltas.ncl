
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
minYear = 1960
maxYear = 2001

avgYearsMin = 1970
avgYearsMax = 1980
;****ENDINPUT****

nmon = (maxYear - minYear + 1) * 12 - 1
nmonX = new((/nmon/),float)
x = 0
do while(x.lt.nmon)
  nmonX(x)=x
  x=x+1
end do
kmon = (avgYearsMax - avgYearsMin + 1) * 12 - 1
nlat = 900
gw = gaus(nlat)

begin

  all_files = systemfunc("ls /raid60/kirtman/HRC07/ocn/mo_nc4/HRC07.pop.{" + minYear +".." + maxYear + "}-*.nc" )

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
    print("Average (" + (i+1) + ") of (" + nmon + ") calculated")
    i = i + 1
  end do

  meanAvgTemps = new((/kmon/),float)
  k = 0
  j = ((avgYearsMin - minYear)*12) + 1
  do while(k.lt.kmon)
    meanAvgTemps(k) = averageTemps(k + j)
    k = k + 1
  end do

  meanAvgTemp = avg(meanAvgTemps)
  h = 0
  deltas = new((/2,nmon/),float)
  zeros = new((/nmon/),float,0)

  k=0
  do while(k.lt.nmon)
    deltas(0,k) = (averageTemps(k) - meanAvgTemp(0))
    deltas(1,k) = 0
    k = k+1
  end do


  ;****************************************
  ; Create plot
  ;****************************************
  wks = gsn_open_wks("png","DeltasXTime2")           ; send graphics to PNG file
  res = True
  res@tiYAxisString  = "Average SST Delta (Degrees C)"
  res@tiXAxisString  = "Months from " + minYear
  res@tiMainString   = "Monthly SST Delta from Mean"
  res@xyLineColors   = (/"red","black"/)   ; choose line colors
  res@xyLineThicknesses = (/ 1.0,  2.0/)

  res@pmLegendDisplayMode    = "Always"     ; turn on legend bar
  res@pmLegendSide           = "Bottom"     ; orient with bottom
  res@pmLegendParallelPosF   = .6          ; move legend
  res@pmLegendOrthogonalPosF = 0
  res@lgPerimFillColor       = "white"      ; fill with white
  res@lgPerimFill            = "SolidFill"
  res@pmLegendWidthF         = 0.05         ; size
  res@pmLegendHeightF        = 0.05
  res@lgLabelFontHeightF     = 0.015
  res@xyExplicitLegendLabels = (/"Delta from 1970-1980 Mean"/)
  res@xyXStyle          = "Linear"
  plot = gsn_csm_xy(wks,nmonX,deltas,res); create plot
end
