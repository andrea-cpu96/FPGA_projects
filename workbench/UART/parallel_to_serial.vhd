-- parallel_to_serial.vhd
-- Parallel-to-Serial Converter (P2S): shifts an 8-bit byte out LSB-first,
-- one bit per baud_tick. Reusable, project-independent module.
-- Placeholder file -- implementation pending (see ARCHITECTURE.md, Section 4.2).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parallel_to_serial is
    port (
        clk : in  std_logic;
        rst_n : in  std_logic;
        shift : in  std_logic;
        load : in  std_logic;
        data_in : in  std_logic_vector(7 downto 0);
        data_out : out std_logic
    );
end entity parallel_to_serial;

architecture rtl of parallel_to_serial is
    signal shift_sig : std_logic;
    signal data_in_load : std_logic_vector(7 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                data_in_load <= (others => '0');
            elsif load = '1' then
                data_in_load <= data_in;
            elsif shift = '1' then
                 data_in_load <= '0' & data_in_load(7 downto 1);   -- LSB first
            end if;
        end if;
    end process;

    data_out <= data_in_load(0);

end architecture rtl;