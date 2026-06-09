library ieee;
use ieee.std_logic_1164.all;

entity SevenSegmentDisplay is
port
(
	rst	:	in std_logic;
	clk	:	in std_logic;
	sw1	:	in std_logic;
	k		:	out std_logic_vector(6 downto 0);
	dp		:	out std_logic;
	A		:	out std_logic_vector(3 downto 0)
);
end entity;

architecture rtl of SevenSegmentDisplay is
	type stateType is (DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4);
	constant debounce_period : integer := 2500000;
	signal deb_counter : integer;
	signal sync : std_logic_vector(1 downto 0);
	signal sw1_sync : std_logic;
	signal sw1_deb : std_logic;
	signal sw1_deb_delay : std_logic;
	signal btn_fall : std_logic;
	signal k_int : std_logic_vector(6 downto 0);
	signal state : stateType;
	signal digit1	: integer;
	signal digit2	: integer;
	signal digit3	: integer;
	signal digit4	: integer;
	signal PeriodCounter	: integer;
	signal NumberToDisplay : integer; 
begin

	dp <= '1';
	k <= not(k_int);
	sw1_sync <= sync(1); -- not a register (just a renaming of sync(1) for readability
	
	SyncSw1:process(rst, clk)
	begin
		if rst = '0' then
			sync <= "11";
		elsif rising_edge(clk) then
			sync(0) <= sw1;
			sync(1) <= sync(0);
		end if;
	end process;
	
	DebounceProcess:process(rst, clk)
	begin
		if rst = '0' then
			deb_counter <= 0;
			sw1_deb <= '1'; -- deasserted
		elsif rising_edge(clk) then
			if sw1_sync = '0' then
				if deb_counter < debounce_period then
					deb_counter <= deb_counter + 1;
				end if;
			else
				if deb_counter > 0 then
					deb_counter <= deb_counter - 1;
				end if;
			end if;
			if deb_counter = debounce_period then
				sw1_deb <= '0';
			elsif deb_counter = 0 then
				sw1_deb <= '1';
			end if;
		end if;
	end process;

	DetectBtnFall:process(rst, clk)
	begin
		if rst = '0' then
			sw1_deb_delay <= '1';
			btn_fall <= '0';
		elsif rising_edge(clk) then
			sw1_deb_delay <= sw1_deb;
			if sw1_deb = '0' and sw1_deb_delay = '1' then
				btn_fall <= '1';
			else
				btn_fall <= '0';
			end if;
		end if;
	end process;
	
	CountInc:process(rst, clk)
	begin
		if rst = '0' then
			digit1 <= 0;
			digit2 <= 0;
			digit3 <= 0;
			digit4 <= 0;
		elsif rising_edge(clk) then
			if btn_fall = '1' then
				if digit1 < 9 then
					digit1 <= digit1 + 1;
				else
					digit1 <= 0;
					if digit2 < 9 then 
						digit2 <= digit2 + 1;
					else	
						digit2 <= 0;
						if digit3 < 9 then 
							digit3 <= digit3 + 1;
						else	
							digit3 <= 0;
							if digit4 < 9 then 
								digit4 <= digit4 + 1;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	
	-- k(0) is seg a
	-- k(1) is seg b
	-- k(2) is seg c
	-- k(3) is seg d
	-- k(4) is seg e
	-- k(5) is seg f
	-- k(6) is seg g
	DecoderProcess:process(rst, clk)
	begin
		if rst = '0' then
			k_int <= "0000000";
		elsif rising_edge(clk) then
			case NumberToDisplay is
				when 0 => k_int <= "0111111";
				when 1 => k_int <= "0000110";
				when 2 => k_int <= "1011011";
				when 3 => k_int <= "1001111";
				when 4 => k_int <= "1100110";
				when 5 => k_int <= "1101101";
				when 6 => k_int <= "1111101";
				when 7 => k_int <= "0000111";
				when 8 => k_int <= "1111111";
				when 9 => k_int <= "1100111";
				when others => k_int <= "0000000";
			end case;
		end if;
	end process;
	
	FSMProcess:process(rst, clk)
	begin
		if rst = '0' then
			state <= DIGIT_1;
			A <= "1111";
			PeriodCounter <= 0;
			NumberToDisplay <= 0;
		elsif rising_edge(clk) then
			case state is
				when DIGIT_1 =>
					A <= "1110";
					NumberToDisplay <= digit1;
					PeriodCounter <= PeriodCounter + 1;
					if PeriodCounter = 50000 then 
						PeriodCounter <= 0;
						state <= DIGIT_2;
					end if; 
				when DIGIT_2 =>
					A <= "1101";
					NumberToDisplay <= digit2;
					PeriodCounter <= PeriodCounter + 1;
					if PeriodCounter = 50000 then 
						PeriodCounter <= 0;
						state <= DIGIT_3;
					end if; 
				when DIGIT_3 =>
					A <= "1011";
					NumberToDisplay <= digit3;
					PeriodCounter <= PeriodCounter + 1;
					if PeriodCounter = 50000 then 
						PeriodCounter <= 0;
						state <= DIGIT_4;
					end if; 
				when DIGIT_4 =>
					A <= "0111";
					NumberToDisplay <= digit4;
					PeriodCounter <= PeriodCounter + 1;
					if PeriodCounter = 50000 then 
						PeriodCounter <= 0;
						state <= DIGIT_1;
					end if; 
				when others =>
					state <= DIGIT_1;
			end case;
		end if;
	end process;
	
end rtl;