library ieee;
use ieee.std_logic_1164.all;

entity Synchronizer is
	generic
	(
		IDLE_STATE : std_logic := '1'
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		async			:		in std_logic;
		sync			:		out std_logic
	);
end entity;

architecture rtl of Synchronizer is
	signal signal_async	:	std_logic;
	signal signal_sync :	std_logic;
begin
	sync <= signal_sync;
	SynchronisationProcess:process(rst, clk)
	begin
		if rst = '0' then
			signal_async <= IDLE_STATE;
			signal_sync <= IDLE_STATE;
		elsif rising_edge(clk) then
		   signal_async <= async;
			signal_sync <= signal_async;
		end if;
	end process;
end rtl;