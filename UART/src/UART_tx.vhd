library ieee;
use ieee.std_logic_1164.all;

entity UART_tx is
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
end entity;

architecture rtl of UART_tx is
component Serializer is
	generic
	(
		DATA_WIDTH	: integer := 8;
		DEFAULT_STATE	:	std_logic := '1'
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		shift_en		:		in std_logic;
		load			:		in std_logic;
		Din			:		in std_logic_vector(DATA_WIDTH-1 downto 0);
		Dout			:		out std_logic
	);
end component;
component BaudClkGenerator is
    generic 
	 (
        SYS_CLK_FREQ   : integer := 50000000;
        BAUD_RATE      : integer := 115200;
        NUMBER_OF_CLK  : integer := 10;
		  UART_RX		  : boolean := false
    );
    port 
	 (
        rst      : in  std_logic;
        clk      : in  std_logic;
        start    : in  std_logic;
        baudClk  : out std_logic;
        ready    : out std_logic
    );
end component;
signal baudClk : std_logic; 
signal TxPacket : std_logic_vector(RS232_DATA_BITS+1 downto 0);
begin
	TxPacket <= '1' & TxData & '0';
	UART_SERIALIZER_INST:Serializer
	generic map
	(
		DATA_WIDTH	=> RS232_DATA_BITS+2,
		DEFAULT_STATE => '1'
	)
	port map
	(
		rst => rst,		
		clk => clk,	
		shift_en => baudClk,	
		load => TxStart,	
		Din => TxPacket,	
		Dout => UART_tx_pin
	);
	UART_BIT_TIMING_INST:BaudClkGenerator
    generic map
	 (
        SYS_CLK_FREQ   => SYS_CLK_FREQ,
        BAUD_RATE      => BAUD_RATE,
        NUMBER_OF_CLK  => RS232_DATA_BITS+2,
		  UART_RX		  => false
    )
    port map 
	 (
        rst => rst,	 
        clk => clk,	     
        start => TxStart,	    
        baudClk => baudClk,	 
        ready => TxReady  
    );
end rtl;
