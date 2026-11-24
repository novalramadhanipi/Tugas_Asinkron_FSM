library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity traffic_light is
    generic (CLKS_PER_SEC : positive := 5);
    port (clk, rst                   : in  std_logic;
          ns_r, ns_y, ns_g           : out std_logic;
          ew_r, ew_y, ew_g           : out std_logic);
end entity traffic_light;

architecture fsmd of traffic_light is
    type state_t is (NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW);
    signal state, next_state : state_t;

    -- Sinyal Datapath & Status
    signal clk_cnt  : integer range 0 to CLKS_PER_SEC - 1 := 0;
    signal tick     : std_logic;
    signal sec_cnt  : integer range 1 to 8 := 8;
    signal load_val : integer range 1 to 8;
    signal load_cnt : std_logic;
    signal expired  : std_logic;
begin

    -- frequency divider (menghasilkan clock enable 'tick')
    freq_div : process (clk, rst)
    begin
        if rst = '1' then
            clk_cnt <= 0;
            tick    <= '0';
        elsif rising_edge(clk) then
            if clk_cnt = CLKS_PER_SEC - 1 then
                clk_cnt <= 0;
                tick    <= '1';
            else
                clk_cnt <= clk_cnt + 1;
                tick    <= '0';
            end if;
        end if;
    end process freq_div;

    -- seconds counter
    counter_dp : process (clk, rst)
    begin
        if rst = '1' then
            sec_cnt <= 8; -- Durasi awal state NS_GREEN adalah 8 detik
        elsif rising_edge(clk) then
            if load_cnt = '1' then
                sec_cnt <= load_val;
            elsif tick = '1' then
                if sec_cnt > 1 then
                    sec_cnt <= sec_cnt - 1;
                end if;
            end if;
        end if;
    end process counter_dp;

    -- status expired aktif ketika detik terakhir sedang berjalan
    expired <= '1' when (sec_cnt = 1) else '0';

    -- control unit (Moore FSM)
    reg : process (clk, rst)
    begin
        if rst = '1' then
            state <= NS_GREEN;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process reg;

    logic_f : process (all)
    begin
        next_state <= state;
        load_cnt   <= '0';
        load_val   <= 8;

        if tick = '1' and expired = '1' then
            load_cnt <= '1';
            case state is
                when NS_GREEN =>
                    next_state <= NS_YELLOW;
                    load_val   <= 2;
                when NS_YELLOW =>
                    next_state <= EW_GREEN;
                    load_val   <= 8;
                when EW_GREEN =>
                    next_state <= EW_YELLOW;
                    load_val   <= 2;
                when EW_YELLOW =>
                    next_state <= NS_GREEN;
                    load_val   <= 8;
            end case;
        end if;
    end process logic_f;

    -- Output logic lampu lalu lintas (Moore)
    logic_g : process (all)
    begin
        ns_r <= '0'; ns_y <= '0'; ns_g <= '0';
        ew_r <= '0'; ew_y <= '0'; ew_g <= '0';

        case state is
            when NS_GREEN => ns_g <= '1'; ew_r <= '1';
            when NS_YELLOW => ns_y <= '1'; ew_r <= '1';
            when EW_GREEN => ns_r <= '1'; ew_g <= '1';
            when EW_YELLOW => ns_r <= '1'; ew_y <= '1';
        end case;
    end process logic_g;
end architecture fsmd;
