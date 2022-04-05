lappend auto_path "C:/lscc/radiant/3.1/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {ice40tp}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {iCE40UP}
set ::bali::simulation::Para(PROJECT) {ProvaSImulation}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet}
set ::bali::simulation::Para(FILELIST) {"C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_lcd_fifo/rtl/dpram_lcd_fifo.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_oled_fifo/rtl/dpram_oled_fifo.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_lcd_tx.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/signdet_post.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram1024x8/rtl/dpram1024x8.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram2048x8/rtl/dpram2048x8.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x32/rtl/dpram256x32.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x16/rtl/dpram256x16.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_video_process_128_32_wide_br.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_spram.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_tri_spram.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_ebram.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/spi_loader_wrap.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram4096x8/rtl/dpram4096x8.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_uart.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cs_fsm.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cs.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/lsc_i2cs_signdet.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/himax_led_strobe.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/rom_himax_cfg_20fps_ir/rtl/rom_himax_cfg_20fps_ir.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm_16.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm_himax.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/ice40_resetn.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_signdet_clkgen.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/lsc_ml_ice40_himax_signdet_top.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_i2cm.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/i2c/rtl/i2c.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/signdet_decision_filter.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/strobe_ctl.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/common/lsc_led_con.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/ice40_himax_video_process_128_32_seq_wide_br.v" "C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/cnn_accel/rtl/cnn_accel.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"" "" "Verilog 2001" "Verilog 2001" "" "" "" "" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ice40up}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {lsc_ml_ice40_himax_signdet_top}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/3.1}
set ::bali::simulation::Para(MEMPATH) {C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/cnn_accel;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/ice40_himax_upduino2_signdet/i2c;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram1024x8;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram2048x8;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x16;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram256x32;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram4096x8;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_lcd_fifo;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/dpram_oled_fifo;C:/Users/lunar/Desktop/iCE40 UltraPlus Hand Gesture Detection/iCE40 UltraPlus Hand Gesture Detection Design/hand_gesture_RTL/src/radiant_mem/rom_himax_cfg_20fps_ir}
set ::bali::simulation::Para(UDOLIST) {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(ISRTL)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
::bali::simulation::ModelSim_Run
