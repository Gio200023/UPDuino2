if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/lunar/Desktop/human_presence_detection/UltraPlus Human Presence Detection RTL21/ice40_himax_upduino2_humandet"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- ice40_himax_upduino2_humandet_impl_1_cpe.ldc
run_engine_newmsg cpe -f "ice40_himax_upduino2_humandet_impl_1.cprj" "rom_himax_cfg_324.cprj" "rom_himax_cfg_324_dim.cprj" "rom_himax_cfg_324_dim_maxfps.cprj" "dpram256x32.cprj" "dpram512x8.cprj" "dpram_lcd_fifo.cprj" "rom_himax_cfg_324_faceid.cprj" "rom_himax_cfg_lcd.cprj" "rom_himax_cfg_seq.cprj" "rom_himax_cfg_1fps.cprj" -a "iCE40UP" -o ice40_himax_upduino2_humandet_impl_1_cpe.ldc
# synthesize top design
file delete -force -- ice40_himax_upduino2_humandet_impl_1.vm ice40_himax_upduino2_humandet_impl_1.ldc
run_engine synpwrap -prj "ice40_himax_upduino2_humandet_impl_1_synplify.tcl" -log "ice40_himax_upduino2_humandet_impl_1.srf"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ice40_himax_upduino2_humandet_impl_1_syn.udb ice40_himax_upduino2_humandet_impl_1.vm] "C:/Users/lunar/Desktop/human_presence_detection/UltraPlus Human Presence Detection RTL21/ice40_himax_upduino2_humandet/impl_1/ice40_himax_upduino2_humandet_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
