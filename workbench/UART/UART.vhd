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
        r                : in std_logic;
        data_tx_buff     : in std_logic_vector(7 downto 0);
        data_line_rx     : in std_logic;
        tx_busy          : out std_logic;
        rx_busy          : out std_logic;
        rx_valid         : out std_logic;
        data_rx_buff     : out std_logic_vector(7 downto 0);
        data_line_tx     : out std_logic
    );
end entity UART;

architecture rtl of UART is
begin
    -- Pure structural wrapper: the master's requests are forwarded unchanged.
    -- TX and RX are full-duplex and independent, so there is no cross-gating
    -- between them (rx_busy must not block w, tx_busy must not block r).

    u_tx : entity work.UART_TX
        generic map (
            G_CLK_FREQ => G_CLK_FREQ,
            G_BAUD     => G_BAUD
        )
        port map (
            clk              => clk,
            rst_n            => rst_n,
            w                => w,             -- forward the master's request
            data_to_transmit => data_tx_buff,
            data_out         => data_line_tx,
            tx_busy          => tx_busy
        );

    u_rx : entity work.UART_RX
        generic map (
            G_CLK_FREQ => G_CLK_FREQ,
            G_BAUD     => G_BAUD
        )
        port map (
            clk              => clk,
            rst_n            => rst_n,
            r                => r,             -- forward the master's arm
            data_in          => data_line_rx,
            rx_valid         => rx_valid,
            data_rx          => data_rx_buff,
            rx_busy          => rx_busy
        );
end architecture rtl;


