
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_tec is port(
  clk: in std_logic;
  nRst: in std_logic;
  tic: in std_logic;
  columna: in std_logic_vector(3 downto 0);
  tecla_pulsada: buffer std_logic;
  pulso_largo: buffer std_logic;
  tecla: buffer std_logic_vector(3 downto 0);
  fila: buffer std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of ctrl_tec is
  signal pulso: std_logic;
  signal contador_2s: std_logic_vector(8 downto 0);
  signal contador_ena: std_logic;
  signal tic_2s: std_logic;
  type t_estado is (muestreo, contador);
  signal estado: t_estado;
  signal tecla_selec: std_logic_vector(7 downto 0);
  constant MODULO : natural := 14; --400
begin

  --Control
  process(clk, nRst)
  begin
    if nRst = '0' then
        tecla <= X"0";
        fila <= X"0";
        estado <= muestreo;

    elsif clk'event and clk='1' then
    case estado is
        when muestreo =>


        if tic = '1' and pulso = '0' then
                if fila = X"7" then
                 fila <= X"E";

                else
               fila <= fila(2 downto 0)&'1';

                end if;

            elsif tic = '1' and pulso = '1' then
               estado <= contador;

            end if;
        when contador =>
        if pulso = '0' and tic_2s = '0' then

            estado <= muestreo;

        elsif pulso = '0' then
            estado <= muestreo;

        else
            case tecla_selec is               --Cuando se detecta un pulso se mira que tecla se ha pulsado
                when X"EE" => tecla <= X"1";
                when X"ED" => tecla <= X"4";
                when X"EB" => tecla <= X"7";
                when X"E7" => tecla <= X"A";
                when X"DE" => tecla <= X"2";
                when X"DD" => tecla <= X"5";
                when X"DB" => tecla <= X"8";
                when X"D7" => tecla <= X"0";
                when X"BE" => tecla <= X"3";
                when X"BD" => tecla <= X"6";
                when X"BB" => tecla <= X"9";
                when X"B7" => tecla <= X"B";
                when X"7E" => tecla <= X"F";
                when X"7D" => tecla <= X"E";
                when X"7B" => tecla <= X"D";
                when X"77" => tecla <= X"C";
                when others =>
             end case;

        end if;
        when others =>
    end case;
    end if;
  end process;

  tecla_pulsada <= '1' when pulso = '0' and tic_2s = '0' and estado = contador else   --La pulsación de la tecla ha durado menos de 2 segundo -> pulsación corta
                  '0';

  pulso_largo <= '1' when tic_2s = '1' and estado = contador else   -- La tecla ha durado 2 segundos -> pulsación larga
                 '0';

  tecla_selec <= columna&fila when pulso = '1' else   --Para facilitar la comprobación de la tecla pulsada
                 X"00";

  pulso <= '1' when columna /= 15 else
       '0';

  contador_ena <= '1' when pulso = '1' else
                  '0';

  --Contador 2 segundos
  process(contador_ena, tic)    -- contador_ena actúa como reset asíncrono del contador
  begin
    if contador_ena = '0' then
        contador_2s <= (others => '0');

    elsif tic'event and tic = '1' then
        if contador_2s < MODULO and tic_2s = '0' then
            contador_2s <= contador_2s + 1;
        end if;

    end if;
  end process;

  tic_2s <= '0' when contador_2s < MODULO else
        '1';
end rtl;