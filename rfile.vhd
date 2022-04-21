-- register file 16x32 

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
--     USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    use IEEE.numeric_std.all;
library work;
use work.MyTypes.all;

-- entity
ENTITY RF IS
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
END ENTITY;
--impedence - "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"

-- RFILE architecture
ARCHITECTURE RF_BEH OF RF IS

TYPE RFILE IS ARRAY (15 DOWNTO 0) OF word;
SIGNAL RFL : RFILE := (13 => X"000001FF",others => X"00000000"
);--can all be 0 initially
SIGNAL RADDR1 : INTEGER RANGE 0 TO 15;
SIGNAL RADDR2 : INTEGER RANGE 0 TO 15;
SIGNAL WADDR : INTEGER RANGE 0 TO 15;

BEGIN
	RADDR1 <= to_integer(unsigned(RADDRESS1));
    RADDR2 <= to_integer(unsigned(RADDRESS2));
    WADDR <= to_integer(unsigned(WADDRESS));

    
    DATAOUT1 <=RFL(RADDR1);
    DATAOUT2 <=RFL(RADDR2);
  PROCESS(CLK)
  BEGIN
  	if (rising_edge(CLK)) then
    	IF (W='1') THEN 
        	RFL(WADDR) <=DATAIN;
        END IF;
    END IF;
  END PROCESS;

END RF_BEH;
