library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity Resta_Signo is
    port (
        A : in  std_logic_vector(10 downto 0);
        B : in  std_logic_vector(10 downto 0);
        R : out std_logic_vector(21 downto 0)   
    );
end entity Resta_Signo;

architecture rtl of Resta_Signo is
    signal A_ext : std_logic_vector(11 downto 0);
    signal B_ext : std_logic_vector(11 downto 0);
    signal R_ext : std_logic_vector(11 downto 0);
begin

    -- 1. Extensión de signo manual
    A_ext <= A(10) & A;
    B_ext <= B(10) & B;

    -- 2. Resta puramente combinacional (A - B)
    R_ext <= A_ext - B_ext;

    -- 3. Extensor signo
    R(21 downto 12) <= (Others => R_ext(11));
    R(11 downto 0) <= R_ext;
 
end architecture rtl;

