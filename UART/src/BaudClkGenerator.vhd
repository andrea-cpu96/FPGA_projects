library ieee;
use ieee.std_logic_1164.all;

entity BaudClkGenerator is
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
end entity;

architecture rtl of BaudClkGenerator is
    constant BIT_PERIOD : integer := SYS_CLK_FREQ / BAUD_RATE;
	 constant HALF_BIT_PERIOD : integer := SYS_CLK_FREQ / (2*BAUD_RATE);
    signal BitPeriodCounter : integer range 0 to BIT_PERIOD;
    signal ClockLeft        : integer range 0 to NUMBER_OF_CLK;
    signal baudClk_int      : std_logic;
begin

    baudClk <= baudClk_int;

    -- Gestione start/stop
    StartStopProcess: process(rst, clk)
    begin
        if rst = '0' then
            ClockLeft <= 0;
        elsif rising_edge(clk) then
            if start = '1' then
                ClockLeft <= NUMBER_OF_CLK;
            elsif baudClk_int = '1' and ClockLeft > 0 then
                ClockLeft <= ClockLeft - 1;
            end if;
        end if;
    end process;

    -- Generazione tick baud
    BitPeriodProcess: process(rst, clk)
    begin
        if rst = '0' then
            baudClk_int      <= '0';
            BitPeriodCounter <= 0;
        elsif rising_edge(clk) then
            if ClockLeft > 0 then
                if BitPeriodCounter = BIT_PERIOD then
                    baudClk_int      <= '1';
                    BitPeriodCounter <= 0;  -- reset contatore
                else
                    baudClk_int      <= '0';
                    BitPeriodCounter <= BitPeriodCounter + 1;
                end if;
            else
                baudClk_int      <= '0';
					 if UART_RX = true then
						BitPeriodCounter <= HALF_BIT_PERIOD;
					else
						BitPeriodCounter <= 0;
					end if;
            end if;
        end if;
    end process;

    -- Segnale di ready
    GenerateReady: process(rst, clk)
    begin
        if rst = '0' then
            ready <= '1';
        elsif rising_edge(clk) then
            if start = '1' then
                ready <= '0';
            elsif ClockLeft = 0 then
                ready <= '1';
            end if;
        end if;
    end process;

end rtl;
