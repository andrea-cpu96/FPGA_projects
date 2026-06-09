library ieee;
use ieee.std_logic_1164.all;

entity UART_rx is
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
end entity;
 
architecture rtl of UART_rx is
	component Synchronizer is
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
	end component;
	component BaudClkGenerator is
    generic (
        SYS_CLK_FREQ   : integer := 50000000;
        BAUD_RATE      : integer := 115200;
        NUMBER_OF_CLK  : integer := 10;
		  UART_RX		  : boolean := false
    );
    port (
        rst      : in  std_logic;
        clk      : in  std_logic;
        start    : in  std_logic;
        baudClk  : out std_logic;
        ready    : out std_logic
    );
	end component;
	component ShiftRegister is
	generic
	(
		CHAIN_LENGTH : integer := 8;
		SHIFT_DIRECTION : character := 'R'
	);
	port
	(
		rst			:		in std_logic;
		clk			:		in std_logic;
		shift_en		:		in std_logic;
		Din			:		in std_logic;
		Dout			:		out std_logic_vector(CHAIN_LENGTH-1 downto 0)
	);
	end component;
	type FSMDataType is (IDLE, COLLECT_RS232_DATA, ASSERT_IRQ);
	signal FSMVariable : FSMDataType;
	signal rs232_rx_sync : std_logic;
	signal start : std_logic;
	signal baudClk : std_logic;
	signal ready : std_logic;
	signal rs232_rx_sync_delay : std_logic;
	signal rs232_falling_edge : std_logic;
begin
	Synchronizer_inst:Synchronizer
	generic map
	(
		IDLE_STATE => '1'
	)
	port map
	(
		rst	=> rst,
		clk	=> clk,
		async => rs232_rx,
		sync	=> rs232_rx_sync
	);
	BaudClkGenerator_inst:BaudClkGenerator
   generic map 
	(
        SYS_CLK_FREQ => SYS_CLK_FREQ,
        BAUD_RATE => BAUD_RATE,
        NUMBER_OF_CLK => DATA_WIDTH+1,
		  UART_RX => true
    )
    port map
	 (
        rst => rst,
        clk => clk,
        start => start,
        baudClk => baudClk,
        ready => ready
    );
	ShiftRegister_inst:ShiftRegister
	generic map
	(
		CHAIN_LENGTH => DATA_WIDTH,
		SHIFT_DIRECTION => 'R'
	)
	port map
	(
		rst => rst,
		clk => clk,
		shift_en => baudClk,
		Din => rs232_rx_sync,
		Dout => data_rx
	);
	Falling_edge_detect:process(rst, clk)
	begin
		if rst = '0' then
			rs232_rx_sync_delay <= '1';
			rs232_falling_edge <= '0';
		elsif rising_edge(clk) then
			rs232_rx_sync_delay <= rs232_rx_sync;
			if rs232_rx_sync = '0' and rs232_rx_sync_delay = '1' then
				rs232_falling_edge <= '1';
			else 
				rs232_falling_edge <= '0';
			end if;
		end if;
	end process;
	FSMProcess:process(rst, clk)
	begin
		if rst = '0' then
			IRQ_rx <= '0'; 
			start <= '0';
			FSMVariable <= IDLE;
		elsif rising_edge(clk) then
			if IRQ_clear = '1' then
				IRQ_rx <= '0'; 
			end if;
			case FSMVariable is
				when IDLE =>
					if rs232_falling_edge = '1' then
						FSMVariable <= COLLECT_RS232_DATA;
						start <= '1';
					end if;
				when COLLECT_RS232_DATA =>
					start <= '0';
					if ready = '1' then
						FSMVariable <= ASSERT_IRQ;
					end if;
				when ASSERT_IRQ =>
					IRQ_rx <= '1';
					FSMVariable <= IDLE;
				when others =>
					FSMVariable <= IDLE;
			end case;
		end if;
	end process;	
end rtl;