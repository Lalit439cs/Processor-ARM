-- THE Multi CYCLE PROCESSOR
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.MyTypes.all;

entity processor is
 port (
 clock, reset : in std_logic;
 INPT : in std_logic;
 INDATA : IN WORD
 );
end processor;
architecture behavioral of processor is
    COMPONENT datam IS
    PORT(
      ADDRESS : IN word;
         DATAIN: IN word; --std_logic_vector (31 downto 0);
         W:IN std_logic_vector (3 downto 0);
         --in W four write enable bits to help in writing byte ,word,etc
         CLK: IN STD_LOGIC;
         DATAOUT : OUT word
         );
    END COMPONENT datam;

    COMPONENT alu_comb is
        port(
          a: in word ;
          b: in word;
          opc:in optype;
          cin:in std_logic;
          r: out word;
          cout:out std_logic);
    end COMPONENT alu_comb;

    COMPONENT SHIFTER is
        port(
          s_in: in word ;
          --"00" for LSL, "01" for LSR, "10" for ASR and "11" for ROR
          typ:in std_logic_vector (1 downto 0);
          val: in std_logic_vector (4 downto 0);--deal overflow amount ?-outside...read
          s_out: out word;
          cout:out std_logic);
    end COMPONENT SHIFTER;

    COMPONENT flag is
        port(
            instr_class : in instr_class_type;
            opc:in optype;
            DP_subclass : IN DP_subclass_type;
            s,shiftr:in std_logic;
            c_alu,c_shiftr,CLK:in std_logic;
            a,b:in std_logic;--msb bits
            result: in word;
            cvzn:out nibble);
    end COMPONENT flag;

    COMPONENT RF IS
    PORT(
        RADDRESS1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        RADDRESS2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        WADDRESS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        DATAIN: IN word;
        -- write when W -1
        CLK,W : IN STD_LOGIC;
        DATAOUT1 : OUT word;
        DATAOUT2 : OUT word
        );
    END COMPONENT RF;

    COMPONENT Decoder is
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
    end COMPONENT Decoder;

    COMPONENT CHECKER IS
    PORT(
        FLAGS : IN nibble;
        COND : IN nibble;
        PREDICATE : OUT STD_LOGIC
        );
    END COMPONENT CHECKER;

    component PMconnect is
    port(
        minstr: in minstr_type ;
        rout: in word;
        mout: in word;
        cstate:in ctrl_state;
        adr:in std_logic_vector (1 downto 0);
        minn: out word;
        rin : out word;
        mw : out std_logic_vector (3 downto 0));
    end component PMconnect;

    component mulacc is
        port(
          a: in word ;
          b: in word;
          c: in std_logic_vector (63 downto 0);
          mopc:in std_logic_vector (2 downto 0);
          r: out std_logic_vector (63 downto 0));
        --   cout:out std_logic);
    end component mulacc;

    -- Sign extension for branch address
    signal S_ext : std_logic_vector (7 downto 0);
    -- Instruction fields
    signal ALUOP,OPC : optype;
    signal Cond,FLAGS: nibble;
    signal F : instr_class_type;
    signal Ubit :DT_offset_sign_type;
    signal Lbit : load_store_type;
    signal Ibit : DP_operand_src_type;
    signal Sbit : std_logic;
    -- signal R: std_logic:= '1';
    signal W: std_logic;
    signal MW,MWP: std_logic_vector (3 downto 0);
    SIGNAL DP_subclass : DP_subclass_type;
    signal Im: std_logic_vector (7 downto 0);
    signal Rs: std_logic_vector (3 downto 0);--integer range 0 to 30;
    signal Offset : std_logic_vector (11 downto 0); 
    signal S_offset : std_logic_vector (23 downto 0);
    signal Rd, Rn, Rm : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sftr : std_logic;
    signal c_in:std_logic:= '0';--adc carry where
    signal c_alu,c_sft:std_logic;
    signal a_in,b_in,rd2,r_out : word;
    signal MEMout,RFin:word;
    -- signal t1,t2,t3:std_logic_vector(31 downto 0);
    --signals EXTRA
    signal PC, IR,A,B,C,D,DR,RES: word;--Instr
    --signal IW,AW,BW,DW,REW:STD_LOGIC;
    signal PREDICATE ,PW,FW : std_logic;
    signal rd_AdrA,rd_AdrB : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL data_outA,data_outB :word;
    SIGNAL MEMad,MEMin,MEMinP:word;
    signal control_state: ctrl_state;
    signal state:STD_LOGIC_VECTOR(3 DOWNTO 0);
    --shifter
    signal SFTin,sout : word;
    signal styp: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal amt : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL svar : std_logic; --amount of shift/rotate may be variable,reg

    --PMconnect
    signal minstr : minstr_type ; --OTHR
    signal rout : word ;
    -- mout - MEMout
    --cstate - control_state
    signal adr : std_logic_vector (1 downto 0) ;
    signal rin : word;
    signal minstype : std_logic_vector (2 downto 0) ;-- "ZZZ"
    signal SH : std_logic_vector (1 downto 0) ;

    --Auto-indexing
    signal Pbit,Wback,Idt,Bbit: std_logic;
    signal rwt:std_logic_vector (3 downto 0) ;

    -- MUL-ACCUMULATE
    SIGNAL mrout,MLA,cm: std_logic_vector (63 downto 0) ;
    SIGNAL am,bm,HC : word;
    signal mopc :std_logic_vector (2 downto 0) ;
    signal long: std_logic;
    -- signal high: std_logic:= '0';--high bits of 64  
    signal rflag :word;

    --last stage
    signal mode: std_logic;--mode -1 for user ,supervisor-0
    signal nerror: std_logic; -- 0 when read fails or exit state
    signal LR : word;
    signal link: std_logic;-- 1 for bl

begin


-- component instances
	RFL: RF PORT MAP( rd_AdrA,rd_AdrB,rwt,RFin,clock,W,data_outA,data_outB);
    ALU: alu_comb port map(a_in, b_in,ALUOP,c_in, r_out,c_alu);
    DTM: datam PORT MAP( MEMad,MEMin,MW,clock, MEMout);
    -- PGM: progm PORT MAP(PC (7 downto 2), R, Instr);
    -- PCC: pcr PORT MAP(NXT,reset,PW,clock,PC);
    DCD: Decoder PORT MAP(IR,F,OPC,DP_subclass,Ibit,Lbit,Cond,Ubit);
    CHK: CHECKER PORT MAP(FLAGS,Cond,predicate);
    FLG: flag PORT MAP(F,OPC,DP_subclass,FW,sftr,c_alu,c_sft,clock,a_in(31),b_in(31),rflag,FLAGS);
    SFT: SHIFTER PORT MAP(SFTin,styp,amt,sout,c_sft);
    PMC: PMconnect port map(minstr,rout,MEMout,control_state,adr,MEMinP,rin,MWP);
    MLT : mulacc port map (am,bm,cm,mopc,mrout);
-- concurrent assignments for extracting instruction fields
    Im <= IR (7 downto 0);
    Rm <=IR (3 downto 0);
    Rd <= IR (15 downto 12);
    -- rn and rd are opposite in mula
    Rn <=IR (19 downto 16);
    Rs <= IR (11 downto 8);--to_integer(unsigned(IR (11 downto 8) sll 1) );
    Sbit <= IR (20);
    Offset <= IR (11 downto 0); 
    -- Sign extension for branch address
    S_ext <= "11111111" when (IR(23) = '1') else "00000000";
    S_offset <= IR (23 downto 0);
    Idt <= IR(25);--I (immediate) IN DT
    Bbit <= IR(22);--B (BYTE) IN DT
    Pbit <= IR(24);--P (PRE_INDEXING) IN DT
    Wback <= IR(21);--W (WRITE BACK) IN DT
    SH <= IR (6 DOWNTO 5);
    sftr <='1' when (F = DT and (IR(25) = '1' and IR(11 DOWNTO 4) /= "00000000")) 
    else '1' when (F = DP and ((Ibit = reg and  IR(11 DOWNTO 4) /= "00000000" ) OR (Ibit = imm AND Rs /= "0000"  )))
    else '0';
    svar <= IR(4);
    long <= IR (23);
    link <= IR (24);
    styp <= "11" when (F = DP and Ibit = imm) else IR (6 DOWNTO 5);
    rflag <= (mrout(63 downto 32) or mrout (31 downto 0)) when ( F = MUL ) else r_out;

--     PW <='0' when Instr = X"00000000" else '1' ;--EXIT OR END OF CODE

-- control signals and multiplexers
process (control_state, IR, opC, A, B,RES,DR, FLAGS,PC,LR,Rm,Rn,Rs,Rd,styp,Sbit,sftr,styp,svar,Im,Idt,Bbit,Pbit,Wback,SH,S_ext,S_offset,Offset,long,r_out,inpt)--,MWP,MEMinP,RES,PREDICATE,ALUop...other offset? Lbit
variable t1:std_logic_vector(31 downto 0);
variable mt:std_logic_vector(31 downto 0);
begin
-- default values
PW <= '0';
FW <= '0';
W <= '0';
ALUop <= opc; a_in <= A; 
b_in<= B; c_in <= Flags (3);
rd_AdrB <= Rm;
rd_AdrA <= Rn;
rout <= B ;
-- adr <= "00" ;
RFin <= RES;
--MW <= "0000" ;-- half,byte,etc changes
amt <= IR (11 DOWNTO 7);
sftin <= B;
rwt <= Rd;
nerror <= '1';

if (Pbit = '0') then mt := A ; 
ELSE mt := RES; END IF;

--input port related AND PMCONNECT MULTIPLEXING
if (inpt = '1' AND control_state /= MSTR) then 
MW <= "1111"; MEMin <= INDATA ;  MEMad <= X"0000001C";
else MW <= MWP; MEMin <= MEMinP; MEMad <= mt srl 2 ; end if;

-- state dependent values
case control_state is

when fetch => MEMad <= PC srl 2;
PW <= '1'; 
ALUop <= adc; a_in <= "00" & PC (31 downto 2);
b_in <= X"00000000"; c_in <= '1';
state <= "0000";

when swist => PW <= '1';
state <= "1011";

when read_AB => 
if (F = DT) then rd_AdrB <= Rd ;
elsif (F = MUL) then rd_AdrA <= Rs ; 
elsif (F = RTN) then rd_AdrA <= "0000";rd_AdrB <= "1110" ;
end if;
state <= "0001";

when arithm => FW <= Sbit;
state <= "0010";
--default case
if (sftr = '1') then b_in <= D;-- all shift presence
elsif (F = DP and Ibit = imm) then --Ibit
--t1:= X"000000" & Im;
b_in <= X"000000" & Im;--std_logic_vector(unsigned(t1) ror Rs ); 

ELSIF (F = DT) then 
    if (IR (27 downto 26) = "01" and Idt = '0') then b_in <= X"00000" & Offset;
    elsif (IR (27 downto 26) = "00" and Bbit = '1') then t1 (31 downto 8) := X"000000" ;
    t1 (7 downto 4) := IR (11 downto 8) ;t1 (3 downto 0) := IR (3 downto 0) ;
    b_in <= t1;
    else b_in <= C; end if;

    IF (Ubit = minus) then 
    ALUOP <= SUB;ELSE  ALUOP <= add;-- change if reg allowed
    end if;

ELSIF (F = BRN ) then--and predicate = '1'
    PW <= '1'; 
    ALUop <= adc; a_in <= "00" & PC (31 downto 2);
    b_in <= S_ext & S_offset; c_in <= '1';
end if;

--MEMORY INSTRUCTION TYPE DECISION-
IF (IR (27 downto 25) = "000" AND (IR (7 downto 4) > "1001")) THEN --and many 
    if (SH = "01" AND Lbit = load) THEN minstr <= LDRH; minstype <= "100" ;
    ELSIF (SH = "01" AND Lbit = store ) THEN minstr <= STRH; minstype <= "001" ;
    ELSIF (SH = "10") THEN minstr <= LDRSB;minstype <= "111" ;
    ELSIF (SH = "11") THEN minstr <= LDRSH;minstype <= "101" ;
    --SWP
    END IF ;
elsif (F = DT) THEN
    IF (Lbit = load and Bbit = '1' ) then MINSTR <= LDRB; minstype <= "110" ;
    ELSIF (Lbit = load and Bbit = '0' ) then MINSTR <= LDR; minstype <= "011" ;--adr <= "00" ;
    ELSIF (Lbit = store and Bbit = '0' ) then MINSTR <= STR; minstype <= "000" ;--adr <= "00" ;
    ELSE MINSTR <= STRB; minstype <= "010" ;
    END IF ;
else minstr <= OTHR; minstype <= "ZZZ" ;
END IF;

WHEN MSTR => --MW <= "1111";
    state <= "0011";
    CASE minstr IS 
        WHEN STRB  => ADR <= mt (1 DOWNTO 0);
        WHEN STRH => ADR <= mt(1) & '0';
        WHEN OTHERS => ADR <= "00";
    END CASE;

WHEN w2RF =>
state <= "0101";
if (F = DT AND Lbit = load) then RFin <= DR; W <= '1';
elsif ((F = DP) AND ((DP_subclass = arith) or (DP_subclass = logic))) then  W <= '1';
elsif (F = MUL and long = '0') THEN rwt <= Rn; RFin <= MLA (31 DOWNTO 0); W <= '1';
elsif (F = MUL and long = '1') THEN rwt <= Rd; RFin <= MLA (31 DOWNTO 0); W <= '1';
elsif (F = BRN) then rwt <= "1110"; RFin <= LR; W <= '1';
-- elsif (F = DT AND (Lbit = load)) then RFin <= DR; W <= '1'; 
end if;

WHEN MLDR => state <= "0100";--LDR | LDRH | LDRSH |LDRB | LDRSB
    CASE minstr IS 
        WHEN LDRB | LDRSB  => ADR <= mt (1 DOWNTO 0);
        WHEN LDRH | LDRSH=> ADR <= mt (1) & '0';
        WHEN OTHERS => ADR <= "00";
    END CASE;

WHEN READ_C => -- ONLY DP,DT,MUL
    state <= "0110";
    if (F = DT) then rd_AdrB <= Rm ;
    elsif (F = MUL) THEN rd_AdrA <= Rn;rd_AdrB <= Rd;--rn,rd opp in mul
    ELSE rd_AdrB <= Rs;end if;

WHEN RSHIFT => state <= "0111";
    if (F = DT) then sftin <= C; 
    elsif (F = DP and (Ibit = reg and svar = '1')) then amt <= C(4 downto 0);--default need on overflow
    elsif (F = DP and (Ibit = imm)) then --c read cond
        amt <= Rs & '0' ;
        sftin <= X"000000" & Im;
     end if;

WHEN WB2RF => state <= "1000";
    rwt <= Rn;
    RFin <= RES; W <= '1';

WHEN MULAC => state <= "1001";
mopc <= IR (23 DOWNTO 21);
am <= A;
bm <= B;
FW <= Sbit;
if (long = '1') then cm <= HC & C; else cm <= X"00000000" & C;end if;--need?

WHEN MW2RF => state <= "1010";
    rwt <= Rn;--RDHigh
    RFin <= MLA (63 DOWNTO 32); W <= '1';

when retrn =>state <= "1100";

when elast =>state <= "1101";
nerror <= '0';
--others => null;
end case;
end process;


-- control FSM
process (clock, reset)
variable temp:std_logic_vector(31 downto 0);
begin
if reset ='1' then control_state <= fetch; -- start state
PC <= X"00000000";
mode <= '0';
elsif rising_edge(clock) then

    case control_state is
        
    when fetch => IR <= Memout;
        if (PW = '1') THEN 
        PC <= r_out sll 2;END IF;--ELSE EXIT ,outloop may be use
        if (Memout(27 downto 26) = "11") then control_state <= swist; else 
        control_state <= read_AB; end if;
        --BELOW predicate here possible? -one cycle
        
    when read_AB => 
    A <= data_outA; B <= data_outB;
        IF (PREDICATE = '1') THEN
        if (F = DT) then 
            if (IR (27 downto 26) = "01" and Idt = '1') then control_state <= READ_C;
            elsif (IR (27 downto 26) = "00" and Bbit = '0') then control_state <= READ_C;
            else control_state <= arithm;
        end if ;
        ELSIF(F = DP and ( Ibit = reg and svar = '1' )) THEN control_state <=  READ_C;
        ELSIF(F = DP and sftr = '1') THEN control_state <=  RSHIFT;
        ELSIF (F = MUL and IR(21) = '1') THEN control_state <= READ_C;
        ELSIF (F = MUL and IR(21) = '0') THEN control_state <= MULAC;
        ELSIF (F = RTN) THEN control_state <= RETRN; 
        ELSE control_state <= arithm;END IF;
    ELSIF(PREDICATE = '0') THEN control_state <= FETCH;END IF;--OTHER cond...
    --TWO CYCLE IN FALSE PRDEICATE

    when swist => mode <= '0'; --can put in controller
        LR <= PC;
        if (PW = '1') THEN PC <= X"00000008" ;end if; -- no need of PW
        control_state <= FETCH;

    when arithm => RES <= r_out; --FLAgs may change
        if (F = DT) then 
            if (Pbit = '0') then temp := A ; --memory address
            ELSE temp := r_out; END IF;

            IF (MODE = '1' and (temp < X"00000100") ) then control_state <= elast; --unaccessible
            ELSIF ( Lbit = load) THEN control_state <= MLDR;--LDR | LDRH | LDRSH |LDRB | LDRSB
            else control_state <= MSTR; end if;-- STR | STRH |STRB 

        -- if (F = DT and Lbit = load) then control_state <= MLDR;
        -- elsif (F = DT and Lbit = store) then control_state <= MSTR;
        else
            Case F is 
            when DP => control_state <= w2RF;
            when BRN => 
                if (PC = X"00000004") then LR <= X"00000100" ;
                ELSIF (PC /= X"0000000C" and link = '1') THEN LR <= PC;-- assuming link = '1' in bl only branchtype
                
                END IF ;
                if (PW = '1') THEN --BRN CASE
                temp := r_out sll 2;
                PC <= temp;END IF;--ELSE EXIT ,outloop may be use
                
                IF (MODE = '1' and (temp < X"00000100") ) then control_state <= elast; --unaccessible
                ELSIF ( link = '1') THEN control_state <= W2RF;
                else control_state <= fetch; end if;
            when others => null;
            end case;
        END if;
        --ADR CAN BE DECIDED HERE ALSO

    WHEN MSTR => if (Wback = '1' or Pbit = '0' ) then control_state <= WB2RF;
        else control_state <= fetch; end if;

    WHEN MLDR => DR <= rin ;
        if (Wback = '1' or Pbit = '0') then control_state <= WB2RF;
        else control_state <= w2RF; end if;

    WHEN w2RF =>
    if (F = MUL AND long = '1') then control_state <= MW2RF; 
    ELSE control_state <= fetch; END IF ;

    WHEN READ_C => C <= data_outB;
        IF (F = DT and (sftr = '0')) THEN control_state <= arithm;--skip a cycle
        ELSIF (F = MUL) THEN HC <= data_outA ; control_state <= MULAC;
        ELSE control_state <= RSHIFT;END IF;
    
    WHEN RSHIFT => D <= sout; control_state <= arithm;--skipped all possible cycles to reach RSHIFT if necessary
    WHEN WB2RF => if (lbit = load) then control_state <= w2RF;--PUT
        else control_state <= fetch; end if;

    when MULAC => MLA <= mrout;
    control_state <= w2RF;

    WHEN MW2RF =>control_state <= fetch;

    when retrn => -- IR(0) rte bit
    PC <= B;
    if (IR(0)= '1') THEN MODE <= '1' ;END IF;
    -- if (A = X"00000000" and IR(0) = '1') then control_state <= elast;
     control_state <= fetch;
    
    when elast =>null;--control_state <= elast;

    end case;
end if;
end process;
end behavioral;
