/*******************************************************************************
    Verilog netlist generated by IPGEN Radiant
    Soft IP Version: 1.0.0
    Thu Mar 21 14:54:27 2019
*******************************************************************************/
/*******************************************************************************
    Include IP core template files.
*******************************************************************************/
`include "core/lscc_ram_dp.v"
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module dpram_oled_fifo (wr_clk_i, rd_clk_i, wr_clk_en_i, rd_en_i, rd_clk_en_i,
    wr_en_i, wr_data_i, wr_addr_i, rd_addr_i, rd_data_o);
    input  wr_clk_i;
    input  rd_clk_i;
    input  wr_clk_en_i;
    input  rd_en_i;
    input  rd_clk_en_i;
    input  wr_en_i;
    input  [15:0]  wr_data_i;
    input  [7:0]  wr_addr_i;
    input  [7:0]  rd_addr_i;
    output  [15:0]  rd_data_o;
    lscc_ram_dp #(.WADDR_DEPTH(256),
        .WDATA_WIDTH(16),
        .RADDR_DEPTH(256),
        .RDATA_WIDTH(16),
        .WADDR_WIDTH(8),
        .REGMODE("noreg"),
        .RADDR_WIDTH(8),
        .RESETMODE("sync"),
        .INIT_MODE("mem_file"),
        .INIT_FILE("misc/oled_dpram_oled_fifo_copy.mem"),
        .INIT_FILE_FORMAT("hex"))
    lscc_ram_dp_inst(.wr_clk_i(wr_clk_i),
        .rd_clk_i(rd_clk_i),
        .rst_i(1'b0),
        .wr_clk_en_i(wr_clk_en_i),
        .rd_en_i(rd_en_i),
        .rd_clk_en_i(rd_clk_en_i),
        .rd_out_clk_en_i(1'b1),
        .wr_en_i(wr_en_i),
        .wr_data_i(wr_data_i),
        .wr_addr_i(wr_addr_i),
        .rd_addr_i(rd_addr_i),
        .rd_data_o(rd_data_o));
endmodule