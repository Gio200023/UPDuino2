if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- ice40_himax_upduino2_signdet_impl_1_cpe.ldc
run_engine_newmsg cpe -f "ice40_himax_upduino2_signdet_impl_1.cprj" "dpram1024x8.cprj" "dpram256x16.cprj" "dpram_oled_fifo.cprj" "dpram256x32.cprj" "dpram2048x8.cprj" "dpram4096x8.cprj" "dpram_lcd_fifo.cprj" "rom_himax_cfg_20fps_ir.cprj" "cnn_accel.cprj" "i2c.cprj" -a "iCE40UP" -o ice40_himax_upduino2_signdet_impl_1_cpe.ldc
# synthesize top design
file delete -force -- ice40_himax_upduino2_signdet_impl_1.vm ice40_himax_upduino2_signdet_impl_1.ldc
run_engine synpwrap -prj "ice40_himax_upduino2_signdet_impl_1_synplify.tcl" -log "ice40_himax_upduino2_signdet_impl_1.srf"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ice40_himax_upduino2_signdet_impl_1_syn.udb ice40_himax_upduino2_signdet_impl_1.vm] "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/impl_1/ice40_himax_upduino2_signdet_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
