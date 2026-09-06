library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_UART_TX is
end entity;                       

architecture sim of tb_UART_TX is
    constant CLK_PERIOD : time := 20 ns;    -- 50 MHz reference clock
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal w : std_logic := '0';
    signal data_to_transmit : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic;
    signal busy : std_logic;
begin
    dut : entity work.UART_TX
        port map (clk => clk, rst_n => rst_n, w => w, data_to_transmit => data_to_transmit, data_out => data_out, busy => busy);

    clk <= not clk after CLK_PERIOD / 2;    -- free-running clock

    stim : process
    begin
        wait for 2 * CLK_PERIOD;
        rst_n <= '1';                       -- release reset
        data_to_transmit <= x"A5";
        
        wait until rising_edge(clk);       
        w <= '1';                            -- request transmission

        wait until rising_edge(clk);
        w <= '0';                            -- clear request
    
        wait;                              -- end of test
    end process;
end architecture;