----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			SBox
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

USE WORK.SKINNYPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY SBox IS	
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_128);
	PORT ( X : IN	STD_LOGIC_VECTOR ((GET_WORD_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR ((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END SBox;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF SBox IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL NO3, XO3, NO2, XO2, NO1, XO1, NO0, XO0 : STD_LOGIC;
	SIGNAL O, P												 : STD_LOGIC_VECTOR(39 DOWNTO 0);

-- DATAFLOW
----------------------------------------------------------------------------------
BEGIN

	-- 4-BIT S-BOX ----------------------------------------------------------------
	S4 : IF BS = BLOCK_SIZE_64 GENERATE
		NO3 <= X(3) NOR X(2);
		XO3 <= X(0) XOR NO3;
		
		NO2 <= X(2) NOR X(1);
		XO2 <= X(3) XOR NO2;
		
		NO1 <= X(1) NOR XO3;
		XO1 <= X(2) XOR NO1;
		
		NO0 <= XO3 NOR XO2;
		XO0 <= X(1) XOR NO0;
		
		Y <= XO3 & XO2 & XO1 & XO0;
	END GENERATE;
	-------------------------------------------------------------------------------
	
	-- 8-BIT S-BOX ----------------------------------------------------------------
	S8 : IF BS = BLOCK_SIZE_128 GENERATE
		P(7 DOWNTO 0) <= X;

		GEN : FOR I IN 0 TO 3 GENERATE
			O((8 * I +  7) DOWNTO (8 * I + 4)) <= P((8 * I + 7) DOWNTO (8 * I + 5)) & (P(8 * I + 4) XOR (P(8 * I + 7) NOR P(8 * I + 6)));
			O((8 * I +  3) DOWNTO (8 * I + 0)) <= P((8 * I + 3) DOWNTO (8 * I + 1)) & (P(8 * I + 0) XOR (P(8 * I + 3) NOR P(8 * I + 2)));		
			P((8 * I + 15) DOWNTO (8 * I + 8)) <= O((8 * I + 2)) & O((8 * I + 1)) & O((8 * I + 7)) & O((8 * I + 6)) & O((8 * I + 4)) & O((8 * I + 0)) & O((8 * I + 3)) & O((8 * I + 5));
		END GENERATE;

		Y <= O(31 DOWNTO 27) & O(25) & O(26) & O(24);	
	END GENERATE;
	-------------------------------------------------------------------------------
	
END Dataflow;

