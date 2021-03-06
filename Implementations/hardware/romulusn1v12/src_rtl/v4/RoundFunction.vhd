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
			 ROUND_KEY2		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
          ROUND_KEY3		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_KEY4		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
          ROUND_KEY5		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_KEY6		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
          ROUND_KEY7		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_IN		: IN	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS) 	  - 1) DOWNTO 0);
			 ROUND_OUT		: OUT	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)	  - 1) DOWNTO 0);
          CONST0 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
          CONST1 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
			 CONST2 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
          CONST3 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
          CONST4 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
          CONST5 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
			 CONST6 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0);
          CONST7 : in STD_LOGIC_VECTOR( 		5  DOWNTO 0));
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
   SIGNAL CURRENT_STATE2, NEXT_STATE2, KEY_ADDITION2, CONST_ADDITION2, SUBSTITUTION2, SHIFTROWS2    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
   SIGNAL CURRENT_STATE3, NEXT_STATE3, KEY_ADDITION3, CONST_ADDITION3, SUBSTITUTION3, SHIFTROWS3    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
   SIGNAL CURRENT_STATE4, NEXT_STATE4, KEY_ADDITION4, CONST_ADDITION4, SUBSTITUTION4, SHIFTROWS4    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
   SIGNAL CURRENT_STATE5, NEXT_STATE5, KEY_ADDITION5, CONST_ADDITION5, SUBSTITUTION5, SHIFTROWS5    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
   SIGNAL CURRENT_STATE6, NEXT_STATE6, KEY_ADDITION6, CONST_ADDITION6, SUBSTITUTION6, SHIFTROWS6    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
   SIGNAL CURRENT_STATE7, NEXT_STATE7, KEY_ADDITION7, CONST_ADDITION7, SUBSTITUTION7, SHIFTROWS7    : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);

BEGIN

		
	-- S-BOX ----------------------------------------------------------------------
	GEN : FOR I IN 0 TO 15 GENERATE
          S0 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (ROUND_IN((W * (I + 1) - 1) DOWNTO (W * I)),    SUBSTITUTION0((W * (I + 1) - 1) DOWNTO (W * I)));
          S1 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE0((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION1((W * (I + 1) - 1) DOWNTO (W * I)));
			 S2 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE1((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION2((W * (I + 1) - 1) DOWNTO (W * I)));
          S3 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE2((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION3((W * (I + 1) - 1) DOWNTO (W * I)));
	       S4 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE3((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION4((W * (I + 1) - 1) DOWNTO (W * I)));
          S5 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE4((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION5((W * (I + 1) - 1) DOWNTO (W * I)));
			 S6 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE5((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION6((W * (I + 1) - 1) DOWNTO (W * I)));
          S7 : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (NEXT_STATE6((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTION7((W * (I + 1) - 1) DOWNTO (W * I)));
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
		CONST_ADDITION2(63 DOWNTO 60) <= SUBSTITUTION2(63 DOWNTO 60) XOR CONST2(3 DOWNTO 0);
		CONST_ADDITION2(59 DOWNTO 46) <= SUBSTITUTION2(59 DOWNTO 46);
		CONST_ADDITION2(45 DOWNTO 44) <= SUBSTITUTION2(45 DOWNTO 44) XOR CONST2(5 DOWNTO 4);
		CONST_ADDITION2(43 DOWNTO 30) <= SUBSTITUTION2(43 DOWNTO 30);
		CONST_ADDITION2(29) 	     <= NOT(SUBSTITUTION2(29));
		CONST_ADDITION2(28 DOWNTO  0) <= SUBSTITUTION2(28 DOWNTO  0);
		CONST_ADDITION3(63 DOWNTO 60) <= SUBSTITUTION3(63 DOWNTO 60) XOR CONST3(3 DOWNTO 0);
		CONST_ADDITION3(59 DOWNTO 46) <= SUBSTITUTION3(59 DOWNTO 46);
		CONST_ADDITION3(45 DOWNTO 44) <= SUBSTITUTION3(45 DOWNTO 44) XOR CONST3(5 DOWNTO 4);
		CONST_ADDITION3(43 DOWNTO 30) <= SUBSTITUTION3(43 DOWNTO 30);
		CONST_ADDITION3(29)	     <= NOT(SUBSTITUTION3(29));
		CONST_ADDITION3(28 DOWNTO  0) <= SUBSTITUTION3(28 DOWNTO  0);
		CONST_ADDITION4(63 DOWNTO 60) <= SUBSTITUTION4(63 DOWNTO 60) XOR CONST4(3 DOWNTO 0);
		CONST_ADDITION4(59 DOWNTO 46) <= SUBSTITUTION4(59 DOWNTO 46);
		CONST_ADDITION4(45 DOWNTO 44) <= SUBSTITUTION4(45 DOWNTO 44) XOR CONST4(5 DOWNTO 4);
		CONST_ADDITION4(43 DOWNTO 30) <= SUBSTITUTION4(43 DOWNTO 30);
		CONST_ADDITION4(29) 	     <= NOT(SUBSTITUTION4(29));
		CONST_ADDITION4(28 DOWNTO  0) <= SUBSTITUTION4(28 DOWNTO  0);
		CONST_ADDITION5(63 DOWNTO 60) <= SUBSTITUTION5(63 DOWNTO 60) XOR CONST5(3 DOWNTO 0);
		CONST_ADDITION5(59 DOWNTO 46) <= SUBSTITUTION5(59 DOWNTO 46);
		CONST_ADDITION5(45 DOWNTO 44) <= SUBSTITUTION5(45 DOWNTO 44) XOR CONST5(5 DOWNTO 4);
		CONST_ADDITION5(43 DOWNTO 30) <= SUBSTITUTION5(43 DOWNTO 30);
		CONST_ADDITION5(29)	     <= NOT(SUBSTITUTION5(29));
		CONST_ADDITION5(28 DOWNTO  0) <= SUBSTITUTION5(28 DOWNTO  0);
		CONST_ADDITION6(63 DOWNTO 60) <= SUBSTITUTION6(63 DOWNTO 60) XOR CONST6(3 DOWNTO 0);
		CONST_ADDITION6(59 DOWNTO 46) <= SUBSTITUTION6(59 DOWNTO 46);
		CONST_ADDITION6(45 DOWNTO 44) <= SUBSTITUTION6(45 DOWNTO 44) XOR CONST6(5 DOWNTO 4);
		CONST_ADDITION6(43 DOWNTO 30) <= SUBSTITUTION6(43 DOWNTO 30);
		CONST_ADDITION6(29) 	     <= NOT(SUBSTITUTION6(29));
		CONST_ADDITION6(28 DOWNTO  0) <= SUBSTITUTION6(28 DOWNTO  0);
		CONST_ADDITION7(63 DOWNTO 60) <= SUBSTITUTION7(63 DOWNTO 60) XOR CONST7(3 DOWNTO 0);
		CONST_ADDITION7(59 DOWNTO 46) <= SUBSTITUTION7(59 DOWNTO 46);
		CONST_ADDITION7(45 DOWNTO 44) <= SUBSTITUTION7(45 DOWNTO 44) XOR CONST7(5 DOWNTO 4);
		CONST_ADDITION7(43 DOWNTO 30) <= SUBSTITUTION7(43 DOWNTO 30);
		CONST_ADDITION7(29)	     <= NOT(SUBSTITUTION7(29));
		CONST_ADDITION7(28 DOWNTO  0) <= SUBSTITUTION7(28 DOWNTO  0);
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
	  CONST_ADDITION2(127 DOWNTO 124) <= SUBSTITUTION2(127 DOWNTO 124);               
     CONST_ADDITION2(123 DOWNTO 120) <= SUBSTITUTION2(123 DOWNTO 120) XOR CONST2(3 DOWNTO 0);
     CONST_ADDITION2(119 DOWNTO  90) <= SUBSTITUTION2(119 DOWNTO  90);
     CONST_ADDITION2( 89 DOWNTO  88) <= SUBSTITUTION2( 89 DOWNTO  88) XOR CONST2(5 DOWNTO 4);
     CONST_ADDITION2( 87 DOWNTO  58) <= SUBSTITUTION2( 87 DOWNTO  58);
     CONST_ADDITION2(57) 	      <= NOT(SUBSTITUTION2(57));
     CONST_ADDITION2( 56 DOWNTO   0) <= SUBSTITUTION2( 56 DOWNTO   0);	
     CONST_ADDITION3(127 DOWNTO 124) <= SUBSTITUTION3(127 DOWNTO 124);		  
	  CONST_ADDITION3(123 DOWNTO 120) <= SUBSTITUTION3(123 DOWNTO 120) XOR CONST3(3 DOWNTO 0);
	  CONST_ADDITION3(119 DOWNTO  90) <= SUBSTITUTION3(119 DOWNTO  90);
	  CONST_ADDITION3( 89 DOWNTO  88) <= SUBSTITUTION3( 89 DOWNTO  88) XOR CONST3(5 DOWNTO 4);
	  CONST_ADDITION3( 87 DOWNTO  58) <= SUBSTITUTION3( 87 DOWNTO  58);
	  CONST_ADDITION3(57)	      <= NOT(SUBSTITUTION3(57));
	  CONST_ADDITION3( 56 DOWNTO   0) <= SUBSTITUTION3( 56 DOWNTO	0);	
	  CONST_ADDITION4(127 DOWNTO 124) <= SUBSTITUTION4(127 DOWNTO 124);               
     CONST_ADDITION4(123 DOWNTO 120) <= SUBSTITUTION4(123 DOWNTO 120) XOR CONST4(3 DOWNTO 0);
     CONST_ADDITION4(119 DOWNTO  90) <= SUBSTITUTION4(119 DOWNTO  90);
     CONST_ADDITION4( 89 DOWNTO  88) <= SUBSTITUTION4( 89 DOWNTO  88) XOR CONST4(5 DOWNTO 4);
     CONST_ADDITION4( 87 DOWNTO  58) <= SUBSTITUTION4( 87 DOWNTO  58);
     CONST_ADDITION4(57) 	      <= NOT(SUBSTITUTION4(57));
     CONST_ADDITION4( 56 DOWNTO   0) <= SUBSTITUTION4( 56 DOWNTO   0);	
     CONST_ADDITION5(127 DOWNTO 124) <= SUBSTITUTION5(127 DOWNTO 124);		  
	  CONST_ADDITION5(123 DOWNTO 120) <= SUBSTITUTION5(123 DOWNTO 120) XOR CONST5(3 DOWNTO 0);
	  CONST_ADDITION5(119 DOWNTO  90) <= SUBSTITUTION5(119 DOWNTO  90);
	  CONST_ADDITION5( 89 DOWNTO  88) <= SUBSTITUTION5( 89 DOWNTO  88) XOR CONST5(5 DOWNTO 4);
	  CONST_ADDITION5( 87 DOWNTO  58) <= SUBSTITUTION5( 87 DOWNTO  58);
	  CONST_ADDITION5(57)	      <= NOT(SUBSTITUTION5(57));
	  CONST_ADDITION5( 56 DOWNTO   0) <= SUBSTITUTION5( 56 DOWNTO	0);	
	  CONST_ADDITION6(127 DOWNTO 124) <= SUBSTITUTION6(127 DOWNTO 124);               
     CONST_ADDITION6(123 DOWNTO 120) <= SUBSTITUTION6(123 DOWNTO 120) XOR CONST6(3 DOWNTO 0);
     CONST_ADDITION6(119 DOWNTO  90) <= SUBSTITUTION6(119 DOWNTO  90);
     CONST_ADDITION6( 89 DOWNTO  88) <= SUBSTITUTION6( 89 DOWNTO  88) XOR CONST6(5 DOWNTO 4);
     CONST_ADDITION6( 87 DOWNTO  58) <= SUBSTITUTION6( 87 DOWNTO  58);
     CONST_ADDITION6(57) 	      <= NOT(SUBSTITUTION6(57));
     CONST_ADDITION6( 56 DOWNTO   0) <= SUBSTITUTION6( 56 DOWNTO   0);	
     CONST_ADDITION7(127 DOWNTO 124) <= SUBSTITUTION7(127 DOWNTO 124);		  
	  CONST_ADDITION7(123 DOWNTO 120) <= SUBSTITUTION7(123 DOWNTO 120) XOR CONST7(3 DOWNTO 0);
	  CONST_ADDITION7(119 DOWNTO  90) <= SUBSTITUTION7(119 DOWNTO  90);
	  CONST_ADDITION7( 89 DOWNTO  88) <= SUBSTITUTION7( 89 DOWNTO  88) XOR CONST7(5 DOWNTO 4);
	  CONST_ADDITION7( 87 DOWNTO  58) <= SUBSTITUTION7( 87 DOWNTO  58);
	  CONST_ADDITION7(57)	      <= NOT(SUBSTITUTION7(57));
	  CONST_ADDITION7( 56 DOWNTO   0) <= SUBSTITUTION7( 56 DOWNTO	0);	
	END GENERATE;
	-------------------------------------------------------------------------------

	-- SUBKEY ADDITION ------------------------------------------------------------
	T1N : IF TS = TWEAK_SIZE_1N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION2((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION2((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY2((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY2((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION3((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION3((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY3((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY3((12 * W - 1) DOWNTO ( 8 * W));
	       KEY_ADDITION4((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION4((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY4((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY4((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION5((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION5((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY5((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY5((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION6((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION6((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY6((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY6((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION7((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION7((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY7((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY7((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	T2N : IF TS = TWEAK_SIZE_2N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION2((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION2((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY2((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY2((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY2((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY2((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION3((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION3((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY3((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY3((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY3((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY3((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION4((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION4((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY4((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY4((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY4((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY4((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION5((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION5((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY5((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY5((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY5((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY5((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION6((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION6((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY6((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY6((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY6((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY6((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION7((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION7((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY7((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY7((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY7((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY7((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	T3N : IF TS = TWEAK_SIZE_3N GENERATE
          KEY_ADDITION0((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION0((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY0((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY0((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY0((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION0((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY0((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY0((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY0((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION1((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION1((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY1((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY1((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY1((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION1((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY1((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY1((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY1((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION2((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION2((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY2((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY2((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY2((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION2((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY2((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY2((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY2((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION3((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION3((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY3((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY3((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY3((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION3((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY3((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY3((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY3((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION4((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION4((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY4((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY4((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY4((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION4((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY4((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY4((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY4((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION5((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION5((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY5((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY5((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY5((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION5((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY5((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY5((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY5((12 * W - 1) DOWNTO ( 8 * W));
			 KEY_ADDITION6((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION6((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY6((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY6((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY6((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION6((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY6((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY6((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY6((12 * W - 1) DOWNTO ( 8 * W));
          KEY_ADDITION7((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION7((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY7((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY7((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY7((16 * W - 1) DOWNTO (12 * W));
          KEY_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION7((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY7((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY7((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY7((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;
	
	KEY_ADDITION0(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION0(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION0(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION0(( 4 * W - 1) DOWNTO ( 0 * W));
   KEY_ADDITION1(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION1(( 8 * W - 1) DOWNTO ( 4 * W));
   KEY_ADDITION1(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION1(( 4 * W - 1) DOWNTO ( 0 * W));
	KEY_ADDITION2(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION2(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION2(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION2(( 4 * W - 1) DOWNTO ( 0 * W));
   KEY_ADDITION3(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION3(( 8 * W - 1) DOWNTO ( 4 * W));
   KEY_ADDITION3(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION3(( 4 * W - 1) DOWNTO ( 0 * W));
	KEY_ADDITION4(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION4(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION4(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION4(( 4 * W - 1) DOWNTO ( 0 * W));
   KEY_ADDITION5(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION5(( 8 * W - 1) DOWNTO ( 4 * W));
   KEY_ADDITION5(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION5(( 4 * W - 1) DOWNTO ( 0 * W));
	KEY_ADDITION6(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION6(( 8 * W - 1) DOWNTO ( 4 * W));
	KEY_ADDITION6(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION6(( 4 * W - 1) DOWNTO ( 0 * W));
   KEY_ADDITION7(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION7(( 8 * W - 1) DOWNTO ( 4 * W));
   KEY_ADDITION7(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION7(( 4 * W - 1) DOWNTO ( 0 * W));
	-------------------------------------------------------------------------------
	
	-- SHIFT ROWS -----------------------------------------------------------------
	SR0 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION0, SHIFTROWS0);
   SR1 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION1, SHIFTROWS1);
	SR2 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION2, SHIFTROWS2);
   SR3 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION3, SHIFTROWS3);
	SR4 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION4, SHIFTROWS4);
   SR5 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION5, SHIFTROWS5);
	SR6 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION6, SHIFTROWS6);
   SR7 : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (KEY_ADDITION7, SHIFTROWS7);
	-------------------------------------------------------------------------------
	
	-- MIX COLUMNS ----------------------------------------------------------------
	MC0 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS0, NEXT_STATE0);
   MC1 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS1, NEXT_STATE1);
	MC2 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS2, NEXT_STATE2);
   MC3 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS3, NEXT_STATE3);
	MC4 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS4, NEXT_STATE4);
   MC5 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS5, NEXT_STATE5);
	MC6 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS6, NEXT_STATE6);
   MC7 : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS7, NEXT_STATE7);
	-------------------------------------------------------------------------------
	
	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= NEXT_STATE7;
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

