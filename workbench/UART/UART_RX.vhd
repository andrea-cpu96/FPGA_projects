library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX is
    generic (
        G_CLK_FREQ : natural := 50_000_000;
        G_BAUD     : natural := 115_200
    );
    port (
        clk : in  std_logic;
        rst_n : in  std_logic;
        r : in  std_logic;
        data_in : in  std_logic;
        rx_valid : out std_logic;
        data_rx : out std_logic_vector(7 downto 0);
        rx_busy : out std_logic
    );
end entity UART_RX;

architecture rtl of UART_RX is

    constant C_DIVIDER : natural := G_CLK_FREQ / G_BAUD;
    
    signal baud_tick : std_logic;
    signal shift : std_logic;               -- stays combinatorial: consumed only
                                            -- by the S2P register on clk edges
    signal baud_enable : std_logic;
    signal rx_valid_r : std_logic;          -- registered rx_valid strobe
    signal rx_busy_r : std_logic := '0';    -- registered rx_busy status
    signal data_in_meta : std_logic := '1'; -- 1st sync stage (metastable-prone)
    signal data_in_sync : std_logic := '1'; -- synchronized RXD (the only
                                            -- source used downstream)
    signal count : natural range 0 to 7 := 0;

    type state_t is (IDLE, WAIT_START_BIT, START_BIT, DATA_BITS, STOP_BIT);
    signal state: state_t;
    signal nstate: state_t;

begin

    u_brg : entity work.baudrate_gen(rtl)
        generic map (
            G_PHASE_OFFSET => C_DIVIDER / 2    -- first tick at mid start bit
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            enable => baud_enable,
            divider => C_DIVIDER,
            baud_tick => baud_tick
        );

    u_s2p : entity work.serial_to_parallel(rtl)
        port map (
            clk => clk,
            rst_n => rst_n,
            shift => shift,
            data_in => data_in_sync,        -- synchronized line, not the raw pin
            data_out => data_rx
        );

    -- 2-FF input synchronizer: on a real board RXD is an asynchronous pin
    -- (driven by the remote transmitter's clock domain). The first stage may
    -- go metastable; the second stage provides a clean sample for the FSM
    -- start detection and the S2P register. Never read the raw data_in pin
    -- anywhere downstream of this process.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                data_in_meta <= '1';        -- serial line idles high
                data_in_sync <= '1';
            else
                data_in_meta <= data_in;
                data_in_sync <= data_in_meta;
            end if;
        end if;
    end process;

    -- Sequential logic

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                state <= IDLE;
                count <= 0;
                rx_valid_r <= '0';
                rx_busy_r <= '0';
            else
                state <= nstate;

                -- Registered status output (module outputs are FF-driven)
                if state = IDLE then
                    rx_busy_r <= '0';
                else
                    rx_busy_r <= '1';
                end if;

                -- rx_valid is a registered strobe. The combinatorial decode
                -- (state = STOP_BIT and baud_tick) glitches for one delta at
                -- the edge that enters STOP_BIT, because state is already
                -- updated while the old tick is still high. Here state is
                -- sampled before the register updates, so that race is
                -- unreachable and the strobe is always one clean clock pulse.
                rx_valid_r <= '0';          -- default: single-clock pulse
                if state = STOP_BIT and baud_tick = '1' then
                    rx_valid_r <= '1';      -- byte complete (mid-stop tick)
                end if;

                if baud_tick = '1' then
                    if state = DATA_BITS then
                        if count = 7 then
                            count <= 0;
                        else
                            count <= count + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Combinatorial logic

    rx_busy <= rx_busy_r;                   -- glitch-free status out
    rx_valid <= rx_valid_r;                 -- glitch-free strobe out
    -- Tick phase re-armed on every frame: enable rises when the start bit is
    -- detected (not when r arrives), so the tick grid resynchronizes on the
    -- received start edge regardless of the idle-gap length. It stays high
    -- for the whole frame (data/stop bits can be '1' without dropping it).
    baud_enable <= '1' when (state = WAIT_START_BIT and data_in_sync = '0') or
                             state = START_BIT or
                             state = DATA_BITS  or
                             state = STOP_BIT
                 else '0';

    process(state, r, data_in_sync, baud_tick, count)                
	 begin
        nstate <= state;
        shift <= '0';
        case state is
            when IDLE => 
                if r = '1' then 
                    nstate <= WAIT_START_BIT; 
                end if;
            when WAIT_START_BIT =>
                if data_in_sync = '0' then
                    nstate <= START_BIT;
                end if;
            when START_BIT =>
                if baud_tick = '1' then        -- mid start bit: from here on
                    nstate <= DATA_BITS;       -- the ticks hit mid data bits
                end if;
            when DATA_BITS =>
                if baud_tick = '1' then
                    shift <= '1';
                    if count = 7 then
                        nstate <= STOP_BIT;
                    end if;
                end if;
            when STOP_BIT =>
                if baud_tick = '1' then
                    nstate <= IDLE;         -- frame done; the rx_valid strobe
                end if;                     -- is generated registered (seq proc)
        end case;
    end process;

end architecture rtl;