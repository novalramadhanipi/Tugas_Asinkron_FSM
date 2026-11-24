library ieee;
use ieee.std_logic_1164.all;

entity traffic_light_tb is
end entity traffic_light_tb;

architecture sim of traffic_light_tb is
    constant CLK_PERIOD   : time    := 10 ns; -- 100 MHz
    constant CLKS_PER_SEC : integer := 5;
    constant ONE_SEC      : time    := CLK_PERIOD * CLKS_PER_SEC;

    signal clk, rst                 : std_logic := '0';
    signal ns_r, ns_y, ns_g         : std_logic;
    signal ew_r, ew_y, ew_g         : std_logic;
    signal lamps                    : std_logic_vector(5 downto 0);
begin
    clk   <= not clk after CLK_PERIOD / 2;
    lamps <= ns_r & ns_y & ns_g & ew_r & ew_y & ew_g;

    dut : entity work.traffic_light
        generic map (CLKS_PER_SEC => CLKS_PER_SEC)
        port map (clk => clk, rst => rst,
                  ns_r => ns_r, ns_y => ns_y, ns_g => ns_g,
                  ew_r => ew_r, ew_y => ew_y, ew_g => ew_g);

    check_proc : process
    begin
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        wait until rising_edge(clk);
        rst <= '0';
        wait for 1 ns;

        -- cek NS_GREEN ("001100")
        for s in 1 to 8 loop
            assert lamps = "001100" report "Expected NS_GREEN at sec " & integer'image(s) severity error;
            wait for ONE_SEC;
        end loop;

        -- cek NS_YELLOW ("010100")
        for s in 1 to 2 loop
            assert lamps = "010100" report "Expected NS_YELLOW at sec " & integer'image(s) severity error;
            wait for ONE_SEC;
        end loop;

        -- cek EW_GREEN ("100001")
        for s in 1 to 8 loop
            assert lamps = "100001" report "Expected EW_GREEN at sec " & integer'image(s) severity error;
            wait for ONE_SEC;
        end loop;

        -- cek EW_YELLOW ("100010")
        for s in 1 to 2 loop
            assert lamps = "100010" report "Expected EW_YELLOW at sec " & integer'image(s) severity error;
            wait for ONE_SEC;
        end loop;

        -- cek kembali ke NS_GREEN ("001100")
        assert lamps = "001100" report "Did not wrap back to NS_GREEN" severity error;

        report "PASS: Traffic light sequence, durations (8s, 2s, 8s, 2s), and all 6 lamps verified!" severity note;
        std.env.stop;
    end process check_proc;
end architecture sim;
