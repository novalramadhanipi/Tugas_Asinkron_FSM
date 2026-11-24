library ieee;
use ieee.std_logic_1164.all;
use work.det1101_pkg.all;

entity det1101_tb is
end entity det1101_tb;

architecture sim of det1101_tb is
    constant CLK_PERIOD : time := 20 ns;
    signal clk, rst, x  : std_logic := '0';
    signal z_mealy, z_moore : std_logic;

    -- 10 bit pertama: "1101101101" (3 deteksi overlap di bit ke-4, 7, 10)
    -- bit tambahan untuk menutup seluruh (state, x) 
    constant PATTERN  : std_logic_vector(0 to 19) := "11011011010011100101";
    constant EXPECTED : std_logic_vector(0 to 19) := "00010010010000000001";

    type cov_mealy_t is array (mealy_t, std_logic range '0' to '1') of boolean;
    type cov_moore_t is array (moore_t, std_logic range '0' to '1') of boolean;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut_mealy : entity work.det1101_mealy port map (clk => clk, rst => rst, x => x, z => z_mealy);
    dut_moore : entity work.det1101_moore port map (clk => clk, rst => rst, x => x, z => z_moore);

    -- stimulus & self checking
    stim : process
        alias s_mealy is << signal .det1101_tb.dut_mealy.state : mealy_t >>;
        alias s_moore is << signal .det1101_tb.dut_moore.state : moore_t >>;
        variable cov_mealy : cov_mealy_t := (others => (others => false));
        variable cov_moore : cov_moore_t := (others => (others => false));
        variable m_cnt, mo_cnt : integer := 0;
    begin
        rst <= '1';
        wait for 15 ns;
        rst <= '0';

        for i in PATTERN'range loop
            x <= PATTERN(i);
            wait for 4 ns; -- Cek Mealy 4 ns setelah x berubah (SEBELUM rising edge)
            assert z_mealy = EXPECTED(i)
                report "Mealy mismatch at bit " & integer'image(i+1) severity error;

            -- melihat coverage sebelum clock edge state & x
            cov_mealy(s_mealy, x) := true;
            cov_moore(s_moore, x) := true;

            wait until rising_edge(clk);
            wait for 2 ns; -- Cek Moore 2 ns SETELAH rising edge
            assert z_moore = EXPECTED(i)
                report "Moore mismatch at bit " & integer'image(i+1) severity error;

            wait for 14 ns; 
        end loop;

        -- Hitung & verifikasi coverage
        for st in mealy_t loop
            for b in std_logic range '0' to '1' loop
                if cov_mealy(st, b) then m_cnt := m_cnt + 1; end if;
            end loop;
        end loop;
        for st in moore_t loop
            for b in std_logic range '0' to '1' loop
                if cov_moore(st, b) then mo_cnt := mo_cnt + 1; end if;
            end loop;
        end loop;

        assert m_cnt = 8 and mo_cnt = 10
            report "Coverage incomplete!" severity error;

        report "PASS: Mealy (before edge) & Moore (after edge) detect 1101 (4 times), coverage: " &
               integer'image(m_cnt) & "/8 Mealy, " & integer'image(mo_cnt) & "/10 Moore" severity note;
        std.env.stop;
    end process stim;
end architecture sim;
