-- baudrate_gen_tb.vhd
-- Self-checking testbench for baudrate_gen (BRG).
--
-- Verifies, by sampling on rising edges (same convention as the DUT):
--   1. baud_tick period  == divider clock cycles (tick-to-tick)
--   2. first tick after reset release arrives exactly divider edges
--      after the last reset edge (counter re-alignment)
--   3. pulse width == 1 clock cycle (for divider >= 2)
--   4. all of the above re-verified after a mid-run reset,
--      for divider = 4, 10, 433 (115200 Bd @ 50 MHz) and 5208 (9600 Bd)
--
-- NOTE: divider = 1 is deliberately not tested: the DUT then ticks on every
-- cycle, so baud_tick stays high continuously (period == 1, no isolated pulse).
-- NOTE: divider = 0 would hang the DUT (counter never matches -1).
--
-- Simulation-only file: do NOT register it in UART.qsf.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudrate_gen_tb is
end entity baudrate_gen_tb;

architecture sim of baudrate_gen_tb is

    constant C_CLK_PERIOD : time := 20 ns;   -- 50 MHz reference clock

    signal sim_done : boolean := false;

    -- DUT interface
    signal clk       : std_logic := '0';
    signal rst_n     : std_logic := '0';
    signal enable    : std_logic := '1';
    signal divider   : integer   := 4;
    signal baud_tick : std_logic;

    -- checker -> summary
    signal errors     : natural := 0;
    signal ticks_seen : natural := 0;

begin

    ---------------------------------------------------------------
    -- DUT
    ---------------------------------------------------------------
    dut : entity work.baudrate_gen
        port map (
            clk       => clk,
            rst_n     => rst_n,
            enable    => enable,
            divider   => divider,
            baud_tick => baud_tick
        );

    ---------------------------------------------------------------
    -- Clock generation (stops when sim_done)
    ---------------------------------------------------------------
    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for C_CLK_PERIOD / 2;
            clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    ---------------------------------------------------------------
    -- Stimulus
    ---------------------------------------------------------------
    stim : process
        -- assert reset, change divider, release away from a rising edge
        procedure reset_and_set(new_divider : natural) is
        begin
            wait until falling_edge(clk);
            rst_n   <= '0';
            divider <= new_divider;
            wait for 4 * C_CLK_PERIOD;   -- guarantees >= 1 reset edge
            wait until falling_edge(clk);
            rst_n   <= '1';
        end procedure;
    begin
        -- stage 1: divider = 4, quick timing check (~12 ticks)
        divider <= 4;
        rst_n   <= '0';
        wait for 4 * C_CLK_PERIOD;
        wait until falling_edge(clk);
        rst_n <= '1';
        wait for 50 * C_CLK_PERIOD;

        -- stage 2: reset in the middle of normal operation
        rst_n <= '0';
        wait for 3 * C_CLK_PERIOD;
        wait until falling_edge(clk);
        rst_n <= '1';
        wait for 50 * C_CLK_PERIOD;

        -- stage 3: divider = 10
        reset_and_set(10);
        wait for 130 * C_CLK_PERIOD;

        -- stage 4: divider = 433  (115200 Bd @ 50 MHz)
        reset_and_set(433);
        wait for (2 * 433 + 20) * C_CLK_PERIOD;

        -- stage 5: divider = 5208 (9600 Bd @ 50 MHz)
        reset_and_set(5208);
        wait for (2 * 5208 + 20) * C_CLK_PERIOD;

        -- stage 6: mid-run reset while running at divider = 5208
        rst_n <= '0';
        wait for 3 * C_CLK_PERIOD;
        wait until falling_edge(clk);
        rst_n <= '1';
        wait for (2 * 5208 + 20) * C_CLK_PERIOD;

        -- summary
        wait for 5 * C_CLK_PERIOD;
        sim_done <= true;
        wait for C_CLK_PERIOD;
        if errors = 0 then
            report "=====================================================" severity note;
            report " BRG TEST PASSED - " & integer'image(ticks_seen) &
                   " ticks checked, 0 errors" severity note;
            report "=====================================================" severity note;
        else
            report "=====================================================" severity error;
            report " BRG TEST FAILED - " & integer'image(errors) &
                   " error(s) in " & integer'image(ticks_seen) & " ticks" severity error;
            report "=====================================================" severity error;
        end if;
        wait;
    end process;

    ---------------------------------------------------------------
    -- Self-checking monitor (clocked, like the DUT)
    ---------------------------------------------------------------
    monitor : process(clk)
        variable edge_cnt    : natural := 0;   -- rising edges since last reset edge
        variable last_tick   : natural := 0;   -- edge_cnt of previous sampled tick
        variable first_tick  : boolean := true;
        variable prev_sample : std_logic := '0';
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                edge_cnt    := 0;
                last_tick   := 0;
                first_tick  := true;
                prev_sample := '0';
            else
                -- pulse width: with divider >= 2, ticks must be isolated
                if baud_tick = '1' and prev_sample = '1' then
                    report "ERROR: baud_tick high longer than 1 clock cycle"
                        severity error;
                    errors <= errors + 1;
                end if;

                edge_cnt := edge_cnt + 1;

                if baud_tick = '1' then
                    ticks_seen <= ticks_seen + 1;
                    if first_tick then
                        if edge_cnt /= divider then
                            report "ERROR: first tick after reset at edge " &
                                   integer'image(edge_cnt) & ", expected " &
                                   integer'image(divider) severity error;
                            errors <= errors + 1;
                        end if;
                        first_tick := false;
                    else
                        if edge_cnt - last_tick /= divider then
                            report "ERROR: tick period " &
                                   integer'image(edge_cnt - last_tick) &
                                   " cycles, expected " &
                                   integer'image(divider) severity error;
                            errors <= errors + 1;
                        end if;
                    end if;
                    last_tick := edge_cnt;
                end if;

                prev_sample := baud_tick;
            end if;
        end if;
    end process;


end architecture sim;
