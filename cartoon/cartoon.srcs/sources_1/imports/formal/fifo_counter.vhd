library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity fifo_counter is
    port(
        clk: in std_logic;
        display_x, display_y: in std_logic_vector(10 downto 0);
        wr_en, rd_en: out std_logic
    );
end fifo_counter;

architecture behavioral of fifo_counter is

    signal count: std_logic_vector(10 downto 0) := "00000000000";

    begin
        process(clk,display_x,display_y)
        begin
            if(rising_edge(clk)) then
                if count < "00011101001" then
                    if display_x < "00000000001" then  --display_x < 1
                        wr_en <= '0';
                        rd_en <= '0';  
                    elsif display_x < "00011101000" then  --display_x < 232
                        wr_en <= '1';
                        rd_en <= '0';
                        count <= count + "00000000001";
                    elsif display_x < "00011110000" then  --display_x < 240
                        wr_en <= '1';
                        rd_en <= '1';
                    else
                        wr_en <= '0';
                        rd_en <= '0';
                    end if;
                else
                    if display_x < "00000000001" then  --display_x < 1
                        wr_en <= '0';
                        rd_en <= '0';   
                    elsif display_x < "00011110000" then   -- display_x < 240
                        wr_en <= '1';
                        rd_en <= '1';
                    else
                        wr_en <= '0';
                        rd_en <= '0';
                    end if;     
                end if;
            end if;
        end process;
    end behavioral;