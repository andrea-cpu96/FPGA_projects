library ieee;
use ieee.std_logic_1164.all;

entity UART_tx_tb is
    generic 
	 (
		RS232_DATA_BITS : integer := 8;
		BAUD_RATE	: integer := 115200;
		SYS_CLK_FREQ : integer := 50000000
    );
end entity;

architecture rtl of UART_tx_tb is
	component UART_tx is
    generic 
	 (
		RS232_DATA_BITS : integer := 8;
		BAUD_RATE	: integer := 115200;
		SYS_CLK_FREQ : integer := 50000000
    );
    port 
	 (
		rst      	: in  std_logic;
		clk      	: in  std_logic;
		TxStart 		: in  std_logic;
		TxData		: in std_logic_vector(RS232_DATA_BITS-1 downto 0);
		TxReady		: out std_logic;
		UART_tx_pin	: out std_logic
    );
	end component;
	signal rst      	: std_logic;
	signal clk      	: std_logic := '0';
	signal TxStart 		: std_logic;
	signal TxData		: std_logic_vector(RS232_DATA_BITS-1 downto 0);
	signal TxReady		: std_logic;
	signal UART_tx_pin	: std_logic;
begin
	 clk <= not(clk) after 10ns; 
	 UART_tx_inst:UART_tx
    generic map
	 (
		RS232_DATA_BITS => RS232_DATA_BITS,
		BAUD_RATE => BAUD_RATE,
		SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
	 (
		rst => rst,    	
		clk => clk,      
		TxStart => TxStart, 		
		TxData => TxData,	
		TxReady => TxReady,
		UART_tx_pin => UART_tx_pin	
    );
	 process1:process
	 begin
		rst <= '0';
		TxStart <= '0';
		TxData <= (others => '0');
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		wait until rising_edge(clk);
		TxData <= x"AA";
		TxStart <= '1';
		wait until rising_edge(clk);
		TxData <= (others => '0');
		TxStart <= '0';
		wait;	 end process;
end rtl;
