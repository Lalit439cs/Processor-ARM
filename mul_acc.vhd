-- MUL-ACCUMULATE module 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.MyTypes.all;
-- entity
entity mulacc is
port(
  a: in word ;
  b: in word;
  c: in std_logic_vector (63 downto 0);--word
  mopc:in std_logic_vector (2 downto 0);
  r: out std_logic_vector (63 downto 0));
--   cout:out std_logic);
end entity;
--  architecture
architecture mulacc_behv of mulacc is
signal ma,s: std_logic;
begin
 ma <= mopc(0);
 s <= mopc(1);
  process(a, b,c,ma,s) is
  variable at,bt:std_logic_vector (32 downto 0);
--   variable cs:signed (31 downto 0);
  variable x1,x2:std_logic;
--   variable ct:signed (63 downto 0);
  variable rt:signed (65 downto 0);
  begin
    if (s = '1') then 
        x1:= a(31); 
        x2:= b(31);
        -- cs := (others => c(31));
    else 
        x1:= '0' ;
        x2:= '0' ; 
        -- cs:= (others => '0');
    end if;
    at:= x1 & a;
    bt:= x2 & b;
    rt:= signed(at) * signed (bt);
  	if (ma = '0') then r <= std_logic_vector (rt( 63 downto 0)); else  
        -- ct(63 downto 32) := cs;
        -- ct(31 downto 0) := c;
        r <= std_logic_vector (rt( 63 downto 0) + signed(c)) ;
    end if;

    
  end process;
end mulacc_behv;
