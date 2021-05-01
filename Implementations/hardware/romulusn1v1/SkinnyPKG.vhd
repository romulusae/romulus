----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2016 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-Universitaet Bochum, Chair for Embedded Security
-- AUTHOR:					Pascal Sasdrich
--
-- CREATE DATA:			17/11/2016
-- MODULE NAME:			SkinnyPKG
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

PACKAGE SKINNYPKG is

	-- DEFINE BLOCKSIZE -----------------------------------------------------------
	TYPE BLOCK_SIZE IS (BLOCK_SIZE_64, BLOCK_SIZE_128);
	-------------------------------------------------------------------------------
		
	-- DEFINE TWEAKSIZE -----------------------------------------------------------	
	TYPE TWEAK_SIZE IS (TWEAK_SIZE_1N, TWEAK_SIZE_2N, TWEAK_SIZE_3N);
	-------------------------------------------------------------------------------
		
	--DEFINE FUNCTIONS ------------------------------------------------------------
	FUNCTION GET_WORD_SIZE  (BS : BLOCK_SIZE) RETURN INTEGER;		
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAK_FACT (TS : TWEAK_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAK_SIZE (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER;
	-------------------------------------------------------------------------------
	
END SKINNYPKG;

PACKAGE BODY SKINNYPKG IS

	-- FUNCTION: RETURN WORD SIZE -------------------------------------------------
	FUNCTION GET_WORD_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 4;
			ELSE
				RETURN 8;
			END IF;
	END GET_WORD_SIZE;
	-------------------------------------------------------------------------------
	
	-- FUNCTION: RETURN BLOCK SIZE ------------------------------------------------
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 64;
			ELSE
				RETURN 128;
			END IF;
	END GET_BLOCK_SIZE;
	-------------------------------------------------------------------------------
	
	-- FUNCTION: RETURN TWEAK FACTOR ----------------------------------------------
	FUNCTION GET_TWEAK_FACT (TS : TWEAK_SIZE) RETURN INTEGER IS
	BEGIN
			IF    TS = TWEAK_SIZE_1N THEN
				RETURN 1;
			ELSIF TS = TWEAK_SIZE_2N THEN
				RETURN 2;
			ELSE
				RETURN 3;
			END IF;
	END GET_TWEAK_FACT;
	-------------------------------------------------------------------------------
	
	-- FUNCTION: RETURN TWEAK SIZE ------------------------------------------------
	FUNCTION GET_TWEAK_SIZE (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER IS
	BEGIN
			RETURN GET_BLOCK_SIZE(BS) * GET_TWEAK_FACT(TS);
	END GET_TWEAK_SIZE;
	-------------------------------------------------------------------------------
	
	
END SKINNYPKG;