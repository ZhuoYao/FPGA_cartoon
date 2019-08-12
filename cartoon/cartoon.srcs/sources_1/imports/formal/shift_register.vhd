library ieee;
use ieee.std_logic_1164.all;


entity sr5 is 
    port(
        clk: in std_logic;
        in1: in std_logic_vector(4 downto 0);
        enable: in std_logic;
        q0, q1, q2, q3, q4: out std_logic_vector(4 downto 0)
    );
end sr5;


architecture behavioral of sr5 is
    signal o1, o2, o3, o4, o5: std_logic_vector(4 downto 0);
    begin
        process(clk)
        begin
            if (rising_edge(clk)) then
                if (enable='1') then
                    o1 <= in1;
                    o2 <= o1;
                    o3 <= o2;
                    o4 <= o3;
                end if;
            end if;
        end process;
        q0 <= in1;
        q1 <= o1;
        q2 <= o2;
        q3 <= o3;
        q4 <= o4;
    end behavioral;
