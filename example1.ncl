
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

  all_files = systemfunc( "ls /raid60/kirtman/HRC07/ocn/mo_nc4/HRC07.pop.1997-*.nc" )
  file_list = addfiles(all_files, "r")                  ;adding all of our files
  ListSetType(file_list, "cat")

  sst = file_list[:]->TEMP(:,0,:,:)
  sst_all = where(sst.gt.1.0,sst,sst@_FillValue)
  copy_VarMeta(sst,sst_all)


wks  = gsn_open_wks("png","maponly")         ; send graphics to PNG file

res                            = True
res@mpProjection               = "Satellite" ; choose map projection
res@mpCenterLonF               = 280.0       ; choose center lon
res@mpCenterLatF               = 25.         ; choose center lat
res@mpSatelliteDistF           = 3.0         ; choose satellite view
res@mpOutlineOn                = True
res@cnFillOn = True
res@cnLinesOn = True
res@cnLevelSelectionMode 	= "ExplicitLevels"  ; manually set cont levels
res@cnLevels = (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34/)
mpGridLineColor = "transparent" ; trick ncl into drawing earth's outline

plot = gsn_csm_map(wks,sst_all(0,:,:),res)                  ; draw satellite proj map
