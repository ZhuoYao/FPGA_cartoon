library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity cartoon_top is
    port(
        clk: in std_logic;
        clk_mux: in std_logic;
        R_in, G_in, B_in: in std_logic_vector(4 downto 0);
        display_x, display_y: in std_logic_vector(10 downto 0);
        R_out, G_out, B_out: out std_logic_vector(7 downto 0);
        clk_lcd: out std_logic
    );
end cartoon_top;


architecture behavioral of cartoon_top is
    component fifo_display is
        port(
            clk: in std_logic;
            din: in std_logic_vector(23 downto 0);
            wr_en: in std_logic;
            rd_en: in std_logic;
            dout: out std_logic_vector(23 downto 0);
            full: out std_logic;
            empty: out std_logic
        );
    end component;

    component cartoon is
        port(
            clk: in std_logic;
            enable: in std_logic;
            display_x, display_y: in std_logic_vector(10 downto 0);
            pixel_in: in std_logic_vector(4 downto 0);
            pixel_out: out std_logic_vector(7 downto 0)
        );
    end component;

    signal enable: std_logic := '0';
    signal R_t, G_t, B_t: std_logic_vector(7 downto 0) := "00000000";
    -- signal gray_t: std_logic_vector(15 downto 0) := "0000000000000000";
    -- signal gray, gray1, gray_out: std_logic_vector(7 downto 0) := "00000000";
    -- signal gray2: std_logic_vector(23 downto 0) := "000000000000000000000000";
    signal wr_en, rd_en: std_logic := '0';
    signal RGB1, RGB2: std_logic_vector(23 downto 0) := "000000000000000000000000";
    signal full, empty: std_logic := '0';
    signal R1, G1, B1: std_logic_vector(7 downto 0) := "00000000";
    signal p_in, p_out: std_logic_vector(7 downto 0) := "00000000";

    begin
        d1: fifo_display port map(clk, RGB1, wr_en, rd_en, RGB2, full, empty);
        cr: cartoon port map(clk, enable, display_x, display_y, R_in, R1);
        cg: cartoon port map(clk, enable, display_x, display_y, G_in, G1);
        cb: cartoon port map(clk, enable, display_x, display_y, B_in, B1);
        -- cg: convolution port map(clk, enable, display_x, display_y, gray, gray_out);
        clk_lcd <= clk;
        -- gray_t <= R_in * "00100110" + G_in * "01001011" + B_in * "00001111";
        -- gray <= gray_t(14 downto 7);

        process(clk, R_in, G_in, B_in, display_x, display_y)
        begin
            if (rising_edge(clk)) then
                if (display_x<"00000000001") then
                    R_t <= "00000000";
                    G_t <= "00000000";
                    B_t <= "00000000"; 
                    wr_en <= '0';
                    rd_en <= '0';
                    enable <= '0';
                elsif display_x < "00011101011" then
                    -- gray1 <= gray_out;
                    R_t <= R_in&R_in(2 downto 0);
                    G_t <= G_in&G_in(2 downto 0);
                    B_t <= B_in&B_in(2 downto 0); 
                    wr_en <= '1';
                    rd_en <= '0';
                    enable <= '1';
                    RGB1(23 downto 16) <= R1;
                    RGB1(15 downto 8) <= G1;
                    RGB1(7 downto 0) <= B1;
                    -- RGB1(23 downto 16) <= gray1;
                    -- RGB1(15 downto 8) <= gray1;
                    -- RGB1(7 downto 0) <= gray1;
                elsif display_x < "00011110000" then 
                    -- gray1 <= gray_out;
                    R_t <= R_in&R_in(2 downto 0);
                    G_t <= G_in&G_in(2 downto 0);
                    B_t <= B_in&B_in(2 downto 0); 
                    wr_en <= '1';
                    rd_en <= '1';
                    enable <= '1';
                    RGB1(23 downto 16) <= R1;
                    RGB1(15 downto 8) <= G1;
                    RGB1(7 downto 0) <= B1;
                    -- RGB1(23 downto 16) <= gray1;
                    -- RGB1(15 downto 8) <= gray1;
                    -- RGB1(7 downto 0) <= gray1;
                else
                    wr_en <= '0';
                    rd_en <= '1';
                    enable <= '0';
                    R_t <= RGB2(23 downto 16);
                    G_t <= RGB2(15 downto 8);
                    B_t <= RGB2(7 downto 0);
                end if; 
            end if;
        end process;
        R_out <= R_t;
        G_out <=  G_t ;
        B_out <=  B_t;
    end behavioral;
    