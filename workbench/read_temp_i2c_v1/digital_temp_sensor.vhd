library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_temp_sensor is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;

        scl   : inout std_logic;
        sda   : inout std_logic;
        
        data_out : out std_logic_vector(7 downto 0);  -- I2C data output
        scl_o : out std_logic;                         -- SCL debug
        sda_o : out std_logic;                         -- SDA debug
        reset_out : out std_logic                      -- Reset status
    );
end entity;

architecture rtl of digital_temp_sensor is

    signal i2c_scl_o  : std_logic;
    signal i2c_scl_oen: std_logic;

    signal i2c_sda_o  : std_logic;
    signal i2c_sda_oen: std_logic;
    
    -- I2C control signals
    signal i2c_start  : std_logic;
    signal i2c_stop   : std_logic;
    signal i2c_read   : std_logic;
    signal i2c_write  : std_logic;
    signal i2c_ack_in : std_logic;
    signal i2c_din    : std_logic_vector(7 downto 0);
    signal i2c_dout   : std_logic_vector(7 downto 0);
    signal i2c_busy   : std_logic;
    signal i2c_ack_out: std_logic;
    
    -- Test data output
    signal temp_data  : std_logic_vector(7 downto 0);
    
    -- State machine
    type state_t is (IDLE, START_BIT, ADDR_WRITE, DATA_READ, STOP_BIT, WAIT_STATE);
    signal state : state_t;
    signal counter : integer;
    signal reset_counter : integer;
    signal internal_reset : std_logic;

begin

    i2c_core : entity work.i2c_master_top
        port map (
            clk      => clk,
            rst      => internal_reset,

            -- SDA
            sda_i    => sda,
            sda_o    => i2c_sda_o,
            sda_oen  => i2c_sda_oen,

            -- SCL
            scl_i    => scl,
            scl_o    => i2c_scl_o,
            scl_oen  => i2c_scl_oen,

            -- Control signals
            clk_cnt  => to_unsigned(125, 16),  -- 50MHz / (125*4) = 100kHz I2C
            start    => i2c_start,
            stop     => i2c_stop,
            read     => i2c_read,
            write    => i2c_write,
            ack_in   => i2c_ack_in,
            din      => i2c_din,
            dout     => i2c_dout,
            ack_out  => i2c_ack_out,
            busy     => i2c_busy
        );
	  
    -- SDA open-drain
    sda <= '0' when i2c_sda_oen = '0' else 'Z';
    
    -- SCL open-drain
    scl <= '0' when i2c_scl_oen = '0' else 'Z';
    
    -- Output data from I2C
    data_out <= temp_data;
    
    -- Debug outputs
    scl_o <= scl;
    sda_o <= sda;
    reset_out <= internal_reset;
    
    -- Simple state machine to test I2C
    process(clk, reset)
    begin
        if reset = '0' then  -- INVERTED: reset active LOW
            state <= IDLE;
            i2c_start <= '0';
            i2c_stop <= '0';
            i2c_read <= '0';
            i2c_write <= '0';
            i2c_ack_in <= '0';
            i2c_din <= (others => '0');
            temp_data <= (others => '0');
            counter <= 0;
            reset_counter <= 0;
            internal_reset <= '1';
        elsif rising_edge(clk) then
            -- Auto-reset: keep internal reset high for 1000 cycles, then release permanently
            if reset_counter < 1000 then
                reset_counter <= reset_counter + 1;
                internal_reset <= '1';
            else
                internal_reset <= '0';  -- Release after boot
            end if;
            
            i2c_start <= '0';
            i2c_stop <= '0';
            i2c_read <= '0';
            i2c_write <= '0';
            i2c_ack_in <= '0';
            
            case state is
                when IDLE =>
                    counter <= 0;
                    state <= WAIT_STATE;
                    
                when WAIT_STATE =>
                    counter <= counter + 1;
                    if counter = 1000000 then  -- Wait ~10ms at 100MHz
                        state <= START_BIT;
                    end if;

                when START_BIT =>
                    i2c_start <= '1';
                    if i2c_busy = '0' then
                        state <= ADDR_WRITE;
                    end if;
                    
                when ADDR_WRITE =>
                    -- LM75 address 0x48 (A0/A1/A2 = 0 = GND), read bit = 1 => 0x91
                    i2c_din <= "10010001";
                    i2c_write <= '1';
                    if i2c_busy = '0' then
                        state <= DATA_READ;
                    end if;
                    
                when DATA_READ =>
                    i2c_read <= '1';
                    if i2c_busy = '0' then
                        temp_data <= i2c_dout;
                        state <= STOP_BIT;
                    end if;
                    
                when STOP_BIT =>
                    i2c_stop <= '1';
                    if i2c_busy = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

end architecture;