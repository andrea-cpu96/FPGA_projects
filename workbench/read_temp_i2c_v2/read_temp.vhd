library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_temp is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;

        i2c_scl     : inout std_logic;
        i2c_sda     : inout std_logic;

        valid_temp    : out std_logic      
    );
end entity;

architecture rtl of read_temp is
    
    -- I2C control signals
    signal internal_reset  : std_logic;
    signal i2c_trigger     : std_logic;
    signal i2c_stop        : std_logic;
    signal i2c_restart     : std_logic;
    signal i2c_rw          : std_logic;
    signal i2c_ack_nack    : std_logic;
    signal i2c_din         : std_logic_vector(7 downto 0);
    signal i2c_dout        : std_logic_vector(7 downto 0);
    signal i2c_busy        : std_logic;

    -- State machine
    type state_t is (
        IDLE, WAIT_STATE, START_BIT, WAIT_ADDR_HIGH,
        WAIT_ADDR_LOW, TRIG_READ, WAIT_READ_HIGH, WAIT_READ_LOW
    );
    signal state : state_t;
     
begin

    i2c_core : entity work.i2c_controller
        port map (
            clock       => clk,
            reset       => internal_reset,
            trigger     => i2c_trigger,
            restart     => i2c_restart,
            last_byte   => i2c_stop,
            address     => "1001000",
            read_write  => i2c_rw,
            write_data  => i2c_dout,
            read_data   => i2c_din,
            ack_error   => i2c_ack_nack,
            busy        => i2c_busy,
            scl         => i2c_scl,
            sda         => i2c_sda
        );
    
    -- Simple state machine to test I2C
    process(clk, reset)
        variable wait_counter : unsigned(31 downto 0) := (others => '0');
    begin
        if reset = '0' then  -- INVERTED: reset active LOW
            state <= IDLE;
            i2c_trigger <= '0';
            i2c_stop <= '0';
            i2c_restart <= '0';
            i2c_rw <= '0';
            i2c_dout <= (others => '0');
            internal_reset <= '1';

        elsif rising_edge(clk) then
            case state is

                when IDLE =>
                    if i2c_busy = '0' then
                        internal_reset <= '0';
                        i2c_trigger <= '0';
                        i2c_stop <= '0';
                        i2c_restart <= '0';
                        i2c_rw <= '0';
                        i2c_dout <= (others => '0');
                        state <= WAIT_STATE;
                    end if;

                when WAIT_STATE =>
                    wait_counter := wait_counter + 1;
                    if wait_counter = 1000000 then
                        wait_counter := (others => '0');
								valid_temp <= '0';
                        state <= START_BIT;
                    end if;

                when START_BIT =>
                    i2c_rw <= '1';
                    i2c_stop <= '0';
                    i2c_trigger <= '1';
                    state <= WAIT_ADDR_HIGH;

                when WAIT_ADDR_HIGH =>
                    i2c_trigger <= '0';
                    if i2c_busy = '1' then
                        state <= WAIT_ADDR_LOW;
                    end if;

                when WAIT_ADDR_LOW =>
                    if i2c_busy = '0' then
                        state <= TRIG_READ;
                    end if;

                when TRIG_READ =>
                    i2c_stop <= '1';
                    i2c_trigger <= '1';
                    state <= WAIT_READ_HIGH;

                when WAIT_READ_HIGH =>
                    i2c_trigger <= '0';
                    if i2c_busy = '1' then
                        state <= WAIT_READ_LOW;
                    end if;

					 when WAIT_READ_LOW =>
						  if i2c_busy = '0' then
								if unsigned(i2c_din) >= 10 and unsigned(i2c_din) <= 35 then
									valid_temp <= '1';
								else
									valid_temp <= '0';
								end if;
								state <= IDLE;
						  end if;

            end case;
        end if;
    end process;

end architecture;
