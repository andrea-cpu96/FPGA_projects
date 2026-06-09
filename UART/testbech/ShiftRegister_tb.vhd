library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister_tb is
end entity;

architecture rtl of ShiftRegister_tb is
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
	signal rst			:		std_logic;
	signal clk			:		std_logic := '0';
	signal shift_en	:		std_logic;
	signal Din			:		std_logic;
	signal Dout			:		std_logic_vector(7 downto 0);
begin
	clk <= not(clk) after 10ns;
	UUT:ShiftRegister
	generic map
	(
		CHAIN_LENGTH => 8,
		SHIFT_DIRECTION => 'R'
	)
	port map
	(
		rst => rst,
		clk => clk,
		shift_en	=> shift_en,
		Din => Din,		
		Dout => Dout		
	);
	Process1:process
	begin
		rst <= '0';
		shift_en <= '0';
		Din <= '0';
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		
		-- RS232 transmitted here is 0x51 -> 0101 0001
	
		Din <= '1';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '0';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '0';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '0';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '1';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '0';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '1';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		
		Din <= '0';
		wait for 4.3us;
		wait until rising_edge(clk);
		shift_en <= '1';
		wait until rising_edge(clk);
		shift_en <= '0';
		wait for 4.3us;
		wait;
	end process;
end rtl;