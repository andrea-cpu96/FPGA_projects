library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;

        -- comandi
        start     : in  std_logic;
        stop      : in  std_logic;
        read      : in  std_logic;
        write     : in  std_logic;
        ack_in    : in  std_logic;
        din       : in  std_logic_vector(7 downto 0);

        -- risultati
        dout      : out std_logic_vector(7 downto 0);
        busy      : out std_logic;
        ack_out   : out std_logic;

        -- configurazione
        clk_cnt   : in  unsigned(15 downto 0);

        -- linee I2C
        scl_i     : in  std_logic;
        scl_o     : out std_logic;
        scl_oen   : out std_logic;
        sda_i     : in  std_logic;
        sda_o     : out std_logic;
        sda_oen   : out std_logic
    );
end entity;

architecture rtl of i2c_master_top is

    component i2c_master_byte_ctrl is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            nReset   : in  std_logic;
            ena      : in  std_logic;
            clk_cnt  : in  unsigned(15 downto 0);
            start    : in  std_logic;
            stop     : in  std_logic;
            read     : in  std_logic;
            write    : in  std_logic;
            ack_in   : in  std_logic;
            din      : in  std_logic_vector(7 downto 0);
            cmd_ack  : out std_logic;
            ack_out  : out std_logic;
            i2c_busy : out std_logic;
            i2c_al   : out std_logic;
            dout     : out std_logic_vector(7 downto 0);
            scl_i    : in  std_logic;
            scl_o    : out std_logic;
            scl_oen  : out std_logic;
            sda_i    : in  std_logic;
            sda_o    : out std_logic;
            sda_oen  : out std_logic
        );
    end component;

    signal cmd_ack_s : std_logic;
    signal busy_s    : std_logic;
    signal ack_s     : std_logic;
    signal dout_s    : std_logic_vector(7 downto 0);

begin

    dout    <= dout_s;
    busy    <= busy_s;
    ack_out <= ack_s;

    u_byte : i2c_master_byte_ctrl
        port map (
            clk      => clk,
            rst      => rst,
            nReset   => '1',
            ena      => '1',
            clk_cnt  => clk_cnt,
            start    => start,
            stop     => stop,
            read     => read,
            write    => write,
            ack_in   => ack_in,
            din      => din,
            cmd_ack  => cmd_ack_s,
            ack_out  => ack_s,
            i2c_busy => busy_s,
            i2c_al   => open,
            dout     => dout_s,
            scl_i    => scl_i,
            scl_o    => scl_o,
            scl_oen  => scl_oen,
            sda_i    => sda_i,
            sda_o    => sda_o,
            sda_oen  => sda_oen
        );

end architecture;