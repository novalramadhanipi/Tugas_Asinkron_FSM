library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is
    port (clk, rst        : in  std_logic;
          c500, c1000     : in  std_logic;
          item, change500 : out std_logic);
end entity vending_machine;

architecture mealy of vending_machine is
    type state_t is (S0, S500, S1000);
    signal state, next_state : state_t;
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

    -- (2) Combinational logic F + G
    logic_fg : process (all)
    begin
        next_state <= state;
        item       <= '0';
        change500  <= '0';

        -- Jika 11 atau koin masuk bersamaan, tolak dan pertahankan state
        if c500 = '1' and c1000 = '1' then
            next_state <= state;
        else
            case state is
                when S0 =>
                    if c500 = '1' then
                        next_state <= S500;
                    elsif c1000 = '1' then
                        next_state <= S1000;
                    end if;

                when S500 =>
                    if c500 = '1' then
                        next_state <= S1000;
                    elsif c1000 = '1' then
                        next_state <= S0;
                        item       <= '1'; -- total 1.500
                    end if;

                when S1000 =>
                    if c500 = '1' then
                        next_state <= S0;
                        item       <= '1'; -- total 1.500
                    elsif c1000 = '1' then
                        next_state <= S0;
                        item       <= '1'; -- total 2.000
                        change500  <= '1'; -- kembalian 500
                    end if;
            end case;
        end if;
    end process logic_fg;
end architecture mealy;
