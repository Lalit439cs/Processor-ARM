-- data memory 64x32 with
-- 1 read and 1 write port

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    use IEEE.numeric_std.all;
library work;
use work.MyTypes.all;

--  entity
ENTITY datam IS
  PORT(
    ADDRESS : IN word;--STD_LOGIC_VECTOR(6 DOWNTO 0);
       DATAIN: IN word; --std_logic_vector (31 downto 0);
       W:IN std_logic_vector (3 downto 0);
       --in W four write enable bits to help in writing byte ,word,etc
       CLK: IN STD_LOGIC;
       DATAOUT : OUT word
       );
END ENTITY;

--  architecture
ARCHITECTURE dm OF datam IS

--SIGNAL MEMORY : DMEM;
SIGNAL TEMP :word;
SIGNAL ADDR : INTEGER RANGE 0 TO 127;--PGM incorporated
signal MEMORY : DMEM :=
  ( 0 => X"EB000006",
  2 => X"EB00000C",
  -- ISR RESET
  --8 => X"E3A00001",
  8=> X"E6000011",
  -- ISR SWI
  16 =>X"E3A01070",
  17 => X"E5910000",
  18 => X"E3100C01",
  19 => X"0AFFFFFC",
  20 => X"E20000FF",
  21 => X"E6000011",
  --user program  --uncomment,change,run like previously
-- ftestcase1--
  64 => X"E3A00002",
  65 => X"E3A01003",
  66 => X"E0812000",
  67 => X"E3520005",
  68 => X"01A03002",
  others => X"00000000"
  );
-- -- ftestcase2--
--   64 => X"EF000000",
--   65 => X"E44D0004",
--   66 => X"E2800002",
--   others => X"00000000"
--   );

-- -- ftestcase3--
--   64 => X"E3A01070",
--   65 => X"E5910000",
--   66 => X"E1A02000",
--   others => X"00000000"
--   );

-- -- ftestcase4--
-- 64 => X"E3A00003",
-- 65 => X"EB000000",
-- 66 => X"E1A01000",
-- 67 => X"E3A01001",
-- 68 => X"E1A00011",
-- 69 => X"E6000010",
-- others => X"00000000"
-- );

-- -- ftestcase5--
-- 64 => X"E3A00002",
-- 65 => X"E3A01C01",
-- 66 => X"E0112120",
-- 67 => X"E1A04002",
-- 68 => X"03A03000",
-- 69 => X"23A03002",
-- 70 => X"33A03003",
-- 71 => X"E1A05003",
-- others => X"00000000"
-- );

-- -- ftestcase6--
-- 64 => X"E3B00000",
-- 65 => X"13A01001",
-- 66 => X"B3A0100B",
-- 67 => X"C3A0100C",
-- 68 => X"53A01005",
-- 69 => X"E1A02001",
-- others => X"00000000"
-- );
-- -- ftestcase7--
--   64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E3A02002",
--   67 => X"E0332091",
--   68 => X"11A05003",
--   others => X"00000000"
--   );
-- -- ftestcase8--
--   64 => X"E3A00007",
--   65 => X"E3A01004",
--   66 => X"E0112000",
--   67 => X"00623001",
--   68 => X"E3130000",
--   others => X"00000000"
--   );



--Mtestcase 1--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E0020091",
--   67 => X"E1A04002",
--   others => X"00000000"
--   );
--   --Mtestcase 2--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E3A02002",
--   67 => X"E0332091",
--   68 => X"11A05003",
--   others => X"00000000"
--   );
--   --Mtestcase 3--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E0832091",
--   67 => X"E1A05003",
--   68 => X"E1A04002",
--   others => X"00000000"
--   );
--   --Mtestcase 4--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E3A02002",
--   67 => X"E3A03000",
--   68 => X"E0A32091",
--   69 => X"E1A05003",
--   70 => X"E1A04002",
--   others => X"00000000"
--   );
  
--    --Mtestcase 5--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E0C32091",
--   67 => X"E1A05003",
--   68 => X"E1A04002",
--   others => X"00000000"
--   );
--   --Mtestcase 6--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A0110A",
--   66 => X"E3A02002",
--   67 => X"E3A03000",
--   68 => X"E0E32091",
--   69 => X"E1A05003",
--   70 => X"E1A04002",
--   others => X"00000000"
--   );
-- --PMtestcase 1--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A01000",
--   66 => X"E5A10004",
--   67 => X"E1D120B0",
--   68 => X"E1A04002",
--   others => X"00000000"
--   );
--   --PMtestcase 2--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A01000",
--   66 => X"E5A10001",
--   67 => X"E0D120D1",
--   68 => X"E1A04002",
--   69 => X"E1A05001",
--   others => X"00000000"
--   );
--   --PMtestcase 3--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00A49",
--   65 => X"E3A01000",
--   66 => X"E5810001",
--   67 => X"E1D120F1",
--   68 => X"E1A04002",
--   69 => X"E1A05001",
--   others => X"00000000"
--   );

-- --PMtestcase 4--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01000",
--   66 => X"E3A03001",
--   67 => X"E7C10003",
--   68 => X"E19120F3",
--   69 => X"E1A04002",
--   70 => X"E1A05001",
--   others => X"00000000"
--   );
-- --PMtestcase 5--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00801",
--   65 => X"E3A01000",
--   66 => X"E3A03001",
--   67 => X"E7A10083",
--   68 => X"E1D120B0",
--   69 => X"E1A04002",
--   70 => X"E1A05001",
--   others => X"00000000"
--   );
-- --stestcase 1--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01002",
--   66 => X"E0802101",
--   67 => X"E1A04002",
--   others => X"00000000"
--   );
-- --stestcase 2--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01002",
--   66 => X"E3A03002",
--   67 => X"E0802311",
--   68 => X"E1A04002",
--   others => X"00000000"
--   );
-- --stestcase 3-1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00002",
--   65 => X"E3A01C01",
--   66 => X"E0112120",
--   67 => X"E1A04002",
--   others => X"00000000"
--   );
-- --stestcase 4-1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01004",
--   66 => X"E3A02001",
--   67 => X"E7812100",
--   68 => X"E5913010",
--   69 => X"E1A04003",
--   others => X"00000000"
--   );

 -- --testcase 1--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01008",
--   66 => X"E1A04001",
--   67 => X"E0802001",
--   68 => X"E1A03002",
--   others => X"00000000"
--   );

--  -- --testcase 2--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E2802008",
--   66 => X"E1A03002",
--   others => X"00000000"
--   );
-- --testcase 3--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00002",
--   65 => X"E3A01003",
--   66 => X"E0812000",
--   67 => X"E3520005",
--   68 => X"01A03002",
--   others => X"00000000"
--   );


 -- --testcase 4--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00007",
--   65 => X"E3500005",
--   66 => X"12B01007",
--   67 => X"E1A02001",
--   others => X"00000000"
--   );
 
--testcase 5--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01005",
--   66 => X"E5801000",
--   67 => X"E2811002",
--   68 => X"E5801004",
--   69 => X"E5902000",
--   70 => X"E5903004",
--   71 => X"E0434002",
--   others => X"00000000"
--   );

--   --testcase 6--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00000",
--   65 => X"E3A01000",
--   66 => X"E0800001",
--   67 => X"E2811001",
--   68 => X"E3510002",
--   69 => X"1AFFFFFB",
--   others => X"00000000"
--   );
--  --testcase 7--1
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00004",
--   65 => X"E3A01003",
--   66 => X"E0912000",
--   67 => X"05801000",
--   68 => X"05903000",
--   69 => X"E3A03002",
--   others => X"00000000"
--   );
--testcase 8--
-- SIGNAL MEMORY : DMEM:=
--   (64 => X"E3A00007",
--   65 => X"E3A01004",
--   66 => X"E0112000",
--   67 => X"00623001",
--   68 => X"E3130000",
--   others => X"00000000"
--   );
-- SIGNAL W0,W1,W2,W3: std_logic_vector (7 downto 0);
BEGIN
-- 	ADDR <= CONV_INTEGER(ADDRESS);
	ADDR <= to_integer(unsigned(ADDRESS(6 downto 0)));--size
	TEMP<=MEMORY(ADDR);
	DATAOUT<=TEMP;
--     TEMPIN<=DATAIN;
--     W3 <= TEMPIN(31 DOWNTO 24);
  PROCESS(CLK)
  VARIABLE W0,W1,W2,W3: std_logic_vector (7 downto 0);
  variable TEMPW:word :="00000000000000000000000000000000";
  BEGIN
  	if (rising_edge(CLK) AND (W > "0000")) then
    	IF ('1' = W(0)) THEN
            W0 := DATAIN(7 DOWNTO 0);
        ELSE
            W0 := TEMP(7 DOWNTO 0);
        END IF;
        IF ('1' = W(1)) THEN
            W1 := DATAIN(15 DOWNTO 8);
        ELSE
            W1 := TEMP(15 DOWNTO 8);
        END IF;
        IF ('1' = W(2)) THEN
            W2 := DATAIN(23 DOWNTO 16);
        ELSE
            W2 := TEMP(23 DOWNTO 16);
        END IF;
        IF ('1' = W(3)) THEN
            W3 := DATAIN(31 DOWNTO 24);
        ELSE
            W3 := TEMP(31 DOWNTO 24);
        END IF;
        
        TEMPW (31 DOWNTO 24):=W3;
        TEMPW (23 DOWNTO 16):=W2;
        TEMPW (15 DOWNTO 8):=W1;
        TEMPW (7 DOWNTO 0):=W0;
        
        MEMORY(ADDR) <= TEMPW;
        --W3 & W2 & W1 & W0;--STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(W3 & W2) & STD_LOGIC_VECTOR(W1 & W0));
    END IF;
  END PROCESS;

END dm;
