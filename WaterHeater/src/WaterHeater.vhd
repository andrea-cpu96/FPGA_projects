library IEEE;
use IEEE.std_logic_1164.all;

entity WaterHeater is
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		sw				:		in std_logic;
		temp_in		:		in	std_logic;
		water_lev	:		in std_logic;	
		led_ready	:		out std_logic;
		led_err		:		out std_logic;
		heater		:		out std_logic
	);
end entity;

architecture rtl of WaterHeater is
	type FSMStateDT is (IDLE, RUN, STOP); 
	signal state	:	FSMStateDT;
	signal temp_in_sync, water_lev_sync	:	std_logic;
begin
	HeaterProcess:process(rst, clk)
	begin
		if rst = '0' then
			led_ready <= '0'; 
			led_err <= '0';
			heater <= '0';
			state <= IDLE;
		elsif rising_edge(clk) then
			-- Synchronous signals when assigned here inside rising_edge clock condition (input registers) 
			temp_in_sync <= temp_in;		-- Assign inputs to intermediate signals for having input registers
			water_lev_sync <= water_lev;
			case state is
				when IDLE =>
					led_ready <= '0'; 
					led_err <= '0';
					heater <= '0';
					if sw = '0' then
						state <= STOP;
					end if;
				when STOP =>
					led_ready <= '0'; 
					led_err <= '0';
					heater <= '0';
					if sw = '1' then
						state <= IDLE;
					else  
						led_err <= water_lev_sync;
						led_ready <= temp_in_sync;
						if (temp_in_sync = '0') and (water_lev_sync = '0') then
							state <= RUN;
						end if;
					end if;
				when RUN =>
					heater <= '1';
					led_err <= '0';
					led_ready <= '0';
					if sw = '1' then
						state <= IDLE;
					elsif (temp_in_sync = '1') or (water_lev_sync = '1') then
						state <= STOP;
					end if;
				when others => 
					led_ready <= '0'; 
					led_err <= '0';
					heater <= '0';
					state <= STOP;
			end case;
		end if;
	end process;
end rtl;
