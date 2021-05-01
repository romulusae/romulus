----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			KeyExpansion
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
ENTITY KeyExpansion_x4 IS
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_128; TS : TWEAK_SIZE := TWEAK_SIZE_3N);
	PORT ( --CLK			: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
			 --INIT			: IN	STD_LOGIC;
			 -- KEY PORTS ------------------------------------
          KEY			: IN  STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 1 - 64) DOWNTO 0);
        ROUND_KEY1	: OUT STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 64 - 1) DOWNTO 0);   
        ROUND_KEY2	: OUT STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 64 - 1) DOWNTO 0);   
        ROUND_KEY3	: OUT STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 64 - 1) DOWNTO 0);   
        ROUND_KEY4	: OUT STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 64 - 1) DOWNTO 0));
END KeyExpansion_x4;



-- ARCHITECTURE : MIXED
----------------------------------------------------------------------------------
ARCHITECTURE Mixed OF KeyExpansion_x4 IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	
	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CURRENT_KEY0, PERMUTED_KEY0, NEXT_KEY0	: STD_LOGIC_VECTOR((T - 64 - 1) DOWNTO 0);
        SIGNAL CURRENT_KEY1, PERMUTED_KEY1, NEXT_KEY1	: STD_LOGIC_VECTOR((T - 64 - 1) DOWNTO 0);
        SIGNAL CURRENT_KEY2, PERMUTED_KEY2, NEXT_KEY2	: STD_LOGIC_VECTOR((T - 64 - 1) DOWNTO 0);
        SIGNAL CURRENT_KEY3, PERMUTED_KEY3, NEXT_KEY3	: STD_LOGIC_VECTOR((T - 64 - 1) DOWNTO 0);

BEGIN

	-- REGISTER -------------------------------------------------------------------
	--R : ENTITY work.ScanFF
	--GENERIC MAP (SIZE => T)
	--PORT MAP (
	--	CLK 	=> CLK,
	--	SE		=> INIT,
	--	D		=> NEXT_KEY,
	--	DS		=> KEY,
	--	Q		=> CURRENT_KEY
	--);
  -------------------------------------------------------------------------------

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
  TK1 : IF TS = TWEAK_SIZE_1N OR TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE
    

    NEXT_KEY0((T - 64 - 1) DOWNTO (T - 1 * N)) <= x"0000000000000000"; 
          -- PERMUTATION -------------------------------------------------------------
          P1 : ENTITY work.HPermutation
            GENERIC MAP (BS => BS) PORT MAP (
            KEY ((T - 64 - 1) DOWNTO (T - 1 * N)), 
            PERMUTED_KEY1((T - 64 - 1) DOWNTO (T - 1 * N))
            ); 
		
          -- NO LFSR -----------------------------------------------------------------
    NEXT_KEY1((T - 64 - 1) DOWNTO (T - 1 * N)) <= PERMUTED_KEY1((T - 64 - 1) DOWNTO (T - 1 * N));

    NEXT_KEY2((T - 64 - 1) DOWNTO (T - 1 * N)) <= x"0000000000000000"; 

          -- PERMUTATION -------------------------------------------------------------
          P3 : ENTITY work.HPermutation
            GENERIC MAP (BS => BS) PORT MAP (
            NEXT_KEY1 ((T - 64 - 1) DOWNTO (T - 1 * N)), 
            PERMUTED_KEY3((T - 64 - 1) DOWNTO (T - 1 * N))
            ); 
		
		-- NO LFSR -----------------------------------------------------------------
		NEXT_KEY3((T - 64 - 1) DOWNTO (T - 1 * N)) <= PERMUTED_KEY3((T - 64 - 1) DOWNTO (T - 1 * N));
	          
	END GENERATE;
	-------------------------------------------------------------------------------
	
	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	TK2 : IF TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE 
	
		-- PERMUTATION -------------------------------------------------------------
		PP : ENTITY work.Permutation
		GENERIC MAP (BS => BS) PORT MAP (
			KEY ((T - 1 * N - 1) DOWNTO (T - 2 * N)), 
			PERMUTED_KEY0((T - 1 * N - 1) DOWNTO (T - 2 * N))
		); 
		-- PERMUTATION -------------------------------------------------------------
		PP1 : ENTITY work.Permutation
		GENERIC MAP (BS => BS) PORT MAP (
			NEXT_KEY0 ((T - 1 * N - 1) DOWNTO (T - 2 * N)), 
			PERMUTED_KEY1((T - 1 * N - 1) DOWNTO (T - 2 * N))
		); 
		-- PERMUTATION -------------------------------------------------------------
		PP2 : ENTITY work.Permutation
		GENERIC MAP (BS => BS) PORT MAP (
			NEXT_KEY1 ((T - 1 * N - 1) DOWNTO (T - 2 * N)), 
			PERMUTED_KEY2((T - 1 * N - 1) DOWNTO (T - 2 * N))
		); 
		-- PERMUTATION -------------------------------------------------------------
		PP3 : ENTITY work.Permutation
		GENERIC MAP (BS => BS) PORT MAP (
			NEXT_KEY2 ((T - 1 * N - 1) DOWNTO (T - 2 * N)), 
			PERMUTED_KEY3((T - 1 * N - 1) DOWNTO (T - 2 * N))
		); 
		
		-- LFSR --------------------------------------------------------------------
		LFSR2 : FOR I IN 0 TO 3 GENERATE
                  NEXT_KEY0((T + W * (I + 13) - 2 * N - 1) DOWNTO (T + W * (I + 12) - 2 * N)) <= PERMUTED_KEY0((T + W * (I + 13) - 2 * N - 2) DOWNTO (T + W * (I + 12) - 2 * N)) & (PERMUTED_KEY0(T + W * (I + 13) - 2 * N - 1) XOR PERMUTED_KEY0(T + W * (I + 13) - 2 * N - (W / 4) - 1));
                  NEXT_KEY1((T + W * (I + 13) - 2 * N - 1) DOWNTO (T + W * (I + 12) - 2 * N)) <= PERMUTED_KEY1((T + W * (I + 13) - 2 * N - 2) DOWNTO (T + W * (I + 12) - 2 * N)) & (PERMUTED_KEY1(T + W * (I + 13) - 2 * N - 1) XOR PERMUTED_KEY1(T + W * (I + 13) - 2 * N - (W / 4) - 1));
                  NEXT_KEY2((T + W * (I + 13) - 2 * N - 1) DOWNTO (T + W * (I + 12) - 2 * N)) <= PERMUTED_KEY2((T + W * (I + 13) - 2 * N - 2) DOWNTO (T + W * (I + 12) - 2 * N)) & (PERMUTED_KEY2(T + W * (I + 13) - 2 * N - 1) XOR PERMUTED_KEY2(T + W * (I + 13) - 2 * N - (W / 4) - 1));
                  NEXT_KEY3((T + W * (I + 13) - 2 * N - 1) DOWNTO (T + W * (I + 12) - 2 * N)) <= PERMUTED_KEY3((T + W * (I + 13) - 2 * N - 2) DOWNTO (T + W * (I + 12) - 2 * N)) & (PERMUTED_KEY3(T + W * (I + 13) - 2 * N - 1) XOR PERMUTED_KEY3(T + W * (I + 13) - 2 * N - (W / 4) - 1));
                  
                  NEXT_KEY0((T + W * (I +  9) - 2 * N - 1) DOWNTO (T + W * (I +  8) - 2 * N)) <= PERMUTED_KEY0((T + W * (I +  9) - 2 * N - 2) DOWNTO (T + W * (I +  8) - 2 * N)) & (PERMUTED_KEY0(T + W * (I +  9) - 2 * N - 1) XOR PERMUTED_KEY0(T + W * (I +  9) - 2 * N - (W / 4) - 1));
                  NEXT_KEY1((T + W * (I +  9) - 2 * N - 1) DOWNTO (T + W * (I +  8) - 2 * N)) <= PERMUTED_KEY1((T + W * (I +  9) - 2 * N - 2) DOWNTO (T + W * (I +  8) - 2 * N)) & (PERMUTED_KEY1(T + W * (I +  9) - 2 * N - 1) XOR PERMUTED_KEY1(T + W * (I +  9) - 2 * N - (W / 4) - 1));
                  NEXT_KEY2((T + W * (I +  9) - 2 * N - 1) DOWNTO (T + W * (I +  8) - 2 * N)) <= PERMUTED_KEY2((T + W * (I +  9) - 2 * N - 2) DOWNTO (T + W * (I +  8) - 2 * N)) & (PERMUTED_KEY2(T + W * (I +  9) - 2 * N - 1) XOR PERMUTED_KEY2(T + W * (I +  9) - 2 * N - (W / 4) - 1));
                  NEXT_KEY3((T + W * (I +  9) - 2 * N - 1) DOWNTO (T + W * (I +  8) - 2 * N)) <= PERMUTED_KEY3((T + W * (I +  9) - 2 * N - 2) DOWNTO (T + W * (I +  8) - 2 * N)) & (PERMUTED_KEY3(T + W * (I +  9) - 2 * N - 1) XOR PERMUTED_KEY3(T + W * (I +  9) - 2 * N - (W / 4) - 1));
                  
                  NEXT_KEY0((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N)) <= PERMUTED_KEY0((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N));
                  NEXT_KEY1((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N)) <= PERMUTED_KEY1((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N));
                  NEXT_KEY2((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N)) <= PERMUTED_KEY2((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N));
                  NEXT_KEY3((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N)) <= PERMUTED_KEY3((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N));
                  
                  NEXT_KEY0((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N)) <= PERMUTED_KEY0((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N));
                  NEXT_KEY1((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N)) <= PERMUTED_KEY1((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N));
                  NEXT_KEY2((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N)) <= PERMUTED_KEY2((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N));
                  NEXT_KEY3((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N)) <= PERMUTED_KEY3((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N));		
		END GENERATE;
		
	END GENERATE;
	-------------------------------------------------------------------------------
	
	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	TK3 : IF TS = TWEAK_SIZE_3N GENERATE 
	
          -- PERMUTATION -------------------------------------------------------------
          PP0 : ENTITY work.Permutation
            GENERIC MAP (BS => BS) PORT MAP (
              KEY ((T - 2 * N - 1) DOWNTO (T - 3 * N)),
              PERMUTED_KEY0((T - 2 * N - 1) DOWNTO (T - 3 * N))
          ); 
          -- PERMUTATION -------------------------------------------------------------
          PP1 : ENTITY work.Permutation
            GENERIC MAP (BS => BS) PORT MAP (
              NEXT_KEY0 ((T - 2 * N - 1) DOWNTO (T - 3 * N)),
              PERMUTED_KEY1((T - 2 * N - 1) DOWNTO (T - 3 * N))
          ); 
	-- PERMUTATION -------------------------------------------------------------
          PP2 : ENTITY work.Permutation
            GENERIC MAP (BS => BS) PORT MAP (
              NEXT_KEY1 ((T - 2 * N - 1) DOWNTO (T - 3 * N)),
              PERMUTED_KEY2((T - 2 * N - 1) DOWNTO (T - 3 * N))
          ); 
	-- PERMUTATION -------------------------------------------------------------
          PP3 : ENTITY work.Permutation
            GENERIC MAP (BS => BS) PORT MAP (
              NEXT_KEY2 ((T - 2 * N - 1) DOWNTO (T - 3 * N)),
              PERMUTED_KEY3((T - 2 * N - 1) DOWNTO (T - 3 * N))
          ); 
	
		-- LFSR --------------------------------------------------------------------
		LFSR3 : FOR I IN 0 TO 3 GENERATE
                  NEXT_KEY0((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N)) <= (PERMUTED_KEY0(T + W * (I + 12) - 3 * N) XOR PERMUTED_KEY0(T + W * (I + 13) - 3 * N - (W / 4))) & PERMUTED_KEY0((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N + 1));
                  NEXT_KEY1((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N)) <= (PERMUTED_KEY1(T + W * (I + 12) - 3 * N) XOR PERMUTED_KEY1(T + W * (I + 13) - 3 * N - (W / 4))) & PERMUTED_KEY1((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N + 1));
                  NEXT_KEY2((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N)) <= (PERMUTED_KEY2(T + W * (I + 12) - 3 * N) XOR PERMUTED_KEY2(T + W * (I + 13) - 3 * N - (W / 4))) & PERMUTED_KEY2((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N + 1));
                  NEXT_KEY3((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N)) <= (PERMUTED_KEY3(T + W * (I + 12) - 3 * N) XOR PERMUTED_KEY3(T + W * (I + 13) - 3 * N - (W / 4))) & PERMUTED_KEY3((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N + 1));
                  
                  NEXT_KEY0((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N)) <= (PERMUTED_KEY0(T + W * (I +  8) - 3 * N) XOR PERMUTED_KEY0(T + W * (I +  9) - 3 * N - (W / 4))) & PERMUTED_KEY0((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N + 1));
                  NEXT_KEY1((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N)) <= (PERMUTED_KEY1(T + W * (I +  8) - 3 * N) XOR PERMUTED_KEY1(T + W * (I +  9) - 3 * N - (W / 4))) & PERMUTED_KEY1((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N + 1));
                  NEXT_KEY2((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N)) <= (PERMUTED_KEY2(T + W * (I +  8) - 3 * N) XOR PERMUTED_KEY2(T + W * (I +  9) - 3 * N - (W / 4))) & PERMUTED_KEY2((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N + 1));
                  NEXT_KEY3((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N)) <= (PERMUTED_KEY3(T + W * (I +  8) - 3 * N) XOR PERMUTED_KEY3(T + W * (I +  9) - 3 * N - (W / 4))) & PERMUTED_KEY3((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N + 1));
                  
                  NEXT_KEY0((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N)) <= PERMUTED_KEY0((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N));
                  NEXT_KEY1((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N)) <= PERMUTED_KEY1((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N));
                  NEXT_KEY2((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N)) <= PERMUTED_KEY2((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N));
                  NEXT_KEY3((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N)) <= PERMUTED_KEY3((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N));
                  
                  NEXT_KEY0((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N)) <= PERMUTED_KEY0((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N));
                  NEXT_KEY1((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N)) <= PERMUTED_KEY1((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N));
                  NEXT_KEY2((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N)) <= PERMUTED_KEY2((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N));
                  NEXT_KEY3((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N)) <= PERMUTED_KEY3((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N));		
		END GENERATE;
		
	END GENERATE;
	-------------------------------------------------------------------------------
	
    -- KEY OUTPUT -----------------------------------------------------------------
    ROUND_KEY1 <= NEXT_KEY0;
    ROUND_KEY2 <= NEXT_KEY1;
    ROUND_KEY3 <= NEXT_KEY2;
    ROUND_KEY4 <= NEXT_KEY3;
    -------------------------------------------------------------------------------
	
END Mixed;

