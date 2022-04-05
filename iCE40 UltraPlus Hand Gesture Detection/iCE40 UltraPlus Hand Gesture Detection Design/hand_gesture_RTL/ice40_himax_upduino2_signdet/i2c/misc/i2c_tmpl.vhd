component i2c is
    port(
        i2c2_scl_io: inout std_logic;
        i2c2_sda_io: inout std_logic;
        rst_i: in std_logic;
        ipload_i: in std_logic;
        ipdone_o: out std_logic;
        sb_clk_i: in std_logic;
        sb_wr_i: in std_logic;
        sb_stb_i: in std_logic;
        sb_adr_i: in std_logic_vector(7 downto 0);
        sb_dat_i: in std_logic_vector(7 downto 0);
        sb_dat_o: out std_logic_vector(7 downto 0);
        sb_ack_o: out std_logic;
        i2c_pirq_o: out std_logic_vector(1 downto 0);
        i2c_pwkup_o: out std_logic_vector(1 downto 0)
    );
end component;

__: i2c port map(
    i2c2_scl_io=>,
    i2c2_sda_io=>,
    rst_i=>,
    ipload_i=>,
    ipdone_o=>,
    sb_clk_i=>,
    sb_wr_i=>,
    sb_stb_i=>,
    sb_adr_i=>,
    sb_dat_i=>,
    sb_dat_o=>,
    sb_ack_o=>,
    i2c_pirq_o=>,
    i2c_pwkup_o=>
);
