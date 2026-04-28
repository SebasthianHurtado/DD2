library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

entity test_operar is
end entity;

architecture test of test_operar is
  signal clk:         std_logic;
  signal nRst:        std_logic;
  signal A : std_logic_vector(10 downto 0);
  signal B : std_logic_vector(10 downto 0);
  signal resultado : std_logic_vector(21 downto 0);
  signal op : std_logic_vector(2 downto 0);

  constant Tclk:       time := 20 ns; 
begin

process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;


dut: entity work.Operaciones(estructural)
port map(
     op => op,
     num_1 => A,
     num_2 => B,
     resultado => resultado
    );          



process
  begin
    wait until clk'event and clk = '1';
    A <= (Others => '0');
    B <= (Others => '0');
    op <= (Others => '0');
    wait until clk'event and clk = '1';
    --Prueba positivos
    A <= "00000001010";
    B <= "00000001010";
    wait until clk'event and clk = '1';
    op <= "001";
    wait until clk'event and clk = '1';
    op <= "010";
    wait until clk'event and clk = '1';
    op <= "100";
    wait until clk'event and clk = '1';
    op <= "000";
    wait until clk'event and clk = '1';

    --Prueba negativos
    A <= "11111110110";
    B <= "11111110110";
    wait until clk'event and clk = '1';
    op <= "001";
    wait until clk'event and clk = '1';
    op <= "010";
    wait until clk'event and clk = '1';
    op <= "100";
    wait until clk'event and clk = '1';
    op <= "000";
    wait until clk'event and clk = '1';

    --Prueba positivos y negativos
    A <= "11111110110";
    B <= "00000001010";
    wait until clk'event and clk = '1';
    op <= "001";
    wait until clk'event and clk = '1';
    op <= "010";
    wait until clk'event and clk = '1';
    op <= "100";
    wait until clk'event and clk = '1';
    op <= "000";
    wait until clk'event and clk = '1';

    assert false
    report "fin simulacion"
    severity error;
end process;
end test;
