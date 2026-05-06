library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Modulo_Suma_BCD is
port(
     numero_1        : in  std_logic_vector(23 downto 0);
     numero_2        : in  std_logic_vector(23 downto 0); 
     Carry_in        : in  std_logic;
     resultado_final : out std_logic_vector(23 downto 0);
     Carry_out       : out std_logic
);
end entity;

architecture rtl of Modulo_Suma_BCD is
    
    signal suma0, suma1, suma2, suma3, suma4, suma5 : std_logic_vector(4 downto 0);
    signal C0, C1, C2, C3, C4 : std_logic;

begin
    -- MODULO DE SUMA : 6 DIGITOS (Máximo 999.999)
    
    -- DIGITO 0
    suma0 <= ('0' & numero_1(3 downto 0)) + ('0' & numero_2(3 downto 0)) + ("0000" & Carry_in);
    resultado_final(3 downto 0) <= suma0(3 downto 0) + "0110" when suma0 > "01001" else suma0(3 downto 0); 
    C0 <= '1' when suma0 > "01001" else '0'; 

    -- DIGITO 1
    suma1 <= ('0' & numero_1(7 downto 4)) + ('0' & numero_2(7 downto 4)) + ("0000" & C0);
    resultado_final(7 downto 4) <= suma1(3 downto 0) + "0110" when suma1 > "01001" else suma1(3 downto 0); 
    C1 <= '1' when suma1 > "01001" else '0'; 

    -- DIGITO 2
    suma2 <= ('0' & numero_1(11 downto 8)) + ('0' & numero_2(11 downto 8)) + ("0000" & C1);
    resultado_final(11 downto 8) <= suma2(3 downto 0) + "0110" when suma2 > "01001" else suma2(3 downto 0); 
    C2 <= '1' when suma2 > "01001" else '0'; 

    -- DIGITO 3
    suma3 <= ('0' & numero_1(15 downto 12)) + ('0' & numero_2(15 downto 12)) + ("0000" & C2);
    resultado_final(15 downto 12) <= suma3(3 downto 0) + "0110" when suma3 > "01001" else suma3(3 downto 0); 
    C3 <= '1' when suma3 > "01001" else '0'; 

    -- DIGITO 4
    suma4 <= ('0' & numero_1(19 downto 16)) + ('0' & numero_2(19 downto 16)) + ("0000" & C3);
    resultado_final(19 downto 16) <= suma4(3 downto 0) + "0110" when suma4 > "01001" else suma4(3 downto 0); 
    C4 <= '1' when suma4 > "01001" else '0'; 

    -- DIGITO 5
    suma5 <= ('0' & numero_1(23 downto 20)) + ('0' & numero_2(23 downto 20)) + ("0000" & C4);
    resultado_final(23 downto 20) <= suma5(3 downto 0) + "0110" when suma5 > "01001" else suma5(3 downto 0); 
    Carry_out <= '1' when suma5 > "01001" else '0'; 

end rtl;
