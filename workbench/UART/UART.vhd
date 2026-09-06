library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
    generic (
        G_CLK_FREQ : natural := 50_000_000;   -- Hz
        G_BAUD     : natural := 115_200       -- bit/s
    );
    port (
        clk              : in std_logic;
        rst_n            : in std_logic;
        w                : in std_logic;
        data_to_transmit : in std_logic_vector(7 downto 0);
        data_out         : out std_logic;
        tx_busy          : out std_logic
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
            clk              => clk,
            rst_n            => rst_n,
            w                => w,
            data_to_transmit => data_to_transmit,
            data_out         => data_out,
            tx_busy          => tx_busy
        );

end architecture rtl;


