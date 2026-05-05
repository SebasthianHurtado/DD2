library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity Bin_BCD is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     bin_in: 		in	   std_logic_vector(21 downto 0); -- ENTRADA MAXIMA, 998001
     bcd_out: 		out    std_logic_vector(23 downto 0); --SALIDA MAXIMA, 6 DIGITOS
     bcd_sign: 		buffer	std_logic
    );
end entity;

architecture rtl of Bin_BCD is
  signal P9,P8,P7,P6,P5,P4,P3,P2,P1,P0 : std_logic_vector(23 downto 0);
  signal P19,P18,P17,P16,P15,P14,P13,P12,P11,P10 : std_logic_vector(23 downto 0);
  -- registros 
  signal reg_desp : std_logic_vector(21 downto 0);
  signal reg_BCD : std_logic_vector(23 downto 0);
  signal contador : std_logic_vector(4 downto 0);
  
   -- modulo sumador BCD 
  signal next_BCD : std_logic_vector(23 downto 0);
  signal bit_actual : std_logic;
  signal Carry_out : std_logic; -- Ultimo acarreo que no sirve
  signal Modulo : std_logic_vector(21 downto 0);


begin


  -- MODULO BINARIO ENTRADA + Extraer signo
    bcd_sign <= bin_in(21); 

    Modulo <= (not bin_in) + 1 when bcd_sign = '1' else 
                         bin_in;


    bit_actual <= reg_desp(19);
 
  -- MODULO SUMADOR BCD 
    U_MODULO_SUMA_BCD_6_DIGITOS: entity work.Modulo_Suma_BCD(rtl)
      port map(numero_1                  =>  reg_BCD,
               numero_2                 => reg_BCD,
               Carry_in               => bit_actual,
			   resultado_final    => next_BCD,
               Carry_out         => Carry_out);


  -- Proceso secuancial, acumulacion.
  process(clk, nRst)
    begin 
	 if nRst='1' then
		reg_desp <= (others => '0');
		reg_BCD <= (others => '0');
		bcd_out <= (others => '0');
		contador <= (others => '0');
	 elsif clk'event and clk = '1' then
	  if contador = 0 then 
		bcd_out <= reg_BCD;
		reg_desp <= Modulo;
		reg_BCD <= (others => '0');
		contador <= "10011";
	   else 
	    reg_BCD <= next_BCD;
		reg_desp <= reg_desp(20 downto 0 ) & '0';
		contador <= contador -1 ;
	   end if;
	   
	 end if;
	 end process;

 


end rtl;

