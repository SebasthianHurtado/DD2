library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_calculadora is
end entity;

architecture test of test_calculadora is
	signal	clk	 		  :  std_logic;
	signal	nRst 		  :  std_logic;
	signal	tecla		  :  std_logic_vector(3 downto 0);
	signal	pres		  :  std_logic_vector(1 downto 0);
	signal	op			  :  std_logic_vector(1 downto 0);
	signal	ena			  :  std_logic;
	signal	op1           :  std_logic_vector(11 downto 0);
    signal	op1_sgn       :  std_logic;
    signal	op2           :  std_logic_vector(11 downto 0);
    signal	op2_sgn       :  std_logic;
    signal	res           :  std_logic_vector(23 downto 0);
    signal	res_sgn       :  std_logic;

	constant Tclk    : time := 20 ns; 

begin

process
  begin
    clk <= '0';
    wait for Tclk/2;
    clk <= '1';
    wait for Tclk/2;
end process;


dut: entity work.Calculadora_interfaz(estructural)
  port map(
    clk	=> clk, 		  
	nRst => nRst,
	tecla => tecla,
	pres => pres,
	op	=> op,		 
	ena	=> ena,		
	op1 => op1,          
    op1_sgn => op1_sgn,    
    op2  => op2,      
    op2_sgn => op2_sgn,      
    res  => res,      
    res_sgn => res_sgn
  );   

process
	begin
		nRst <= '0';
		wait until clk'event and clk = '1';
		nRst <= '1';
		wait until clk'event and clk = '1';
		tecla <= x"1";
		wait until clk'event and clk = '1';
		tecla <= x"2";
		wait until clk'event and clk = '1';
		tecla <= x"3";
		wait until clk'event and clk = '1';
		tecla <= x"2";
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		tecla <= x"E";
		wait until clk'event and clk = '1';
		tecla <= x"C";
		tecla <= x"2";
		wait until clk'event and clk = '1';
		tecla <= x"3";
		wait until clk'event and clk = '1';
		tecla <= x"1";
		wait for Tclk*30;
		assert true
    	report "Fin de la simulación - Éxito"
    	severity error;
end process;
end test;