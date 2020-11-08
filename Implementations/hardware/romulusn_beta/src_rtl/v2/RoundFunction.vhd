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
	PORT (  -- KEY PORT -------------------------------------
			 ROUND_KEY0		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
                         ROUND_KEY1		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_IN		: IN	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS) 	  - 1) DOWNTO 0);
			 ROUND_OUT		: OUT	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)	  - 1) DOWNTO 0);
                         CONST0 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
                         CONST1 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0));
END RoundFunction;



-- ARCHITECTURE : MIXED
----------------------------------------------------------------------------------
ARCHITECTURE Mixed OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	
	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CURRENT_STATE0, NEXT_STATE0, KEY_ADDITION0, CONST_ADDITION0, SUBSTITUTION0, SHIFTROWS0    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
        SIGNAL CURRENT_STATE1, NEXT_STATE1, KEY_ADDITION1, CONST_ADDITION1, SUBSTITUTION1, SHIFTROWS1    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);

BEGIN

		
	-- S-BOX ----------------------------------------------------------------------
	GEN : FOR I IN 0 TO 15 GENERATE
          S0 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (ROUND_IN((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION0((W * (I + 1) - 1) DOWNTO (W * I)));
          S1 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE0((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION1((W * (I + 1) - 1) DOWNTO (W * I)));
	END GENERATE;
	-------------------------------------------------------------------------------

	-- CONSTANT ADDITION ----------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		CONST_ADDITION0(63 DOWNTO 60) <= SUBSTITUTION0(63 DOWNTO 60) XOR CONST0(3 DOWNTO 0);
		CONST_ADDITION0(59 DOWNTO 46) <= SUBSTITUTION0(59 DOWNTO 46);
		CONST_ADDITION0(45 DOWNTO 44) <= SUBSTITUTION0(45 DOWNTO 44) XOR CONST0(5 DOWNTO 4);
		CONST_ADDITION0(43 DOWNTO 30) <= SUBSTITUTION0(43 DOWNTO 30);
		CONST_ADDITION0(29) 	     <= NOT(SUBSTITUTION0(29));
		CONST_ADDITION0(28 DOWNTO  0) <= SUBSTITUTION0(28 DOWNTO  0);
		CONST_ADDITION1(63 DOWNTO 60) <= SUBSTITUTION1(63 DOWNTO 60) XOR CONST1(3 DOWNTO 0);
		CONST_ADDITION1(59 DOWNTO 46) <= SUBSTITUTION1(59 DOWNTO 46);
		CONST_ADDITION1(45 DOWNTO 44) <= SUBSTITUTION1(45 DOWNTO 44) XOR CONST1(5 DOWNTO 4);
		CONST_ADDITION1(43 DOWNTO 30) <= SUBSTITUTION1(43 DOWNTO 30);
		CONST_ADDITION1(29)	     <= NOT(SUBSTITUTION1(29));
		CONST_ADDITION1(28 DOWNTO  0) <= SUBSTITUTION1(28 DOWNTO  0);
	END GENERATE;
	
	N128 : IF BS = BLOCK_SIZE_128 GENERATE
          CONST_ADDITION0(127 DOWNTO 124) <= SUBSTITUTION0(127 DOWNTO 124);               
          CONST_ADDITION0(123 DOWNTO 120) <= SUBSTITUTION0(123 DOWNTO 120) XOR CONST0(3 DOWNTO 0);
          CONST_ADDITION0(119 DOWNTO  90) <= SUBSTITUTION0(119 DOWNTO  90);
          CONST_ADDITION0( 89 DOWNTO  88) <= SUBSTITUTION0( 89 DOWNTO  88) XOR CONST0(5 DOWNTO 4);
          CONST_ADDITION0( 87 DOWNTO  58) <= SUBSTITUTION0( 87 DOWNTO  58);
          CONST_ADDITION0(57) 	      <= NOT(SUBSTITUTION0(57));
          CONST_ADDITION0( 56 DOWNTO   0) <= SUBSTITUTION0( 56 DOWNTO   0);	
          CONST_ADDITION1(127 DOWNTO 124) <= SUBSTITUTION1(127 DOWNTO 124);		  
	  CONST_ADDITION1(123 DOWNTO 120) <= SUBSTITUTION1(123 DOWNTO 120) XOR CONST1(3 DOWNTO 0);
	  CONST_ADDITION1(119 DOWNTO  90) <= SUBSTITUTION1(119 DOWNTO  90);
	  CONST_ADDITION1( 89 DOWNTO  88) <= SUBSTITUTION1( 89 DOWNTO  88) XOR CONST1(5 DOWNTO 4);
	  CONST_ADDITION1( 87 DOWNTO  58) <= SUBSTITUTION1( 87 DOWNTO  58);
	  CONST_ADDITION1(57)	      <= NOT(SUBSTITUTION1(57));
	  CONST_ADDITION1( 56 DOWNTO   0) <= SUBSTITUTION1( 56 DOWNTO	0);	
	END GENERATE;
	-------------------------------------------------------------------------------

	-- SUBKEY ADDITION ------------------------------------------------------------
	T1N : IF TS = TWEAK_SIZE_1N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	T2N : IF TS = TWEAK_SIZE_2N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	T3N : IF TS = TWEAK_SIZE_3N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY0((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY1((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY0((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY1((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	KEY_ADDITION0(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION0(( 8 * W - 1) DOWNTO ( 4 * W));
        KEY_ADDITION1(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION1(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION0(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION0(( 4 * W - 1) DOWNTO ( 0 * W));
        KEY_ADDITION1(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION1(( 4 * W - 1) DOWNTO ( 0 * W));
	-------------------------------------------------------------------------------
	
	-- SHIFT ROWS -----------------------------------------------------------------
	SR0 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION0, SHIFTROWS0);
        SR1 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION1, SHIFTROWS1);
	-------------------------------------------------------------------------------
	
	-- MIX COLUMNS ----------------------------------------------------------------
	MC0 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS0, NEXT_STATE0);
        MC1 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS1, NEXT_STATE1);
	-------------------------------------------------------------------------------
	
	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= NEXT_STATE1;
	-------------------------------------------------------------------------------
	
	-- DONE -----------------------------------------------------------------------	
	--CHK1 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (CONST = "111000") ELSE '0'; END GENERATE;
	--CHK2 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (CONST = "001101") ELSE '0'; END GENERATE;
	--CHK3 : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (CONST = "011010") ELSE '0'; END GENERATE;
	--CHK4 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (CONST = "011010") ELSE '0'; END GENERATE;
	--CHK5 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (CONST = "000100") ELSE '0'; END GENERATE;
	--CHK6 : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (CONST = "001010") ELSE '0'; END GENERATE;
	-------------------------------------------------------------------------------
	
END Mixed;

