----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			Permutation
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
ENTITY HPermutation is
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_128);
	PORT ( X : IN  STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS)/2 - 1) DOWNTO 0);
          Y : OUT STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS)/2 - 1) DOWNTO 0));
END HPermutation;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF HPermutation IS

	-- CONSTANTS ------------------------------------------------------------------
  CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	
BEGIN

	-- ROW 1 ----------------------------------------------------------------------
	Y((8 * W - 1) DOWNTO (7 * W)) <= X(( 7 * W - 1) DOWNTO ( 6 * W));
	Y((7 * W - 1) DOWNTO (6 * W)) <= X(( 1 * W - 1) DOWNTO ( 0 * W));
	Y((6 * W - 1) DOWNTO (5 * W)) <= X(( 8 * W - 1) DOWNTO ( 7 * W));
	Y((5 * W - 1) DOWNTO (4 * W)) <= X(( 3 * W - 1) DOWNTO ( 2 * W));
	-------------------------------------------------------------------------------

	-- ROW 2 ----------------------------------------------------------------------	
	Y((4 * W - 1) DOWNTO (3 * W)) <= X(( 6 * W - 1) DOWNTO ( 5 * W));
	Y((3 * W - 1) DOWNTO (2 * W)) <= X(( 2 * W - 1) DOWNTO ( 1 * W));
	Y((2 * W - 1) DOWNTO (1 * W)) <= X(( 4 * W - 1) DOWNTO ( 3 * W));
	Y((1 * W - 1) DOWNTO (0 * W)) <= X(( 5 * W - 1) DOWNTO ( 4 * W));
	-------------------------------------------------------------------------------        


END Dataflow;

