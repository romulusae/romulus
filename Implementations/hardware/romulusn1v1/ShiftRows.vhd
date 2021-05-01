----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			ShiftRows
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
ENTITY ShiftRows IS
	GENERIC (BS : BLOCK_SIZE);
	PORT ( X : IN	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0));
END ShiftRows;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF ShiftRows IS

	-- CONSTANT -------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	
BEGIN
	
	-- ROW 1 ----------------------------------------------------------------------
	Y((16 * W - 1) DOWNTO (12 * W)) <= X((16 * W - 1) DOWNTO (12 * W));
	-------------------------------------------------------------------------------
	
	-- ROW 2 ----------------------------------------------------------------------
	Y((12 * W - 1) DOWNTO ( 8 * W)) <= X(( 9 * W - 1) DOWNTO ( 8 * W)) & X((12 * W - 1) DOWNTO ( 9 * W));
	-------------------------------------------------------------------------------
	
	-- ROW 3 ----------------------------------------------------------------------	
	Y(( 8 * W - 1) DOWNTO ( 4 * W)) <= X(( 6 * W - 1) DOWNTO ( 4 * W)) & X(( 8 * W - 1) DOWNTO ( 6 * W));
	-------------------------------------------------------------------------------
	
	-- ROW 4 ----------------------------------------------------------------------
	Y(( 4 * W - 1) DOWNTO ( 0 * W)) <= X(( 3 * W - 1) DOWNTO ( 0 * W)) & X(( 4 * W - 1) DOWNTO ( 3 * W));
	-------------------------------------------------------------------------------

END Dataflow;