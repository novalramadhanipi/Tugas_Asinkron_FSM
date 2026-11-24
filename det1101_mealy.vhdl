library ieee;
use ieee.std_logic_1164.all;
use work.det1101_pkg.all;

entity det1101_mealy is
    port (clk, rst, x : in  std_logic;
          z           : out std_logic);
end entity det1101_mealy;

architecture two_proc of det1101_mealy is
    signal state, next_state : mealy_t;
begin
    -- (1) State register
    reg : process (clk, rst)
    begin
        if rst = '1' then
            state <= S0;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process reg;

    -- (2) Combinational logic
    logic_fg : process (all)
    begin
        next_state <= state;
        z          <= '0';
        case state is
            when S0 =>
                if x = '1' then next_state <= S1; end if;
            when S1 =>
                if x = '1' then next_state <= S2; else next_state <= S0; end if;
            when S2 =>
                if x = '0' then next_state <= S3; end if;
            when S3 =>
                if x = '1' then
                    next_state <= S1; -- Overlap: bit '1' terakhir jadi awal pola baru
                    z          <= '1';
                else
                    next_state <= S0;
                end if;
        end case;
    end process logic_fg;
end architecture two_proc;
