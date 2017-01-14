i = 0
do while(i.lt.131)
  averageTemps(i) = wgt_areaave(sst_all(i,:,:),gw(:,1),1.0,0)
  i = i + 1
end do

i = 0
do while(i.lt.131)
  months2(i) = i+1
  i = i+1
end do

;****************************************
; Create plot
;****************************************
wks = gsn_open_wks("png","test2")           ; send graphics to PNG file
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
plot = gsn_csm_y(wks,array2,res); create plot
