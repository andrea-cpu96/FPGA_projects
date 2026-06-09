library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_temp is
    port (
        clk   		: in  std_logic;
        reset 		: in  std_logic;

        i2c_scl   : inout std_logic;
        i2c_sda   : inout std_logic
    );
end entity;

architecture rtl of read_temp is
    
    -- I2C control signals
	 signal internal_reset : std_logic;
    signal i2c_start  	: std_logic;
    signal i2c_stop   	: std_logic;
	 signal i2c_restart 	: std_logic;
    signal i2c_rw 	 	: std_logic;
    signal i2c_ack_nack	: std_logic;
    signal i2c_din    	: std_logic_vector(7 downto 0);
    signal i2c_dout   	: std_logic_vector(7 downto 0);
    signal i2c_busy   	: std_logic;
	 
    -- State machine
    type state_t is (IDLE, START_BIT, ADDR_WRITE, DATA_READ, STOP_BIT, WAIT_STATE);
    signal state : state_t;
	 
begin

    i2c_core : entity work.i2c_controller
        port map (
				clock 		=> clk,							
				reset 		=> internal_reset,						
				trigger 		=> i2c_start,		
				restart 		=> i2c_restart,
				last_byte 	=> i2c_stop,
				address 		=> "1000001",	
				read_write 	=> i2c_rw,		
				write_data 	=> i2c_dout, 
				read_data 	=> i2c_din,
				ack_error 	=> i2c_ack_nack,				
				busy 			=> i2c_busy, 						
				scl 			=> i2c_scl,				
				sda 			=> i2c_sda
        );
    
    -- Simple state machine to test I2C
    process(clk, reset)
    begin
        if reset = '0' then  -- INVERTED: reset active LOW
            state <= IDLE;
            i2c_start <= '0';
            i2c_stop <= '0';
				i2c_restart <= '0';
            i2c_rw <= '0';
            i2c_dout <= (others => '0');
            internal_reset <= '1';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
							state <= WAIT_STATE;
         
                when WAIT_STATE =>
							state <= START_BIT;

                when START_BIT =>       
                     state <= ADDR_WRITE;
                    
                when ADDR_WRITE =>
                     state <= DATA_READ;
                    
                when DATA_READ =>
                     state <= STOP_BIT;
                    
                when STOP_BIT =>
                        state <= IDLE;
            end case;
        end if;
    end process;

end architecture;