library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister is
	generic
	(
		CHAIN_LENGTH : integer := 8;
		SHIFT_DIRECTION : character := 'R'
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		shift_en		:		in std_logic;
		Din			:		in std_logic;
		Dout			:		out std_logic_vector(CHAIN_LENGTH-1 downto 0)
	);
end entity;

architecture rtl of ShiftRegister is
	signal shift_reg	:	std_logic_vector(CHAIN_LENGTH-1 downto 0);
begin
	Dout <= shift_reg;
	SHIFT_TO_THE_RIGHT : if SHIFT_DIRECTION = 'R' generate
		SerializerProcess:process(rst, clk)
		begin
			if rst = '0' then
				shift_reg <= (others => '0'); 
			elsif rising_edge(clk) then
				if shift_en = '1' then
					shift_reg <= Din & shift_reg(shift_reg'left downto 1);
				end if; 
			end if;
		end process;	
	end generate;
	SHIFT_TO_THE_LEFT : if SHIFT_DIRECTION = 'L' generate
		SerializerProcess:process(rst, clk)
		begin
			if rst = '0' then
				shift_reg <= (others => '0'); 
			elsif rising_edge(clk) then
				if shift_en = '1' then
					shift_reg <= shift_reg(shift_reg'left downto 1) & Din;
				end if; 
			end if;
		end process;	
	end generate;
end rtl;