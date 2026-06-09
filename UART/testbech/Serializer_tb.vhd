library ieee;
use ieee.std_logic_1164.all;

entity Serializer_tb is
end entity;

architecture rtl of Serializer_tb is
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
	constant DATA_WIDTH :  integer := 8;
	constant DEFAULT_STATE :  std_logic := '1';
	signal rst : std_logic;
	signal clk : std_logic := '0';
	signal shift_en : std_logic;
	signal load : std_logic;
	signal Din : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal Dout : std_logic;
begin
	clk <= not(clk) after 10ns;
	UUT:Serializer
	generic map
	(
		DATA_WIDTH => DATA_WIDTH,
		DEFAULT_STATE => DEFAULT_STATE
	)
	port map
	(
		rst => rst,
		clk => clk,
		shift_en => shift_en,
		load => load,
		Din => Din,
		Dout => Dout
	);
	Process1:process
	begin
		rst <= '0';
		shift_en <= '0';
		load <= '0';
		Din <= (others => '0');
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		wait until rising_edge(clk);
		load <= '1';
		Din <= x"AA";
		wait until rising_edge(clk);
		load <= '0';
		Din <= (others => DEFAULT_STATE);
		for i in 0 to 7 loop
			wait for 8.7us;
			wait until rising_edge(clk);
			shift_en <= '1';
			wait until rising_edge(clk);
			shift_en <= '0';	
		end loop;
		wait;
	end process;
end rtl;