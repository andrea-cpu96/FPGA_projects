library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegisterLED is
	port
	(
		rst	:	in std_logic;
		clk	:	in std_logic;
		sw		:	in std_logic;
		led	:	out std_logic_vector(1 to 4)
	);
end entity;

architecture rtl of ShiftRegisterLED is
	signal ShiftReg	:	std_logic_vector(1 to 4); -- auxiliarry outputs status (good practise do not use outputs directly)
	signal ButtonPressed_deb	: std_logic;
	signal ButtonPressed	: std_logic;
	signal delay_sw	: std_logic;
begin
	u_debounce : entity work.deb_btn
		port map 
		(
			rstn    => rst,      
			clk     => clk,     
			btn_in  => sw,   
			btn_out => ButtonPressed_deb   
		);
	led <= ShiftReg; -- actual outputs
	buttonPressedDetect:process(rst, clk)
	begin
		if rst = '0' then
			delay_sw <= '1';
			ButtonPressed <= '0';
		elsif rising_edge(clk) then
			delay_sw <= ButtonPressed_deb;
			if ButtonPressed_deb = '0' and delay_sw ='1' then -- falling edge detection
				ButtonPressed <= '1';
			else
				ButtonPressed <= '0';
			end if;
		end if;
	end process;
	shifRegPross:process(rst, clk)
	begin
		if rst = '0' then
			ShiftReg <= "0111";
		elsif rising_edge(clk) then
			if ButtonPressed = '1' then
				ShiftReg <= ShiftReg(4) & ShiftReg(1 to 3);
			end if;
		end if;
	end process;
end rtl;