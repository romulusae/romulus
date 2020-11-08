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
USE IEEE.std_logic_unsigned.ALL;
USE WORK.SKINNYPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY SBox_LUT IS	
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_128);
	PORT ( X : IN	STD_LOGIC_VECTOR (7 DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR (7 DOWNTO 0));
END SBox_LUT;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF SBox_LUT IS

	-- SIGNALS --------------------------------------------------------------------
	type rom_type is array (0 to 255) of std_logic_vector (7 downto 0);
	SIGNAL lookup : rom_type  := (X"65",X"4c",X"6a",X"42",X"4b",X"63",X"43",X"6b",X"55",X"75",X"5a",X"7a",X"53",X"73",X"5b",X"7b",
X"35",X"8c",X"3a",X"81",X"89",X"33",X"80",X"3b",X"95",X"25",X"98",X"2a",X"90",X"23",X"99",X"2b",
X"e5",X"cc",X"e8",X"c1",X"c9",X"e0",X"c0",X"e9",X"d5",X"f5",X"d8",X"f8",X"d0",X"f0",X"d9",X"f9",
X"a5",X"1c",X"a8",X"12",X"1b",X"a0",X"13",X"a9",X"05",X"b5",X"0a",X"b8",X"03",X"b0",X"0b",X"b9",
X"32",X"88",X"3c",X"85",X"8d",X"34",X"84",X"3d",X"91",X"22",X"9c",X"2c",X"94",X"24",X"9d",X"2d",
X"62",X"4a",X"6c",X"45",X"4d",X"64",X"44",X"6d",X"52",X"72",X"5c",X"7c",X"54",X"74",X"5d",X"7d",
X"a1",X"1a",X"ac",X"15",X"1d",X"a4",X"14",X"ad",X"02",X"b1",X"0c",X"bc",X"04",X"b4",X"0d",X"bd",
X"e1",X"c8",X"ec",X"c5",X"cd",X"e4",X"c4",X"ed",X"d1",X"f1",X"dc",X"fc",X"d4",X"f4",X"dd",X"fd",
X"36",X"8e",X"38",X"82",X"8b",X"30",X"83",X"39",X"96",X"26",X"9a",X"28",X"93",X"20",X"9b",X"29",
X"66",X"4e",X"68",X"41",X"49",X"60",X"40",X"69",X"56",X"76",X"58",X"78",X"50",X"70",X"59",X"79",
X"a6",X"1e",X"aa",X"11",X"19",X"a3",X"10",X"ab",X"06",X"b6",X"08",X"ba",X"00",X"b3",X"09",X"bb",
X"e6",X"ce",X"ea",X"c2",X"cb",X"e3",X"c3",X"eb",X"d6",X"f6",X"da",X"fa",X"d3",X"f3",X"db",X"fb",
X"31",X"8a",X"3e",X"86",X"8f",X"37",X"87",X"3f",X"92",X"21",X"9e",X"2e",X"97",X"27",X"9f",X"2f",
X"61",X"48",X"6e",X"46",X"4f",X"67",X"47",X"6f",X"51",X"71",X"5e",X"7e",X"57",X"77",X"5f",X"7f",
X"a2",X"18",X"ae",X"16",X"1f",X"a7",X"17",X"af",X"01",X"b2",X"0e",X"be",X"07",X"b7",X"0f",X"bf",
X"e2",X"ca",X"ee",X"c6",X"cf",X"e7",X"c7",X"ef",X"d2",X"f2",X"de",X"fe",X"d7",X"f7",X"df",X"ff");

-- DATAFLOW
----------------------------------------------------------------------------------
BEGIN

	Y <= lookup(conv_integer(X));
	
END Dataflow;

