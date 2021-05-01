----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			ConstGenerator
--
--	REVISION:				1.00 - File created
--
-- LICENCE: 				Please look at licence.txt
-- USAGE INFORMATION:	Please look at readme.txt. If licence.txt or readme.txt
--								are missing or	if you have questions regarding the code
--								please contact Pascal Sasdrich (pascal.sasdrich@rub.de)
--								or Amir Moradi (amir.moradi@rub.de).
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.
----------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY ConstGenerator_x4 IS
  PORT (CLK    : IN  STD_LOGIC;
        INIT	: IN  STD_LOGIC;
        CONST0  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        CONST1  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        CONST2  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        CONST3  : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));              
END ConstGenerator_x4;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF ConstGenerator_x4 IS

	-- SIGNALS --------------------------------------------------------------------
  SIGNAL STATE : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL UPDATE0 : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL UPDATE1 : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL UPDATE2 : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL UPDATE3 : STD_LOGIC_VECTOR(5 DOWNTO 0);

-- DATAFLOW
----------------------------------------------------------------------------------
BEGIN
	-- STATE ----------------------------------------------------------------------
	REG : PROCESS(CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (INIT = '1') THEN
				STATE <= "000000";
			ELSE
				STATE <= UPDATE3;
			END IF;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE0(5 DOWNTO 0) <= STATE(4 DOWNTO 0) & (STATE(5) XNOR STATE(4));
        UPDATE1(5 DOWNTO 0) <= UPDATE0(4 DOWNTO 0) & (UPDATE0(5) XNOR UPDATE0(4));
        UPDATE2(5 DOWNTO 0) <= UPDATE1(4 DOWNTO 0) & (UPDATE1(5) XNOR UPDATE1(4));
        UPDATE3(5 DOWNTO 0) <= UPDATE2(4 DOWNTO 0) & (UPDATE2(5) XNOR UPDATE2(4));
	-------------------------------------------------------------------------------

	-- CONSTANT -------------------------------------------------------------------
	CONST0 <= UPDATE0;
        CONST1 <= UPDATE1;
        CONST2 <= UPDATE2;
        CONST3 <= UPDATE3;
	-------------------------------------------------------------------------------
  
END Dataflow;
