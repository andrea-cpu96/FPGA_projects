library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_parallel_to_serial is
end entity;                       -- a testbench has no ports

architecture sim of tb_parallel_to_serial is
    constant C_CLK_PERIOD : time := 20 ns;   -- 50 MHz reference clock
    
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal shift : std_logic := '0';
    signal load : std_logic := '0';
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic;
begin
    dut : entity work.parallel_to_serial
        port map (clk => clk, rst_n => rst_n, shift => shift, load => load, data_in => data_in, data_out => data_out);

    clk <= not clk after C_CLK_PERIOD / 2;  -- free-running clock

    stim : process
    begin
        wait for 2 * C_CLK_PERIOD;
        rst_n <= '1';                       -- release reset
        data_in <= x"A5";

        wait until rising_edge(clk);        -- DUT captures data_in on rising edge of clk
        load <= '1';

        wait until rising_edge(clk);
        load <= '0';

        wait until rising_edge(clk);
        for bit_index in 0 to 7 loop
            assert data_out = data_in(bit_index)
                report "unexpected serial bit at index " & integer'image(bit_index)
                severity error;

            shift <= '1';
            wait until rising_edge(clk);
            shift <= '0';

            wait for 2 * C_CLK_PERIOD;
        end loop;

        report "parallel_to_serial test passed" severity note;

        wait;                              -- end of test
    end process;
end architecture;