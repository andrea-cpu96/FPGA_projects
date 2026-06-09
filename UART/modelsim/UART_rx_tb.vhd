library ieee;
use ieee.std_logic_1164.all;

entity UART_rx_tb is
end entity;
 
architecture rtl of UART_rx_tb is
	component UART_rx is
	generic
	(
		DATA_WIDTH : integer := 8;
      SYS_CLK_FREQ : integer := 50000000;
      BAUD_RATE : integer := 115200
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		rs232_rx		:		in std_logic;
		IRQ_clear	:		in std_logic;
		IRQ_rx		:		out std_logic;
		data_rx		:		out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
	end component;
	signal rst			:	 	std_logic;
	signal clk			:		std_logic := '0';
	signal rs232_rx	:	   std_logic;
	signal IRQ_clear	:		std_logic;
	signal IRQ_rx		:		std_logic;
	signal data_rx		:		std_logic_vector(7 downto 0);
	signal PCData		:		std_logic_vector(7 downto 0) := x"AA";
begin
	clk <= not(clk) after 10ns;
	UUT:UART_rx
	generic map
	(
		DATA_WIDTH => 8,
      SYS_CLK_FREQ => 50000000,
      BAUD_RATE => 115200
	)
	port map
	(
		rst => rst,
		clk => clk,			
		rs232_rx => rs232_rx,		
		IRQ_clear => IRQ_clear,	
		IRQ_rx => IRQ_rx,		
		data_rx => data_rx		
	);
	Process1:process
	begin
		rst <= '0';
		rs232_rx <= '1';
		IRQ_clear <= '0';
		wait for 100ns;
		rst <= '1';
		IRQ_clear <= '0';
		wait for 100ns;
		rs232_rx <= '0';
		wait for 8.7us;
		rs232_rx <= PCData(0);
		wait for 8.7us;
		rs232_rx <= PCData(1);
		wait for 8.7us;
		rs232_rx <= PCData(2);
		wait for 8.7us;
		rs232_rx <= PCData(3);
		wait for 8.7us;
		rs232_rx <= PCData(4);
		wait for 8.7us;
		rs232_rx <= PCData(5);
		wait for 8.7us;
		rs232_rx <= PCData(6);
		wait for 8.7us;
		rs232_rx <= PCData(7);
		wait for 8.7us;
		rs232_rx <= '1';
		wait for 8.7us;
		wait for 50ns;
		wait until rising_edge(clk);
		IRQ_clear <= '1';
		wait until rising_edge(clk);
		IRQ_clear <= '0';
		wait;
	end process;
end rtl;