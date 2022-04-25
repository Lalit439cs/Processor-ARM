library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.MyTypes.all;

--Flags and associated circuit--
entity Decoder is
Port (
    instruction : in word;
    instr_class : out instr_class_type;
    operation : out optype;
    DP_subclass : out DP_subclass_type;
    DP_operand_src : out DP_operand_src_type;
    load_store : out load_store_type;
    cond: out nibble;
    DT_offset_sign : out DT_offset_sign_type
);
end Decoder;

architecture Behavior of Decoder is
    type oparraytype is array (0 to 15) of optype;
    constant oparray : oparraytype := (andop, eor, sub, rsb, add, adc, sbc, rsc, tst, teq, cmp, cmn, orr, mov, bic, mvn);
begin
    -- with instruction (27 downto 26) select instr_class 

    instr_class <= MUL when (instruction (27 downto 24) = "0000" AND (instruction (7 downto 4) = "1001")) else
        RTN when (instruction (27 downto 25) = "011"  AND instruction (4) = '1' ) else 
        DT when (instruction (27 downto 26) = "01" OR (instruction (27 downto 25) = "000" AND (instruction (7 downto 4) > "1001"))) else 
        DP when (instruction (27 downto 26) = "00") else 
        BRN when (instruction (27 downto 26) = "10") else 
        SWI WHEN (instruction (27 downto 26) = "11") else none ;

    operation <= oparray (to_integer(unsigned (instruction (24 downto 21)))) ;

    with instruction (24 downto 22) select
        DP_subclass <= arith when "001" | "010" | "011",
        logic when "000" | "110" | "111",
        comp when "101",
        test when others;
    cond <= instruction (31 downto 28);
    DP_operand_src <= reg when instruction (25) = '0' else imm;
    load_store <= load when instruction (20) = '1' else store;
    DT_offset_sign <= plus when instruction (23) = '1' else minus;--U
end Behavior;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.MyTypes.all;

-- in multicycle used PC as local signal
--Program Counter with next address logic--
-- entity
ENTITY pcr IS
  PORT(
       NXT : IN word;
       -- write when R is 1, else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
       reset,PW,CLK : IN STD_LOGIC;
       CURRENT : OUT word
       );
END pcr;

--  architecture
ARCHITECTURE pcbeh OF pcr IS--reset can be added
SIGNAL ADDRESS : word;
BEGIN
CURRENT <= ADDRESS;
PROCESS(CLK,reset)
BEGIN
	
--     if (reset = '1') then
--         ADDRESS <= X"00000000"; --TIMING CHECK
    if (rising_edge(CLK) ) then
    if (reset = '1') then
        ADDRESS <= X"00000000";
    ELSIF(PW='1') THEN
        ADDRESS<= NXT; --EXIT COND
    ELSE
        ADDRESS<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    END IF;
END IF;
END PROCESS;

END pcbeh;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.MyTypes.all;

--Condition Checker--
-- entity
ENTITY CHECKER IS
  PORT(
       FLAGS : IN nibble;
       COND : IN nibble;
       PREDICATE : OUT STD_LOGIC
       );
END CHECKER;

--  architecture
ARCHITECTURE beh OF CHECKER IS
BEGIN
PROCESS(FLAGS,COND)
BEGIN
CASE COND is
    WHEN "0000"=> PREDICATE <=FLAGS(1); -- EQ
    WHEN "0001"=> PREDICATE <= NOT FLAGS(1); --NE
    WHEN "0010"=> PREDICATE <=FLAGS(3);
    WHEN "0011"=> PREDICATE <= not FLAGS(3);
    WHEN "0100"=> PREDICATE <=FLAGS(0);--MI
    WHEN "0101"=> PREDICATE <= not FLAGS(0);--PL
    WHEN "0110"=> PREDICATE <=FLAGS(2);
    WHEN "0111"=> PREDICATE <= not FLAGS(2);
    WHEN "1000"=> PREDICATE <=FLAGS(3) AND NOT FLAGS(1);--HI
    WHEN "1001"=> PREDICATE <= not (FLAGS(3) AND NOT FLAGS(1)); --LS
    WHEN "1010"=> PREDICATE <=FLAGS(2) XNOR FLAGS(0);--GE
    WHEN "1011"=> PREDICATE <= not (FLAGS(2) XNOR FLAGS(0));--LT
    WHEN "1100"=> PREDICATE <= NOT FLAGS(1) AND (FLAGS(2) XNOR FLAGS(0));--GT
    WHEN "1101"=> PREDICATE <= not (NOT FLAGS(1) AND (FLAGS(2) XNOR FLAGS(0)));--LE
    WHEN "1110"=> PREDICATE <= '1';--AL
    WHEN OTHERS => PREDICATE <= 'Z';--
END CASE;
END PROCESS;

END beh;