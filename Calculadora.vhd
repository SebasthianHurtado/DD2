library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Calculadora_interfaz is
port(
	clk	 		  : in std_logic;
	nRst 		  : in std_logic;
	tecla		  : in std_logic_vector(3 downto 0);
	pres		  : buffer std_logic_vector(1 downto 0);
	op			  : out std_logic_vector(2 downto 0);
	ena			  : out std_logic;
	op1           : out std_logic_vector(11 downto 0);
    op1_sgn       : out std_logic;
    op2           : out std_logic_vector(11 downto 0);
    op2_sgn       : out std_logic;
    res           : out std_logic_vector(23 downto 0);
    res_sgn       : out std_logic;
     ); 
end entity;

architecture estructural of Calculadora_interfaz is
  type t_estado is (operando1, operando2, resultado);
  signal estado: t_estado;
  signal registro_actual : std_logic_vector(11 downto 0);
  signal signo_actual    : std_logic;

begin

	process_estado: process(clk, nRst)
	if nRrst = '0' then
		estado <= operando1;
	elsif clk'event and clk = '1' then
		case estado is
			when operando1 =>
			op1 <= registro_actual;
			op1_sign <= signo_actual;
			pres <= 0;

			when operando2 =>
			op2 <= registro_actual;
			op2_sign <= signo_actual;
			pres <= 1;

			when resultado =>
			pres <= 2;


	end process;


end estructural;
