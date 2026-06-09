library ieee;
use ieee.std_logic_1164.all;

entity Serializer is
	generic
	(
		DATA_WIDTH	: integer := 8;
		DEFAULT_STATE	:	std_logic := '1'
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		shift_en		:		in std_logic;
		load			:		in std_logic;
		Din			:		in std_logic_vector(DATA_WIDTH-1 downto 0);
		Dout			:		out std_logic
	);
end entity;

architecture rtl of Serializer is
	signal shift_reg	:	std_logic_vector(DATA_WIDTH-1 downto 0);
begin
	Dout <= shift_reg(0);
	SerializerProcess:process(rst, clk)
	begin
		if rst = '0' then
			shift_reg <= (others => DEFAULT_STATE); 
		elsif rising_edge(clk) then
			if load = '1' then
				shift_reg <= Din;
			elsif shift_en = '1' then
				shift_reg <= '1' & shift_reg(shift_reg'left downto 1);
			end if; 
		end if;
	end process;
end rtl;