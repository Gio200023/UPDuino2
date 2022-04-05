
#Begin clock constraint
create_clock -name {lsc_ml_ice40_himax_humandet_top|clk_inferred_clock} -period 10.798  [get_nets {lsc_ml_ice40_himax_humandet_top|clk_inferred_clock}]
#End clock constraint

#Begin clock constraint
create_clock -name {lsc_ml_ice40_himax_humandet_top|cam_pclk} -period 10.798  [get_ports {lsc_ml_ice40_himax_humandet_top|cam_pclk}]
#End clock constraint
