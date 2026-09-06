library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_to_parallel is
    port (
        clk : in  std_logic;
        rst_n : in  std_logic;
        shift : in  std_logic;
        data_in : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end entity serial_to_parallel;

architecture rtl of serial_to_parallel is

    signal q : std_logic_vector(7 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                q <= (others => '0');
            elsif shift = '1' then
                -- LSB-first mirror of parallel_to_serial: the first received bit
                -- lands in position 0; after 8 shifts the original byte is rebuilt.
                q <= data_in & q(7 downto 1);
            end if;
        end if;
    end process;
    
    data_out <= q;
end architecture rtl;