library ieee;
use ieee.std_logic_1164.all;

entity StateMachineProject is
port
(
	rst	:	in std_logic; 							-- asserted low
	clk	:	in std_logic; 							-- 50MHz
	sw		:	in std_logic_vector(2 downto 0);
	led	:	out std_logic_vector(2 downto 0)
);
end entity;

architecture rtl of StateMachineProject is
	component PLL IS
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	END component;
	type DataTypeofSMState is (STATE1, STATE2, STATE3);
	signal StateVar		:	DataTypeofSMState;
	signal clk_25MHz 	:	std_logic;
begin
	PLL1:PLL
		port map
		(
			areset		=> not(rst),	-- asserted high
			inclk0		=>	clk, 			-- 50MHz
			c0				=> clk_25MHz 	-- 25MHz
		);
	process1:process(rst, clk)
	begin
		if rst = '0' then
			StateVar <= STATE1;
			led <= "111";
		elsif rising_edge(clk_25MHz) then
			case StateVar is
				when STATE1 =>
					led <= "110";
					if sw(0) = '0' then
						StateVar <= STATE2;
					end if;
				when STATE2 =>
					led <= "101";
					if sw(1) = '0' then
						StateVar <= STATE3;
					end if;
				when STATE3 =>
					led <= "011";
					if sw(2) = '0' then
						StateVar <= STATE1;
					end if;
				when others =>
					StateVar <= STATE1;
			end case;
		end if;
	end process;
end rtl;