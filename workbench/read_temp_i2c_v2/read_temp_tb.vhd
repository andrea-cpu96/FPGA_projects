library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_temp_tb is
end entity;

architecture sim of read_temp_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';  -- active low
    signal i2c_scl  : std_logic;
    signal i2c_sda  : std_logic;

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

    -- LM75 slave simulation
    constant SLAVE_ADDR   : std_logic_vector(6 downto 0) := "1001000";
    constant TEMP_DATA    : std_logic_vector(7 downto 0) := "00011001";  -- 25°C

begin

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- Pull-up simulation (weak '1' when no one drives low)
    i2c_scl <= 'H';
    i2c_sda <= 'H';

    -- DUT
    uut : entity work.read_temp
        port map (
            clk     => clk,
            reset   => reset,
            i2c_scl => i2c_scl,
            i2c_sda => i2c_sda
        );

    -- Reset stimulus
    process
    begin
        reset <= '0';  -- assert reset (active low)
        wait for 200 ns;
        reset <= '1';  -- release reset
        wait;
    end process;

    -- LM75 slave simulation process
    -- Monitors SCL/SDA and responds to address match with temperature data
    lm75_slave : process
        variable bit_count    : integer := 0;
        variable received_addr : std_logic_vector(6 downto 0) := (others => '0');
        variable received_rw  : std_logic := '0';
        variable addr_match   : boolean := false;

        -- Wait for SCL rising edge (resolving 'H' as '1')
        procedure wait_scl_rise is
        begin
            wait until (i2c_scl = '1' or i2c_scl = 'H') and (i2c_scl'event);
        end procedure;

        -- Wait for SCL falling edge
        procedure wait_scl_fall is
        begin
            wait until (i2c_scl = '0') and (i2c_scl'event);
        end procedure;

        -- Detect START: SDA falls while SCL is high
        procedure wait_start is
        begin
            loop
                wait until (i2c_sda'event or i2c_scl'event);
                if (i2c_sda = '0') and (i2c_scl = '1' or i2c_scl = 'H') then
                    exit;
                end if;
            end loop;
        end procedure;

        -- Resolve 'H' to '1'
        function resolve_bit(s : std_logic) return std_logic is
        begin
            if s = 'H' or s = '1' then
                return '1';
            else
                return '0';
            end if;
        end function;

    begin
        -- Main slave loop
        loop
            addr_match := false;

            -- Wait for START condition
            wait_start;

            -- Read 7 address bits + 1 R/W bit
            for i in 6 downto 0 loop
                wait_scl_rise;
                received_addr(i) := resolve_bit(i2c_sda);
            end loop;
            wait_scl_rise;
            received_rw := resolve_bit(i2c_sda);

            -- Check address match
            if received_addr = SLAVE_ADDR then
                addr_match := true;

                -- Send ACK (drive SDA low on next SCL low)
                wait_scl_fall;
                i2c_sda <= '0';
                wait_scl_fall;
                i2c_sda <= 'Z';  -- release SDA

                if received_rw = '1' then
                    -- READ: send temperature byte
                    for i in 7 downto 0 loop
                        -- Drive data bit
                        if TEMP_DATA(i) = '1' then
                            i2c_sda <= 'Z';  -- release = pull-up = '1'
                        else
                            i2c_sda <= '0';
                        end if;
                        wait_scl_rise;
                        wait_scl_fall;
                    end loop;
                    i2c_sda <= 'Z';  -- release for NACK from master

                    -- Wait for master NACK
                    wait_scl_rise;
                    -- Master should send NACK (SDA high)
                    wait_scl_fall;
                end if;
            else
                -- No match, release bus
                i2c_sda <= 'Z';
            end if;
        end loop;
    end process;

    -- Simulation timeout
    process
    begin
        wait for 50 ms;
        report "Simulation finished" severity note;
        std.env.stop;
    end process;

end architecture;
