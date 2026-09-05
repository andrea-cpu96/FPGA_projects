library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
    generic (
        G_CLK_FREQ : natural := 50_000_000;   -- Hz
        G_BAUD     : natural := 115_200       -- bit/s
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic
    );
end entity UART;

architecture rtl of UART is
begin

    u_tx : entity work.UART_TX
        generic map (
            G_CLK_FREQ => G_CLK_FREQ,
            G_BAUD     => G_BAUD
        )
        port map (
            clk   => clk,
            rst_n => rst_n
        );

end architecture rtl;


