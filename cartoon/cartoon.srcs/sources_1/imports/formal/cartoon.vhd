library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity cartoon is
    port(
        clk: in std_logic;
        enable: in std_logic;
        display_x, display_y: in std_logic_vector(10 downto 0);
        pixel_in: in std_logic_vector(4 downto 0);
        pixel_out: out std_logic_vector(7 downto 0)
    );
end cartoon;


architecture behavioral of cartoon is
    component sr5 is
        port(
            clk: in std_logic;
            in1: in std_logic_vector(4 downto 0);
            enable: in std_logic;
            q0, q1, q2, q3, q4: out std_logic_vector(4 downto 0)
        );
    end component;

    component fifo_counter is
        port(
            clk: in std_logic;
            display_x, display_y: in std_logic_vector(10 downto 0);
            wr_en, rd_en: out std_logic
        );
    end component;

    component fifo
        port (
            clk: in std_logic;
            din: in std_logic_vector(4 downto 0);
            wr_en: in std_logic;
            rd_en: in std_logic;
            dout: out std_logic_vector(4 downto 0);
            full: out std_logic;
            empty: out std_logic
        );
    end component;

    signal q00, q01, q02, q03, q04: std_logic_vector(4 downto 0) :="00000";
    signal q10, q11, q12, q13, q14: std_logic_vector(4 downto 0) :="00000";
    signal q20, q21, q22, q23, q24: std_logic_vector(4 downto 0) :="00000";
    signal q30, q31, q32, q33, q34: std_logic_vector(4 downto 0) :="00000";
    signal q40, q41, q42, q43, q44: std_logic_vector(4 downto 0) :="00000";
    signal wr_en0, rd_en0, wr_en1, rd_en1, wr_en2, rd_en2, wr_en3, rd_en3: std_logic := '0';
    signal out_1, out_2, out_3, out_4: std_logic_vector(4 downto 0) := "00000";
    signal full_0, empty_0, full_1, empty_1, full_2, empty_2, full_3, empty_3: std_logic := '0';
    signal tempin: std_logic_vector(4 downto 0) := "00000";
    signal quantify, mult, filter, temp: integer := 0;
    signal y: std_logic_vector(7 downto 0) := "00000000";
    constant compare: integer := 2037;
    constant pow: integer := 2048;

    begin
        fifo0: fifo port map(clk, q04, wr_en0, rd_en0, out_1, full_0, empty_0);
        fifo1: fifo port map(clk, q14, wr_en1, rd_en1, out_2, full_1, empty_1);
        fifo2: fifo port map(clk, q24, wr_en2, rd_en2, out_3, full_2, empty_2);
        fifo3: fifo port map(clk, q34, wr_en3, rd_en3, out_4, full_3, empty_3);
        tempin <= pixel_in;
        sr0: sr5 port map(clk, tempin, enable, q00, q01, q02, q03, q04);
        sr1: sr5 port map(clk, out_1, enable, q10, q11, q12, q13, q14);
        sr2: sr5 port map(clk, out_2, enable, q20, q21, q22, q23, q24);
        sr3: sr5 port map(clk, out_3, enable, q30, q31, q32, q33, q34);
        sr4: sr5 port map(clk, out_4, enable, q40, q41, q42, q43, q44);

        counter0: fifo_counter port map(clk, display_x, display_y, wr_en0, rd_en0);
        counter1: fifo_counter port map(clk, display_x, display_y, wr_en1, rd_en1);
        counter2: fifo_counter port map(clk, display_x, display_y, wr_en2, rd_en2);
        counter3: fifo_counter port map(clk, display_x, display_y, wr_en3, rd_en3);

        filter <= (conv_integer(q00) + conv_integer(q01) + conv_integer(q02) + conv_integer(q03) + conv_integer(q04) + conv_integer(q10) + conv_integer(q11) + conv_integer(q12) + conv_integer(q13) + conv_integer(q14) + conv_integer(q20) + conv_integer(q21) + conv_integer(q22) + conv_integer(q23) + conv_integer(q24) + conv_integer(q30) + conv_integer(q31) + conv_integer(q32) + conv_integer(q33) + conv_integer(q34) + conv_integer(q40) + conv_integer(q41) + conv_integer(q42) + conv_integer(q43) + conv_integer(q44)) / 32;
        quantify <= conv_integer(q22) * pow / filter;
        mult <= (quantify - compare) when quantify>compare else
                0;
        y <= conv_std_logic_vector(conv_integer(q22) * mult / 32, 8) when quantify < 2150 else
             q22&q22(2 downto 0);
        pixel_out <= y;
    end behavioral;