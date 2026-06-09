library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity TopLevelModule_tb is
	generic
	(
		RS232_DATA_BITS : integer := 8
	);
end entity;
 
architecture rtl of TopLevelModule_tb is
	component TopLevelModule is
	generic
	(
		RS232_DATA_BITS : integer := 8;
		BAUD_RATE	: integer := 115200;
		SYS_CLK_FREQ : integer := 50000000
	);
	port
	(
		rstn      	: in  std_logic;
		clk      	: in  std_logic;
		UART_rx_pin : in std_logic;
		UART_tx_pin : out std_logic
	);
	end component;
	signal rstn      	: std_logic;
	signal clk      	: std_logic := '0';
	signal UART_rx_pin : std_logic; 
	signal UART_tx_pin : std_logic;
begin
	clk <= not(clk) after 10ns;
	UUT:TopLevelModule
	generic map
	(
		RS232_DATA_BITS => RS232_DATA_BITS,
		BAUD_RATE => 115200,
		SYS_CLK_FREQ => 50000000
	)
	port map
	(
		rstn => rstn,
		clk => clk,
		UART_rx_pin => UART_rx_pin,
		UART_tx_pin => UART_tx_pin
	);
	Process1:process(rstn, clk)
		variable TransmitDataVector : std_logic_vector(RS232_DATA_BITS-1 downto 0); 
		procedure TRANSMIT_CHARACTER
		(
			constant TransmitData : in integer
		) is
		begin
			TransmitDataVector := std_logic_vector(to_unsigned(TransmitData, RS232_DATA_BITS));
			UART_rx_pin <= '0';
			wait for 8.7us;
			for i in 0 to  RS232_DATA_BITS-1 loop
				UART_rx_pin <= TransmitDataVector(i);
				wait for 8.7us;
			end loop;
			UART_rx_pin <= '1';
			wait for 8.7us;
		end procedure;
	begin
		rstn <= '0';
		UART_rx_pin <=  '1';
		wait for 100ns;
		rstn <= '0';
		wait for 100ns;
		TRANSMIT_CHARACTER(127);
		wait;
	end process;	
end rtl;