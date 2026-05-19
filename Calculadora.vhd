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
    signal num_max         : std_logic_vector(2 downto 0); -- Ampliado a 3 bits para contar de 0 a 3 con seguridad
    
    -- Señales de interconexión
    signal res_bin         : std_logic_vector(21 downto 0);
    signal num_1_Bin       : std_logic_vector(10 downto 0);
    signal num_2_Bin       : std_logic_vector(10 downto 0);
    signal done            : std_logic;

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

    -- ==========================================
    -- Máquina de Estados y Control de Registros
    -- ==========================================
    -- Un único proceso síncrono evita múltiples drivers y latches
    process_control: process(clk, nRst)
    begin
        if nRst = '0' then
            -- Reset general asíncrono
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
            
        elsif clk'event and clk = '1' then
            -- Por defecto, 'ena' es un pulso que dura solo 1 ciclo
            ena <= '0'; 

            case estado is
                -- ----------------------------------------------------
                -- ESTADO: OPERANDO 1
                -- ----------------------------------------------------
                when operando1 =>
                    pres <= "00";
                    
                    -- Entrada de números (0 al 9)
                    if tecla <= X"9" then
                        -- Permitimos hasta 3 dígitos (0, 1, 2)
                        if num_max < 3 then
                            -- Desplazamiento correcto del registro a la izquierda
                            registro_actual <= registro_actual(7 downto 0) & tecla;
                            num_max <= num_max + 1;
                        end if;
                        
                    -- Cambio de signo (Tecla C)
                    elsif tecla = X"C" then
                        signo_actual <= not signo_actual;
                        
                    -- Teclas de Operación (A, D, E)
                    elsif tecla = X"A" or tecla = X"D" or tecla = X"E" then
                        -- Guardamos la operación
                        if    tecla = X"A" then op <= "01";
                        elsif tecla = X"D" then op <= "10";
                        elsif tecla = X"E" then op <= "11";
                        end if;
                        
                        -- Transferimos el registro a op1
                        op1     <= registro_actual;
                        op1_sgn <= signo_actual;
                        
                        -- Limpiamos el registro para el siguiente operando
                        registro_actual <= (others => '0');
                        signo_actual    <= '0';
                        num_max         <= (others => '0');
                        
                        -- Avanzamos de estado
                        estado <= operando2;
                    end if;

                -- ----------------------------------------------------
                -- ESTADO: OPERANDO 2
                -- ----------------------------------------------------
                when operando2 =>
                    pres <= "01";
                    
                    -- Entrada de números (0 al 9)
                    if tecla <= X"9" then
                        if num_max < 3 then
                            registro_actual <= registro_actual(7 downto 0) & tecla;
                            num_max <= num_max + 1;
                        end if;
                        
                    -- Cambio de signo (Tecla C)
                    elsif tecla = X"C" then
                        signo_actual <= not signo_actual;
                        
                    -- Tecla Igual (B)
                    elsif tecla = X"B" then
                        -- Transferimos a op2
                        op2     <= registro_actual;
                        op2_sgn <= signo_actual;
                        
                        -- Disparamos el cálculo
                        ena    <= '1'; 
                        estado <= resultado;
                    end if;

                -- ----------------------------------------------------
                -- ESTADO: RESULTADO
                -- ----------------------------------------------------
                when resultado =>
                    pres <= "10";
                    
                    -- Si se pulsa un nuevo número o la tecla C, reiniciamos la calculadora
                    if tecla <= X"9" or tecla = X"C" then
                        op1             <= (others => '0');
                        op1_sgn         <= '0';
                        op2             <= (others => '0');
                        op2_sgn         <= '0';
                        op              <= "00";
                        
                        -- Si pulsó un número, lo guardamos como el primer dígito del nuevo op1
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
