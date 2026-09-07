-- UART_TX.vhd
-- UART transmitter (top of the TX hierarchy). Instantiates baudrate_gen (BRG)
-- and parallel_to_serial (P2S); owns start/stop framing and tx_busy status.
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
        rst_n : in std_logic;
        w : in std_logic;
        data_to_transmit  : in std_logic_vector(7 downto 0);
        data_out : out std_logic;   
        tx_busy  : out std_logic
    );
end entity UART_TX;

architecture rtl of UART_TX is

    constant C_DIVIDER : natural := G_CLK_FREQ / G_BAUD;

    signal load       : std_logic;
    signal shift      : std_logic;
    signal baud_tick  : std_logic;
    signal baud_enable : std_logic;
    signal count      : natural range 0 to 7 := 0;
    signal data_out_b : std_logic := '1';
    signal data_out_r : std_logic := '1';   -- registered serial output (TXD)
    signal tx_busy_r  : std_logic := '0';   -- registered status output

    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_t := IDLE;

begin

    u_brg : entity work.baudrate_gen
        port map (
            clk       => clk,
            rst_n     => rst_n,
            enable    => baud_enable,
            divider   => C_DIVIDER,
            baud_tick => baud_tick
        );

    u_p2s : entity work.parallel_to_serial(rtl)
        port map (
            clk => clk,
            rst_n => rst_n,
            shift => shift,
            load => load,
            data_in => data_to_transmit,
            data_out => data_out_b
        );

    -- Sequential FSM logic; state and bit counter update on the rising clock edge.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                state <= IDLE;
                count <= 0;
                data_out_r <= '1';          -- serial line idles high
                tx_busy_r  <= '0';
            else
                case state is
                    when IDLE =>
                        count <= 0;
                        if w = '1' then
                            state <= START_BIT;
                        end if;

                    when START_BIT =>
                        if baud_tick = '1' then
                            state <= DATA_BITS;
                            count <= 0;
                        end if;

                    when DATA_BITS =>
                        if baud_tick = '1' then
                            if count = 7 then
                                state <= STOP_BIT;
                                count <= 0;
                            else
                                count <= count + 1;
                            end if;
                        end if;

                    when STOP_BIT =>
                        if baud_tick = '1' then
                            state <= IDLE;
                        end if;
                end case;

                -- Registered output mux: samples the framing decode of the
                -- CURRENT state, so the whole frame is uniformly delayed by
                -- one clock on the wire. Bit cells keep their width and the
                -- receiver re-syncs on the start edge, so the latency is
                -- harmless for any UART.
                case state is
                    when IDLE      => data_out_r <= '1';
                    when START_BIT => data_out_r <= '0';
                    when DATA_BITS => data_out_r <= data_out_b;
                    when STOP_BIT  => data_out_r <= '1';
                end case;

                -- Registered status output (module outputs are FF-driven)
                if state = IDLE then
                    tx_busy_r <= '0';
                else
                    tx_busy_r <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Combinational control signals derived from the current FSM state and inputs.
    baud_enable <= '1' when state /= IDLE else '0';
    load <= '1' when state = IDLE and w = '1' else '0';
    shift <= '1' when state = DATA_BITS and baud_tick = '1' else '0';

    -- Continuous output drivers: exactly one driver per port, both coming
    -- from flip-flops (glitch-free at the module/pin boundary).
    data_out <= data_out_r;
    tx_busy  <= tx_busy_r;

end architecture rtl;
