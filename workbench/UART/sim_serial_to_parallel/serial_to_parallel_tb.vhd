library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_serial_to_parallel is
end entity;                       -- a testbench has no ports

architecture sim of tb_serial_to_parallel is
    constant C_CLK_PERIOD : time := 20 ns;   -- 50 MHz reference clock

    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal shift : std_logic := '0';
    signal data_in : std_logic;
    signal data_out : std_logic_vector(7 downto 0) := (others => '0');

    -- Hex conversion for messages (to_hstring is VHDL-2008 only; this local
    -- helper keeps the TB compilable under VHDL-93/2002 as well).
    function to_hex(slv : std_logic_vector(7 downto 0)) return string is
        constant HEX_CHARS : string(1 to 16) := "0123456789ABCDEF";
    begin
        if is_x(slv) then
            return "XX";
        end if;
        return HEX_CHARS(to_integer(unsigned(slv(7 downto 4))) + 1) &
               HEX_CHARS(to_integer(unsigned(slv(3 downto 0))) + 1);
    end function;

begin
    dut : entity work.serial_to_parallel(rtl)
        port map (clk => clk, rst_n => rst_n, shift => shift, data_in => data_in, data_out => data_out);

    clk <= not clk after C_CLK_PERIOD / 2;  -- free-running clock

    stim : process
        -- Feed 8 bits LSB-first (same convention as parallel_to_serial).
        procedure drive_byte(constant rx_byte : in std_logic_vector(7 downto 0)) is
        begin
            for i in 0 to 7 loop
                wait until rising_edge(clk);
                data_in <= rx_byte(i);
                wait until rising_edge(clk);
                shift <= '1';
                wait until rising_edge(clk);
                shift <= '0';
                wait for C_CLK_PERIOD;
            end loop;
        end procedure drive_byte;

    begin
        wait for 2 * C_CLK_PERIOD;
        rst_n <= '1';                       -- release reset

        drive_byte(x"A5");
        wait until rising_edge(clk);
        assert data_out = x"A5"
            report "A5 mismatch: got " & to_hex(data_out)
            severity error;

        drive_byte(x"C3");
        wait until rising_edge(clk);
        assert data_out = x"C3"
            report "C3 mismatch: got " & to_hex(data_out)
            severity error;

        report "serial_to_parallel test finished" severity note;

        wait;                                 -- end of test
    end process;
end architecture;