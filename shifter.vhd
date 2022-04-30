-- SHIFTER module 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- for synthesis safe ,can use shift_left(), shift_right(), rotate_left(), and rotate_right() functions instead
library work;
use work.MyTypes.all;
--corner cases,rules more careful
-- entity
entity SHIFTER is
port(
  s_in: in word ;
  --"00" for LSL, "01" for LSR, "10" for ASR and "11" for ROR
  typ:in std_logic_vector (1 downto 0);
  val: in std_logic_vector (4 downto 0);--deal overflow amount ?-outside...read
  s_out: out word;
  cout:out std_logic);
end entity;
--  architecture
architecture sbehv of SHIFTER is

begin-- for carry at last if-else only can be put to find value acc to type-R,L(32-n)
  process(s_in,typ,val) is
  variable s0,s1,s2,s3,s4 : std_logic_vector (31 downto 0);
  variable c0,c1,c2,c3,c4: std_logic;
  begin
    --5 stages --each can be a component
    if (val(0)='1') then
    c0 := s_in(0);
  	case typ is
      when "00" => --LSL,"00"
        s0 := s_in sll 1;
        c0 := s_in(31);
      when "01" => --LSR "01"
      s0 := s_in srl 1;
      when "10" => --ASR,"10"
      s0 := std_logic_vector(shift_right(signed(s_in), 1));
      when "11" => --ROR "11"
      s0 := s_in ror 1;
      when others => null;
    end case;
    else
        s0 := s_in;
        c0 :='0' ;
    end if;

    if (val(1)='1') then
        c1:=s0(1);
        case typ is
        when "00" => --LSL,"00"
          s1 := s0 sll 2;
          c1:=s0(30);
        when "01" => --LSR "01"
        s1:= s0 srl 2;
        when "10" => --ASR,"10"
        s1 := std_logic_vector(shift_right(signed(s0), 2));
        when "11" => --ROR "11"
        s1 := s0 ror 2;
        when others => null;
      end case;
      else
          s1 := s0;
          c1:= c0 ;
      end if;
    
    if (val(2)='1') then
        c2:=s1(3);
    case typ is
    when "00" => --LSL,"00"
        s2 := s1 sll 4;
        c2:=s1(28);
    when "01" => --LSR "01"
    s2 := s1 srl 4;
    when "10" => --ASR,"10"
    s2 := std_logic_vector(shift_right(signed(s1), 4));
    when "11" => --ROR "11"
    s2:= s1 ror 4;
    when others => null;
    end case;
    else
        s2 := s1;
        c2:= c1;
    end if;

    if (val(3)='1') then
        c3:=s2(7);
    case typ is
    when "00" => --LSL,"00"
        s3 := s2 sll 8;
        c3:=s2(24);
    when "01" => --LSR "01"
    s3 := s2 srl 8;
    when "10" => --ASR,"10"
    s3 := std_logic_vector(shift_right(signed(s2), 8));
    when "11" => --ROR "11"
    s3 := s2 ror 8;
    when others => null;
    end case;
    else
        s3 := s2;
        c3:= c2;
    end if;

    if (val(4)='1') then
        c4:=s3(15);
    case typ is
    when "00" => --LSL,"00"
        s4 := s3 sll 16;
        c4:=s3(16);
    when "01" => --LSR "01"
    s4 := s3 srl 16;
    when "10" => --ASR,"10"
    s4 := std_logic_vector(shift_right(signed(s3), 16));
    when "11" => --ROR "11"
    s4 := s3 ror 16;
    when others => null;
    end case;
    else
        s4 := s3;
        c4:= c3;
    end if;

    --result
    s_out  <= s4;
    cout <= c4;
  end process;
end sbehv;
