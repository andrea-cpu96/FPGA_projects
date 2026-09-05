-- UART_TX.vhd
-- UART transmitter (top of the TX hierarchy). Instantiates baudrate_gen (BRG)
-- and parallel_to_serial (P2S); owns start/stop framing and busy/ready status.
-- Placeholder file -- implementation pending (see ARCHITECTURE.md, Section 4).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX is
    generic (
        G_CLK_FREQ : natural := 50_000_000;
        G_BAUD     : natural := 115_200
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic
    );
end entity UART_TX;

architecture rtl of UART_TX is

    constant C_DIVIDER : natural := G_CLK_FREQ / G_BAUD;   
    
    signal baud_tick : std_logic;

begin

    u_brg : entity work.baudrate_gen
        port map (
            clk       => clk,
            rst_n     => rst_n,
            divider   => C_DIVIDER,
            baud_tick => baud_tick
        );

    u_p2s : entity work.parallel_to_serial(rtl)
        port map (
            clk => clk,
            rst_n => rst_n,
            shift => baud_tick,
            load => '0',
            data_in => (others => '0'),
            data_out => open
        );

end architecture rtl;
