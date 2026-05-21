library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Calculadora_interfaz is
port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tecla         : in std_logic_vector(3 downto 0);
    pres          : buffer std_logic_vector(1 downto 0);
    op            : buffer std_logic_vector(1 downto 0);
    ena           : buffer std_logic;
    op1           : buffer std_logic_vector(11 downto 0);
    op1_sgn       : buffer std_logic;
    op2           : buffer std_logic_vector(11 downto 0);
    op2_sgn       : buffer std_logic;
    res           : buffer std_logic_vector(23 downto 0);
    res_sgn       : buffer std_logic
); 
end entity;

architecture estructural of Calculadora_interfaz is
    type t_estado is (operando1, operando2, resultado);
    signal estado : t_estado;
    
    -- Registros internos
    signal registro_actual : std_logic_vector(11 downto 0);
    signal signo_actual    : std_logic;
    signal num_max         : std_logic_vector(2 downto 0);
    
    -- Señales de interconexión
    signal res_bin         : std_logic_vector(21 downto 0);
    signal num_1_Bin       : std_logic_vector(10 downto 0);
    signal num_2_Bin       : std_logic_vector(10 downto 0);
    signal done            : std_logic;
    signal tecla_ant       : std_logic_vector(3 downto 0);

begin
    
    -- ==========================================
    -- Instancias de componentes
    -- ==========================================
    BCD_a_BIN_1: entity work.BCD_BN_Signo(rtl)
    port map(
       signo_in   => op1_sgn,
       unidades   => op1(3 downto 0),
       decenas    => op1(7 downto 4),
       centenas   => op1(11 downto 8),
       resultado  => num_1_Bin
    );

    BCD_a_BIN_2: entity work.BCD_BN_Signo(rtl)
    port map(
       signo_in   => op2_sgn,
       unidades   => op2(3 downto 0),
       decenas    => op2(7 downto 4),
       centenas   => op2(11 downto 8),
       resultado  => num_2_Bin
    );

    Operar: entity work.Operaciones(estructural)
    port map( 
        num_1     => num_1_Bin,
        num_2     => num_2_Bin,
        resultado => res_bin,
        op        => op
    );
    
    BIN_a_BCD: entity work.Bin_BCD(rtl)
    port map(
       clk      => clk,
       nRst     => nRst,
       ena      => ena,
       bin_in   => res_bin,
       bcd_out  => res,
       sign_out => res_sgn,
       done     => done
    );

    process_control: process(clk, nRst)
    begin
        if nRst = '0' then
            estado          <= operando1;
            op1             <= (others => '0');
            op1_sgn         <= '0';
            op2             <= (others => '0');
            op2_sgn         <= '0';
            op              <= "00";
            ena             <= '0';
            pres            <= "00";
            registro_actual <= (others => '0');
            signo_actual    <= '0';
            num_max         <= (others => '0');
            tecla_ant       <= X"F"; -- X"F" representa el estado de reposo del teclado
            
        elsif clk'event and clk = '1' then
            tecla_ant <= tecla;
            
            case estado is
                -- ----------------------------------------------------
                -- ESTADO: OPERANDO 1
                -- ----------------------------------------------------
                when operando1 =>
                    pres <= "00";
                    ena  <= '0';
                    
                    if tecla /= tecla_ant and tecla /= X"F" then
                        if tecla <= X"9" then
                            -- ESP10: Ignorar si el primer dígito introducido es un 0
                            if num_max = "000" and tecla = X"0" then
                                null; 
                            elsif num_max < 3 then
                                registro_actual <= registro_actual(7 downto 0) & tecla;
                                num_max <= num_max + 1;
                            end if;
                            
                        elsif tecla = X"C" then
                            signo_actual <= not signo_actual;
                            
                        elsif tecla = X"A" or tecla = X"D" or tecla = X"E" then
                            if    tecla = X"A" then op <= "01";
                            elsif tecla = X"D" then op <= "10";
                            elsif tecla = X"E" then op <= "11";
                            end if;
                            
                            op1     <= registro_actual;
                            op1_sgn <= signo_actual;
                            
                            registro_actual <= (others => '0');
                            signo_actual    <= '0';
                            num_max         <= (others => '0');
                            
                            estado <= operando2;
                        end if;
                    end if;

                -- ----------------------------------------------------
                -- ESTADO: OPERANDO 2
                -- ----------------------------------------------------
                when operando2 =>
                    pres <= "01";
                    ena  <= '0'; 
                    
                    if tecla /= tecla_ant and tecla /= X"F" then
                        if tecla <= X"9" then
                            -- ESP10: Ignorar si el primer dígito introducido es un 0
                            if num_max = "000" and tecla = X"0" then
                                null;
                            elsif num_max < 3 then
                                registro_actual <= registro_actual(7 downto 0) & tecla;
                                num_max <= num_max + 1;
                            end if;
                            
                        elsif tecla = X"C" then
                            signo_actual <= not signo_actual;
                            
                        -- Tecla Igual (B)
                        elsif tecla = X"B" then
                            op2     <= registro_actual;
                            op2_sgn <= signo_actual;
                            
                            -- Iniciamos la conversión con un pulso en alto durante la transición
                            ena     <= '1'; 
                            
                            estado <= resultado;
                        end if;
                    end if;

                -- ----------------------------------------------------
                -- ESTADO: RESULTADO
                -- ----------------------------------------------------
                when resultado =>
                    pres <= "10";
                    
                    -- Bajamos el enable inmediatamente, consolidando el pulso de 1 ciclo
                    ena  <= '0'; 
                    
                    -- ESP13: Cualquier tecla sale del modo de presentación
                    if tecla /= tecla_ant and tecla /= X"F" then
                        
                        op1             <= (others => '0');
                        op1_sgn         <= '0';
                        op2             <= (others => '0');
                        op2_sgn         <= '0';
                        op              <= "00";
                        
                        if tecla <= X"9" then
                            registro_actual <= X"00" & tecla;
                            signo_actual    <= '0';
                            num_max         <= "001";
                        else
                            registro_actual <= (others => '0');
                            signo_actual    <= '0';
                            num_max         <= (others => '0');
                        end if;
                        
                        estado <= operando1;
                    end if;

                when others =>
                    estado <= operando1;
            end case;
        end if;
    end process;

end estructural;
