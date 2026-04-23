
library ieee;                    
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity BN_BCD is             
port(
     	   unidades:    in     std_logic_vector(3 downto 0);
           decenas:     in     std_logic_vector(3 downto 0);
	   centenas:    in     std_logic_vector(3 downto 0);
	   num_bn_div8: buffer std_logic_vector(6 downto 0)
    );
end entity; 

architecture rtl of BCD_BN is
  signal S1_aux: std_logic_vector(6 downto 0);
  signal S2_aux: std_logic_vector(9 downto 0);
begin
    -- S1_aux <= 10*centenas + decenas
    S1_aux <= (centenas & "000") + (centenas &  '0') + decenas;

    -- S2_aux <= 10*(10 centenas + decenas) + unidades
    S2_aux <= (S1_aux & "000") + (S1_aux &  '0') + unidades;

    -- num_bn_div8 <= (100*centenas + 10*decenas + unidades)/8   
    num_bn_div8 <= S2_aux(9 downto 3);

end rtl;