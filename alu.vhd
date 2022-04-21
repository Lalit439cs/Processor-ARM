-- ALU module 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.MyTypes.all;
-- entity
entity alu_comb is
port(
  a: in word ;
  b: in word;
  opc:in optype;
  cin:in std_logic;
  r: out word;
  cout:out std_logic);
end entity;
--  architecture
architecture alu_behv of alu_comb is

begin
  process(a, b,opc,cin) is
  variable at,bt:word;
  variable ct:std_logic;
  variable rt:std_logic_vector (32 downto 0);
  begin
  	cout<='Z';
  	case opc is
      when andop => --andop,"0000"
        r<= a and b;
      when eor => --eor "0001"
        r <= a xor b;
      when orr => --orr,"1100"
        r <= a or b;
      when tst => --tst "1000"
        r <= a and b;
      when teq => --teq "1001"
        r <= a xor b;
      when mov  => --mov "1101"
        r <= b;
      when mvn => --mvn "1111"
        r <= not b;
      when bic => --bic "1110"
        r <= a and not b;
      when others =>
      --r <= std_logic_vector(signed(a) + Signed(b));
      
      	if (opc=add or opc=cmn) then --opc="0100" or opc="1011"
            at:=a;
        	bt:=b;
            ct:='0';
        elsif (opc=sub or opc=cmp) then --opc="0010" or opc="1010"
            at:=a;
            ct:='1';
            bt:= not b;
        elsif opc=rsb then --rsb "0011"
            ct:='1';
            at:= not a;
            bt:=b;
        elsif opc=rsc then --opc=rsc "0111"
        	at:= not a;
            bt:=b;
          	ct:=cin;
       	elsif opc=sbc then --opc=sbc "0110"
            bt:=not b;
            at:=  a;
          	ct:=cin;
        else--initialized with adc operand values
          at:=a;
          bt:=b;
          ct:=cin;
        	
        end if;
        
        rt := std_logic_vector(signed('0' & at)+signed('0' & bt ) + ct);--std_logic_vector typecast
        r<=rt(31 downto 0);
        cout<= rt(32);
        
    end case;
  end process;
end alu_behv;
