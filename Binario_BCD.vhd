library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BIN_a_BCD_21Bits_6D is
port(
    bin_in     : in  std_logic_vector(20 downto 0);
    signo      : out std_logic;
    unidades   : out std_logic_vector(3 downto 0);
    decenas    : out std_logic_vector(3 downto 0);
    centenas   : out std_logic_vector(3 downto 0);
    millares   : out std_logic_vector(3 downto 0);
    d_millares : out std_logic_vector(3 downto 0);
    c_millares : out std_logic_vector(3 downto 0)
);
end entity BIN_a_BCD_21Bits_6D;

architecture rtl of BIN_a_BCD_21Bits_6D is

   
    type t_bcd_array is array (0 to 21) of std_logic_vector(23 downto 0);
    signal bcd_arr : t_bcd_array;

    type t_bin_array is array (0 to 21) of std_logic_vector(20 downto 0);
    signal bin_arr : t_bin_array;


    signal abs_bin : std_logic_vector(20 downto 0);

begin

    -- Gestión concurrente del signo y valor absoluto (C2)
    signo   <= bin_in(20);
    abs_bin <= (not bin_in) + 1 when bin_in(20) = '1' else bin_in;

    bcd_arr(0) <= (others => '0');
    bin_arr(0) <= abs_bin;

    -- 3. Algoritmo Double Dabble desenrollado con bloque Generate
    gen_dabble: for i in 0 to 20 generate
        -- Señal temporal exclusiva para la suma concurrente de esta etapa
        signal bcd_add3 : std_logic_vector(23 downto 0);
    begin

        -- Condición "Add 3" evaluada con sentencias concurrentes when/else
        bcd_add3(3 downto 0)   <= bcd_arr(i)(3 downto 0)   + "0011" when bcd_arr(i)(3 downto 0)   > "0100" else bcd_arr(i)(3 downto 0);
        bcd_add3(7 downto 4)   <= bcd_arr(i)(7 downto 4)   + "0011" when bcd_arr(i)(7 downto 4)   > "0100" else bcd_arr(i)(7 downto 4);
        bcd_add3(11 downto 8)  <= bcd_arr(i)(11 downto 8)  + "0011" when bcd_arr(i)(11 downto 8)  > "0100" else bcd_arr(i)(11 downto 8);
        bcd_add3(15 downto 12) <= bcd_arr(i)(15 downto 12) + "0011" when bcd_arr(i)(15 downto 12) > "0100" else bcd_arr(i)(15 downto 12);
        bcd_add3(19 downto 16) <= bcd_arr(i)(19 downto 16) + "0011" when bcd_arr(i)(19 downto 16) > "0100" else bcd_arr(i)(19 downto 16);
        bcd_add3(23 downto 20) <= bcd_arr(i)(23 downto 20) + "0011" when bcd_arr(i)(23 downto 20) > "0100" else bcd_arr(i)(23 downto 20);

        -- Condición "Shift": El resultado se asigna a la SIGUIENTE posición del array (i+1)
        bcd_arr(i+1) <= bcd_add3(22 downto 0) & bin_arr(i)(20);
        bin_arr(i+1) <= bin_arr(i)(19 downto 0) & '0';

    end generate;

    
    unidades   <= bcd_arr(21)(3 downto 0);
    decenas    <= bcd_arr(21)(7 downto 4);
    centenas   <= bcd_arr(21)(11 downto 8);
    millares   <= bcd_arr(21)(15 downto 12);
    d_millares <= bcd_arr(21)(19 downto 16);
    c_millares <= bcd_arr(21)(23 downto 20);

end architecture rtl;
