-- baudrate_gen.vhd
-- Baud Rate Generator (BRG): divides the system clock into a single-cycle
-- baud_tick pulse. Reusable, project-independent module.
-- Placeholder file -- implementation pending (see ARCHITECTURE.md, Section 4.3).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudrate_gen is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        enable : in std_logic;
        divider  : in  integer;
        baud_tick : out std_logic
    );
end entity baudrate_gen;

architecture rtl of baudrate_gen is

    signal baud : std_logic := '0';
    signal counter : integer := 0;

begin

    process(clk)
    begin
		if rising_edge(clk) then
			if rst_n = '0' then
            baud <= '0';
            counter <= 0;
                elsif enable = '0' then
                baud <= '0';
                counter <= 0;
			elsif counter = divider - 1 then
				baud <= '1';
				counter <= 0;
			else
				baud <= '0';
				counter <= counter + 1;
			end if;
		end if;
        
    end process;

    baud_tick <= baud;

end architecture rtl;