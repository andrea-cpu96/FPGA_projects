library ieee;
use ieee.std_logic_1164.all;

entity PLL_clk_gen is
port
(
	rst		:	in std_logic; 							-- asserted low
	clk		:	in std_logic; 							-- 50MHz
	clk_out	:	out std_logic						
);
end entity;

architecture rtl of PLL_clk_gen is
	component PLL IS
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC 
		);
	END component;
begin
	PLL1:PLL
		port map
		(
			areset		=> not(rst),	-- asserted high
			inclk0		=>	clk, 			-- 50MHz
			c0				=> clk_out 		
		);
end rtl;