-- baudrate_gen.vhd
-- Baud Rate Generator (BRG): divides the system clock into a single-cycle
-- baud_tick pulse. Reusable, project-independent module.
-- Placeholder file -- implementation pending (see ARCHITECTURE.md, Section 4.3).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudrate_gen is
    generic (
        G_PHASE_OFFSET : natural := 0   -- counter preload while disabled: the
                                        -- first tick lands `divider - G_PHASE_OFFSET`
                                        -- edges after enable rises. 0 = legacy
                                        -- (TX); divider/2 = mid-bit sampling (RX)
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        enable : in std_logic;
        divider  : in  integer;
        baud_tick : out std_logic
    );
end entity baudrate_gen;

architecture rtl of baudrate_gen is

    signal counter : integer := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                counter <= 0;
            elsif enable = '0' then
                counter <= G_PHASE_OFFSET;  -- pre-arm the tick phase while idle
            elsif counter = divider - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Combinational terminal-count pulse: a clocked consumer samples the
    -- first tick exactly `divider` edges after enable rises. A registered
    -- tick would add one extra cycle of latency and stretch the UART start
    -- bit to divider+1 clock cycles (framing error).
    baud_tick <= '1' when enable = '1' and counter = divider - 1 else '0';

end architecture rtl;