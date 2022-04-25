library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.MyTypes.all;

-- entity
entity flag is
port(
    instr_class : in instr_class_type;
    opc:in optype;
    DP_subclass : IN DP_subclass_type;
    s,shiftr:in std_logic;
    c_alu,c_shiftr,CLK:in std_logic;
    a,b:in std_logic;--msb bits
    result: in word;
    cvzn:out nibble);
end entity;

--  architecture
architecture fbehv of flag is
signal flags:nibble := "0000";--initially
begin
cvzn<=flags;
PROCESS(CLK)
-- variable r:integer;
variable at,bt,ct,c:std_logic;
begin
    if (rising_edge(CLK) AND (s='1' AND ( instr_class = DP or instr_class = MUL) )) then
    flags(0)<=result(31);--N
    flags(1)<= '1' when result = X"00000000" else '0';--Z
    -- c and V
    CASE DP_subclass IS
    WHEN logic | test =>if (shiftr = '1') then
        c:= c_shiftr;
        end if;
    --comp , arith
    WHEN others =>c:= c_alu;
        if ((opc=add or opc =adc)or opc=cmn) then --opc="0100" or opc="1011"
            at:=a;
            bt:=b;   
        elsif (opc=rsc or opc = rsb) then --opc="0111" or opc="0011"
            at:= not a;
            bt:=b;
        else --(opc=sub or opc=cmp or opc=sbc) then --opc="0010" or opc="1010" or opc="0110"
            at:=a;
            bt:= not b;    
        end if;
        
        ct:=(at xor bt) xor result(31);
        flags(2)<= c xor ct;
    end case;
    flags(3)<=c;
    end if;
END PROCESS;
end fbehv;