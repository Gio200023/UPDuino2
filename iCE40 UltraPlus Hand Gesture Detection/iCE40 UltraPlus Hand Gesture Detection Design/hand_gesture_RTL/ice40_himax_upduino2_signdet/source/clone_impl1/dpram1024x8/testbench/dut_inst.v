    dpram1024x8 u_dpram1024x8(.wr_clk_i(wr_clk_i),
        .rd_clk_i(rd_clk_i),
        .rst_i(rst_i),
        .wr_clk_en_i(wr_clk_en_i),
        .rd_en_i(rd_en_i),
        .rd_clk_en_i(rd_clk_en_i),
        .wr_en_i(wr_en_i),
        .wr_data_i(wr_data_i),
        .wr_addr_i(wr_addr_i),
        .rd_addr_i(rd_addr_i),
        .rd_data_o(rd_data_o));
