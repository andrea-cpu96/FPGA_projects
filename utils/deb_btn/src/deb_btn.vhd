library ieee;
use ieee.std_logic_1164.all;

entity deb_btn is
port
(
	rstn		:	in std_logic; 	-- ACTIVE LOW
	clk		:	in std_logic;
	btn_in	:	in std_logic;	-- ACTIVE LOW
	btn_out	:	out std_logic 	-- ACTIVE LOW
);
end entity;

architecture rtl of deb_btn is
	constant deb_period	:	integer := 2500000;
	signal btn_aux : std_logic;
	signal btn_sync : std_logic;
	signal counter	:	integer range 0 to 2500001 := 0;
begin
	sync_process:process(rstn, clk)
	begin
		if rstn = '0' then
			btn_aux <= '1';
			btn_sync <= '1';
		elsif rising_edge(clk) then
			btn_aux <= btn_in;
			btn_sync <= btn_aux;
		end if;
	end process;
	deb_process:process(rstn, clk)
	begin
		if rstn = '0' then
			counter <= 0;
			btn_out <= '1';
		elsif rising_edge(clk) then
			if btn_sync = '0' then
				if counter < deb_period then
					counter <= counter + 1;
				end if;
			else
				if counter > 0 then
					counter <= counter - 1;
				end if;
			end if;
			if counter = deb_period then
				btn_out <= '0';
			elsif counter = 0 then
				btn_out <= '1';
			end if;
		end if;
	end process;
end rtl;