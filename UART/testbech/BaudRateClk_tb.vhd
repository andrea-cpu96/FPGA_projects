library ieee;
use ieee.std_logic_1164.all;

entity BaudClkGenerator_tb is
end entity;

architecture rtl of BaudClkGenerator_tb is

	component BaudClkGenerator is
	generic 
	(
		SYS_CLK_FREQ	:	integer := 50000000;
		BAUD_RATE		:	integer := 115200;
		NUMBER_OF_CLK	:	integer := 10
	);
	port
	(
		rst		:	in std_logic;
		clk		:	in std_logic;
		start		:	in std_logic;
		baudClk	:	out std_logic;
		ready		:	out std_logic
	);
end component;

	signal rst	: std_logic;
	signal clk	: std_logic := '0';
	signal start	: std_logic;
	signal baudClk	: std_logic;
	signal ready	: std_logic;
begin

	clk <= not(clk) after 10ns;
	
	UUT:BaudClkGenerator	
	generic map
	(
		SYS_CLK_FREQ	=> 50000000,
		BAUD_RATE		=>	115200,
		NUMBER_OF_CLK	=>	10
	)
	port map
	(
		rst		=> rst,
		clk		=> clk,
		start		=> start,
		baudClk	=> baudClk,
		ready	 	=> ready
	);
	
	main:process
	begin
		rst <= '0';
		start <= '0';
		wait for 100ns;
		rst <= '1';
		
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		
		wait;
	end process;
	

end rtl;