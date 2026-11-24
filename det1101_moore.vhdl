library ieee;
use ieee.std_logic_1164.all;
use work.det1101_pkg.all;

entity det1101_moore is
    port (clk, rst, x : in  std_logic;
          z           : out std_logic);
end entity det1101_moore;

architecture three_proc of det1101_moore is
    signal state, next_state : moore_t;
begin
    -- (1) State register
    reg : process (clk, rst)
    begin
        if rst = '1' then
            state <= A;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process reg;

    -- (2) Next-state logic F
    logic_f : process (all)
    begin
        next_state <= state;
        case state is
            when A => if x = '1' then next_state <= B; else next_state <= A; end if;
            when B => if x = '1' then next_state <= C; else next_state <= A; end if;
            when C => if x = '0' then next_state <= D; else next_state <= C; end if;
            when D => if x = '1' then next_state <= E; else next_state <= A; end if;
            when E => if x = '1' then next_state <= C; else next_state <= A; end if;
        end case;
    end process logic_f;

    -- (3) Output logic G (hanya membaca state)
    logic_g : process (all)
    begin
        case state is
            when E      => z <= '1';
            when others => z <= '0';
        end case;
    end process logic_g;
end architecture three_proc;
