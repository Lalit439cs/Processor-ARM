-- PMconnect module 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.MyTypes.all;
-- entity
entity PMconnect is
port(
  minstr: in minstr_type ;
  rout: in word;
  mout: in word;
  cstate:in ctrl_state;--use ?
  adr:in std_logic_vector (1 downto 0);
  minn: out word;
  rin : out word;
  mw : out std_logic_vector (3 downto 0));
end entity;
--  architecture
architecture pm_behv of PMconnect is

begin
  process(minstr,cstate,adr,mout,rout) is
  variable a,b,c,d : std_logic_vector (7 downto 0);
  begin
    mw <= "0000";
    if (cstate = MLDR or cstate = MSTR ) then
    a := (others => mout(7)) ;
    b := (others => mout(15)) ;
    c := (others => mout(23)) ; 
    d := (others => mout(31)) ;
  	case minstr is
      when STR => --STR,"000"
        minn (31 downto 24) <= rout (31 downto 24);
        minn (23 downto 16) <= rout (23 downto 16);
        minn (15 downto 8) <= rout (15 downto 8);
        minn (7 downto 0) <= rout (7 downto 0);
        mw <= "1111";
      when STRH => --STRH "001"
        minn (31 downto 24) <= rout (15 downto 8);
        minn (23 downto 16) <= rout (7 downto 0);
        minn (15 downto 8) <= rout (15 downto 8);
        minn (7 downto 0) <= rout (7 downto 0);
        if (adr = "00") then mw <= "0011";
        else mw <= "1100"; end if;
        
      when STRB => --STRB,"010"
        minn (31 downto 24) <= rout (7 downto 0);
        minn (23 downto 16) <= rout (7 downto 0);
        minn (15 downto 8) <= rout (7 downto 0);
        minn (7 downto 0) <= rout (7 downto 0);
        case adr is 
        when "00" => mw <= "0001";
        when "01" => mw <= "0010";
        when "10" => mw <= "0100";
        when "11" => mw <= "1000";
        when others => null;
        end case;
      when LDR => --LDR "011"
        rin (31 downto 24) <= mout (31 downto 24);
        rin (23 downto 16) <= mout (23 downto 16);
        rin (15 downto 8) <= mout (15 downto 8);
        rin (7 downto 0) <= mout (7 downto 0);
      when LDRH => --LDRH "100"
        rin (31 downto 24) <= "00000000";
        rin (23 downto 16) <= "00000000";
        
        if (adr = "00") then rin (15 downto 8) <= mout (15 downto 8);
        rin (7 downto 0) <= mout (7 downto 0);
        else rin (15 downto 8) <= mout (31 downto 24);
        rin (7 downto 0) <= mout (23 downto 16); end if;

      when LDRSH  => --LDRSH "101"
        if (adr = "00") then
        rin (31 downto 24) <= b;
        rin (23 downto 16) <= b ;
        rin (15 downto 8) <= mout (15 downto 8);
        rin (7 downto 0) <= mout (7 downto 0);

        else 
        rin (31 downto 24) <= d;
        rin (23 downto 16) <= d ;
        rin (15 downto 8) <= mout (31 downto 24);
        rin (7 downto 0) <= mout (23 downto 16); 
        end if;
      when LDRB => --LDRB "110"
        rin (31 downto 24) <="00000000";
        rin (23 downto 16) <="00000000";
        rin (15 downto 8) <= "00000000";
        case adr is 
        when "00" => rin (7 downto 0) <= mout (7 downto 0);
        when "01" => rin (7 downto 0) <= mout (15 downto 8);
        when "10" => rin (7 downto 0) <= mout (23 downto 16);
        when "11" => rin (7 downto 0) <= mout (31 downto 24);
        when others => null;
        end case;
      when LDRSB => --LDRSB "111"
      case adr is 
      when "00" =>
        rin (31 downto 24) <=a;
        rin (23 downto 16) <= a;
        rin (15 downto 8) <= a;
        rin (7 downto 0) <= mout (7 downto 0);
      when "01" => 
      rin (31 downto 24) <=b;
      rin (23 downto 16) <= b;
      rin (15 downto 8) <= b;
      rin (7 downto 0) <= mout (15 downto 8);
      when "10" => 
      rin (31 downto 24) <=c;
        rin (23 downto 16) <= c;
        rin (15 downto 8) <= c;
        rin (7 downto 0) <= mout (23 downto 16);
      when "11" => 
      rin (31 downto 24) <=d;
        rin (23 downto 16) <= d;
        rin (15 downto 8) <= d;
        rin (7 downto 0) <= mout (31 downto 24);
      when others => null;
      end case;
      when others => 
      rin <= mout; minn <= rout;

    end case;
    end if;
  end process;
end pm_behv;
