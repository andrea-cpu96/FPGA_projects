library ieee;
use ieee.std_logic_1164.all;

entity TopLevelModule is
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
end entity;
 
architecture rtl of TopLevelModule is
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
	type SMType is (IDLE, START_TRANSMITTER);
	signal SMVariable : SMType;
	signal TxStart : std_logic;
	signal TxReady : std_logic;
	signal IRQ_rx : std_logic;
	signal data_rx : std_logic_vector(RS232_DATA_BITS-1 downto 0);
begin
	 UART_tx_inst:UART_tx
    generic map
	 (
		RS232_DATA_BITS => RS232_DATA_BITS,
		BAUD_RATE => BAUD_RATE,
		SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
	 (
		rst => rstn,
		clk => clk,
		TxStart => TxStart,
		TxData => data_rx,
		TxReady => TxReady,
		UART_tx_pin => UART_tx_pin
    );
   UART_rx_inst:UART_rx
	generic map
	(
		DATA_WIDTH => RS232_DATA_BITS,
      SYS_CLK_FREQ => SYS_CLK_FREQ,
      BAUD_RATE => BAUD_RATE
	)
	port map
	(
		rst => rstn,
		clk => clk,
		rs232_rx => UART_rx_pin,
		IRQ_clear => TxStart,
		IRQ_rx => IRQ_rx,
		data_rx => data_rx
	);
	Process1:process(rstn, clk)
	begin
		if rstn = '0' then
			SMVariable <= IDLE;
			TxStart <= '0';
		elsif rising_edge(clk) then
			case SMVariable is
				when IDLE => 
					if IRQ_rx = '1' and TxReady = '1' then 
						SMVariable <= START_TRANSMITTER;
						TxStart <= '1';
					end if;
				when START_TRANSMITTER => 
					TxStart <= '0';
					SMVariable <= IDLE;  
				when others => 
					SMVariable <= IDLE;
				end case;
		end if;
	end process;	
end rtl;