set design usb_phy

set netlist "./${design}.v"
set sdc "./${design}.sdc"
set home "/home/linux/ieng6/ee260bwi20/public/data/libraries"
set libworst "$home/lib/contest.lib"
set lef "$home/techfiles/contest.lef"
set captblworst "$home/techfiles/cln65g+_1p08m+alrdl_top2_cworst.captable"
set home "/home/linux/ieng6/ee260bwi20/public/data/libraries"

# default settings
set init_pwr_net "VDD"
set init_gnd_net "VSS"

# default settings
set init_verilog "$netlist"
set init_design_netlisttype "Verilog"
set init_design_settop 1
set init_top_cell "$design"
set init_lef_file "$lef"

# MCMM setup
create_library_set -name WC_LIB -timing $libworst
create_library_set -name BC_LIB -timing $libworst
create_rc_corner -name Cmax -cap_table $captblworst -T 125
create_rc_corner -name Cmin -cap_table $captblworst -T -40
create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin
create_constraint_mode -name CON -sdc_file [list $sdc]
create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON
init_design -setup {WC_VIEW} -hold {BC_VIEW}

set_interactive_constraint_modes {CON}
setDesignMode -process 65

defIn ${design}.def

# set operating temperature
setAnalysisMode -analysisType onChipVariation -cppr both
setDelayCalMode -reset
setDelayCalMode -SIAware true
setExtractRCMode -coupled true -engine postRoute

report_timing

setEcoMode -batchMode true
setEcoMode -refinePlace true
set infile [open cell.sizes]
while {[gets $infile line] >= 0} {
  if {[llength $line] != 3} continue
  set cellname [lindex $line 1]
  set celltype [lindex $line 2]
  ecoChangeCell -inst $cellname -cell $celltype
}
setEcoMode -batchMode false

routeDesign

report_timing

saveNetlist ${design}_eco.v

exec echo "clk" > excNet.rpt
rcOut -excNetFile excNet.rpt -spef ${design}_eco.spef
defOut -routing ${design}_eco.def

exit
