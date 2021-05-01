----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			RoundFunction
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
ENTITY RoundFunction IS	
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_128; TS : TWEAK_SIZE := TWEAK_SIZE_3N);
	PORT ( CLK				: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
			 INIT				: IN	STD_LOGIC;
			 --DONE				: OUT STD_LOGIC;
			 -- KEY PORT -------------------------------------
			 ROUND_KEY		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_IN		: IN	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS) 	  - 1) DOWNTO 0);
			 ROUND_OUT		: OUT	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)	  - 1) DOWNTO 0);
                         CONST_OUT : out STD_LOGIC_VECTOR (5 downto 0));
END RoundFunction;



-- ARCHITECTURE : MIXED
----------------------------------------------------------------------------------
ARCHITECTURE Mixed OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	
	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CURRENT_STATE, NEXT_STATE, KEY_ADDITION,
			 CONST_ADDITION, SUBSTITUTION, SHIFTROWS	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL CONST												: STD_LOGIC_VECTOR( 		5  DOWNTO 0);

BEGIN

	-- CONSTANT GENERATOR ---------------------------------------------------------
	ConstGen : ENTITY work.ConstGenerator
	PORT MAP (
		CLK	=> CLK,
		INIT	=> INIT,
		CONST	=> CONST
	);
	-------------------------------------------------------------------------------
		
	-- REGISTER -------------------------------------------------------------------
	--R : ENTITY work.ScanFF
	--GENERIC MAP (SIZE => N)
	--PORT MAP (
	--	CLK 	=> CLK,
	--	SE		=> INIT,
	--	D		=> NEXT_STATE,
	--	DS		=> ROUND_IN,
	--	Q		=> CURRENT_STATE
	--);
	-------------------------------------------------------------------------------
			
	-- S-BOX ----------------------------------------------------------------------
	GEN : FOR I IN 0 TO 15 GENERATE
		S : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (ROUND_IN((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION((W * (I + 1) - 1) DOWNTO (W * I)));
	END GENERATE;
	-------------------------------------------------------------------------------

	-- CONSTANT ADDITION ----------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		CONST_ADDITION(63 DOWNTO 60) <= SUBSTITUTION(63 DOWNTO 60) XOR CONST(3 DOWNTO 0);
		CONST_ADDITION(59 DOWNTO 46) <= SUBSTITUTION(59 DOWNTO 46);
		CONST_ADDITION(45 DOWNTO 44) <= SUBSTITUTION(45 DOWNTO 44) XOR CONST(5 DOWNTO 4);
		CONST_ADDITION(43 DOWNTO 30) <= SUBSTITUTION(43 DOWNTO 30);
		CONST_ADDITION(29) 	     	  <= NOT(SUBSTITUTION(29));
		CONST_ADDITION(28 DOWNTO  0) <= SUBSTITUTION(28 DOWNTO  0);
	END GENERATE;
	
	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		CONST_ADDITION(127 DOWNTO 124) <= SUBSTITUTION(127 DOWNTO 124);
		CONST_ADDITION(123 DOWNTO 120) <= SUBSTITUTION(123 DOWNTO 120) XOR CONST(3 DOWNTO 0);
		CONST_ADDITION(119 DOWNTO  90) <= SUBSTITUTION(119 DOWNTO  90);
		CONST_ADDITION( 89 DOWNTO  88) <= SUBSTITUTION( 89 DOWNTO  88) XOR CONST(5 DOWNTO 4);
		CONST_ADDITION( 87 DOWNTO  58) <= SUBSTITUTION( 87 DOWNTO  58);
		CONST_ADDITION(57) 	    	    <= NOT(SUBSTITUTION(57));
		CONST_ADDITION( 56 DOWNTO   0) <= SUBSTITUTION( 56 DOWNTO   0);	
	END GENERATE;
	-------------------------------------------------------------------------------

	-- SUBKEY ADDITION ------------------------------------------------------------
	T1N : IF TS = TWEAK_SIZE_1N GENERATE
		KEY_ADDITION((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		KEY_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	T2N : IF TS = TWEAK_SIZE_2N GENERATE
		KEY_ADDITION((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		KEY_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));	
	END GENERATE;
	
	T3N : IF TS = TWEAK_SIZE_3N GENERATE
		KEY_ADDITION((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		KEY_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));	
	END GENERATE;
	
	KEY_ADDITION(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION(( 4 * W - 1) DOWNTO ( 0 * W));
	-------------------------------------------------------------------------------
	
	-- SHIFT ROWS -----------------------------------------------------------------
	SR : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION, SHIFTROWS);
	-------------------------------------------------------------------------------
	
	-- MIX COLUMNS ----------------------------------------------------------------
	MC : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS, NEXT_STATE);
	-------------------------------------------------------------------------------
	
	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= NEXT_STATE;
	-------------------------------------------------------------------------------
        CONST_OUT <= CONST;
	
	-- DONE -----------------------------------------------------------------------	
	--CHK1 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (CONST = "111000") ELSE '0'; END GENERATE;
	--CHK2 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (CONST = "001101") ELSE '0'; END GENERATE;
	--CHK3 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (CONST = "011010") ELSE '0'; END GENERATE;
	--CHK4 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (CONST = "011010") ELSE '0'; END GENERATE;
	--CHK5 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (CONST = "000100") ELSE '0'; END GENERATE;
	--CHK6 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (CONST = "001010") ELSE '0'; END GENERATE;
	-------------------------------------------------------------------------------
	
END Mixed;

