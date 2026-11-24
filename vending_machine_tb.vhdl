library ieee;
use ieee.std_logic_1164.all;

entity vending_machine_tb is
end entity vending_machine_tb;

architecture sim of vending_machine_tb is
    constant CLK_PERIOD : time := 20 ns;
    signal clk, rst, c500, c1000 : std_logic := '0';
    signal item, change500       : std_logic;

    procedure insert_coin(
        signal s_c500, s_c1000 : out std_logic;
        constant v500, v1000   : in  std_logic;
        constant exp_item, exp_chg : in std_logic;
        signal clk_sig, obs_item, obs_chg : in std_logic
    ) is
    begin
        s_c500  <= v500;
        s_c1000 <= v1000;
        wait for 4 ns; 
        assert obs_item = exp_item and obs_chg = exp_chg
            report "Output mismatch!" severity error;
        wait until rising_edge(clk_sig);
        wait for 2 ns;
        s_c500  <= '0';
        s_c1000 <= '0';
        wait for 14 ns;
    end procedure;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.vending_machine
        port map (clk => clk, rst => rst, c500 => c500, c1000 => c1000, item => item, change500 => change500);

    stim : process
    begin
        rst <= '1';
        wait for 15 ns;
        rst <= '0';

        -- ketika 500 + 1000 = 1500 (item = 1, change500 = 0)
        insert_coin(c500, c1000, '1', '0', '0', '0', clk, item, change500);
        insert_coin(c500, c1000, '0', '1', '1', '0', clk, item, change500);

        -- ketika 1000 + (tolak 500&1000) + 1000 = 2000 (item = 1, change500 = 1)
        insert_coin(c500, c1000, '0', '1', '0', '0', clk, item, change500);
        insert_coin(c500, c1000, '1', '1', '0', '0', clk, item, change500); 
        insert_coin(c500, c1000, '0', '1', '1', '1', clk, item, change500); 

        -- ketika 500 + 500 + 500 = 1500 (item = 1, change500 = 0)
        insert_coin(c500, c1000, '1', '0', '0', '0', clk, item, change500);
        insert_coin(c500, c1000, '1', '0', '0', '0', clk, item, change500);
        insert_coin(c500, c1000, '1', '0', '1', '0', clk, item, change500);

        report "PASS: Vending machine passed 1500, 2000 (with change), and simultaneous coin rejection!" severity note;
        std.env.stop;
    end process stim;
end architecture sim;
