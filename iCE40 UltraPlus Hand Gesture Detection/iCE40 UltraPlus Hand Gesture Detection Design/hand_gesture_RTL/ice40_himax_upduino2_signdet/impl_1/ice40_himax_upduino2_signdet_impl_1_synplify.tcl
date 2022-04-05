#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology SBTICE40UP
set_option -part iCE40UP5K
set_option -package SG48I
set_option -speed_grade -6
#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -retiming false; set_option -pipe true
set_option -force_gsr auto
set_option -compiler_compatible 0
set_option -frequency 1

set_option -default_enum_encoding default

#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -rw_check_on_ram 0
set_option -seqshift_no_replicate 0

#-- set any command lines input by customer

set_option -dup false
set_option -disable_io_insertion false
add_file -constraint {ice40_himax_upduino2_signdet_impl_1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/3.1/ip/pmi/pmi_iCE40UP.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/3.1/ip/pmi/pmi_iCE40UP.vhd}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_signdet_clkgen.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/lsc_ml_ice40_himax_signdet_top.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/signdet_post.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/signdet_decision_filter.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/himax_led_strobe.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/strobe_ctl.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/lsc_i2cs_signdet.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/ice40_resetn.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm_16.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm_himax.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cs.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cs_fsm.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_led_con.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_uart.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_spram.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_tri_spram.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_wrap.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_lcd_tx.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_video_process_128_32_wide_br.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_video_process_128_32_seq_wide_br.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram1024x8/rtl/dpram1024x8.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x16/rtl/dpram256x16.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_oled_fifo/rtl/dpram_oled_fifo.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x32/rtl/dpram256x32.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram2048x8/rtl/dpram2048x8.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram4096x8/rtl/dpram4096x8.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_lcd_fifo/rtl/dpram_lcd_fifo.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/rom_himax_cfg_20fps_ir/rtl/rom_himax_cfg_20fps_ir.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/cnn_accel/rtl/cnn_accel.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/i2c/rtl/i2c.v}
add_file -verilog -vlog_std v2001 {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_ebram.v}
#-- top module name
set_option -top_module lsc_ml_ice40_himax_signdet_top
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/cnn_accel}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/i2c}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram1024x8}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram2048x8}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x16}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x32}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram4096x8}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_lcd_fifo}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_oled_fifo}
set_option -include_path {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/rom_himax_cfg_20fps_ir}

#-- set result format/file last
project -result_format "vm"
project -result_file {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/impl_1/ice40_himax_upduino2_signdet_impl_1.vm}

#-- error message log file
project -log_file {ice40_himax_upduino2_signdet_impl_1.srf}
project -run -clean
