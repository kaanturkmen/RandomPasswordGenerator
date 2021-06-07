----------------------------------------------------------------------------------
-- University: Koc University
-- Students: Kaan Turkmen - Can Usluel
-- 
-- Create Date:    12:45:10 05/13/2021 
-- Design Name: FPGA Design
-- Module Name:    RPGCode - Behavioral 
-- Project Name: RandomPasswordGenerator
-- Target Devices: Prometheus FPGA
-- Tool versions: 
-- Description: Creates a random password sequence according to the user inputs.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RPGCode is
    Port ( MCLK : in  STD_LOGIC;
			  BUTTON : in STD_LOGIC;
			  passwordMode : in STD_LOGIC_VECTOR(2 downto 0) := "000";
           SegmentBlock : out  STD_LOGIC_VECTOR(7 downto 0);
           SevenSegmentDisplay : out  STD_LOGIC_VECTOR(6 downto 0));
end RPGCode;

architecture Behavioral of RPGCode is

signal RightToLeftLedDisplay: STD_LOGIC_VECTOR(31 downto 0);
signal clkRandom: STD_LOGIC_VECTOR(31 downto 0);
signal MXSelect: STD_LOGIC_VECTOR(2 downto 0);
signal DigitToLed: STD_LOGIC_VECTOR(3 downto 0);
signal aen: STD_LOGIC_VECTOR(7 downto 0);
signal DividedClock: STD_LOGIC_VECTOR(25 downto 0);

-- Two arrays are defined to store required numbers / characters.
-- They will be used to get random element using indexing.

type vectorArrayNumeric is array (0 to 31) of std_logic_vector(3 downto 0);
signal onlyNumeric: vectorArrayNumeric;

type vectorArrayLetters is array (0 to 31) of std_logic_vector(3 downto 0);
signal onlyLetters: vectorArrayLetters;

begin

-- We have defined FPS of the display using parsing (We did not use specific FPS rate).
MXSelect <= DividedClock(19 downto 17);

-- Setting all segments closed at the first place.
aen <= "11111111";

-- ** The reason there is more indexing than the number counts. ** --

-- Since VHDL can divide non-constant variables only with 2's powers,
-- we have defined 32 numeric values which increases 2 number's selection chance.
-- this increse can be reduced proportionaly if we increase the number of definitions
-- for example, if we define 1024 numeric values, the chance would be reduced 103/1024 instead of 4/32 for only numeric  

-- Filling onlyNumeric array indices with the numbers.

onlyNumeric(0) <= "0000";
onlyNumeric(1) <= "0001";
onlyNumeric(2) <= "0010";
onlyNumeric(3) <= "0011";
onlyNumeric(4) <= "0100";
onlyNumeric(5) <= "0101";
onlyNumeric(6) <= "0110";
onlyNumeric(7) <= "0111";
onlyNumeric(8) <= "1000";
onlyNumeric(9) <= "1001";
onlyNumeric(10) <= "0000";
onlyNumeric(11) <= "0001";
onlyNumeric(12) <= "0010";
onlyNumeric(13) <= "0011";
onlyNumeric(14) <= "0100";
onlyNumeric(15) <= "0101";
onlyNumeric(16) <= "0110";
onlyNumeric(17) <= "0111";
onlyNumeric(18) <= "1000";
onlyNumeric(19) <= "1001";
onlyNumeric(20) <= "0000";
onlyNumeric(21) <= "0001";
onlyNumeric(22) <= "0010";
onlyNumeric(23) <= "0011";
onlyNumeric(24) <= "0100";
onlyNumeric(25) <= "0101";
onlyNumeric(26) <= "0110";
onlyNumeric(27) <= "0111";
onlyNumeric(28) <= "1000";
onlyNumeric(29) <= "1001";
onlyNumeric(30) <= "1001";
onlyNumeric(31) <= "0111";

-- Filling onlyLetters array indices with the letters.

onlyLetters(0) <= "1010";
onlyLetters(1) <= "1011";
onlyLetters(2) <= "1100";
onlyLetters(3) <= "1101";
onlyLetters(4) <= "1110";
onlyLetters(5) <= "1111";
onlyLetters(6) <= "1010";
onlyLetters(7) <= "1011";
onlyLetters(8) <= "1100";
onlyLetters(9) <= "1101";
onlyLetters(10) <= "1110";
onlyLetters(11) <= "1111";
onlyLetters(12) <= "1010";
onlyLetters(13) <= "1011";
onlyLetters(14) <= "1100";
onlyLetters(15) <= "1101";
onlyLetters(16) <= "1110";
onlyLetters(17) <= "1111";
onlyLetters(18) <= "1010";
onlyLetters(19) <= "1011";
onlyLetters(20) <= "1100";
onlyLetters(21) <= "1101";
onlyLetters(22) <= "1110";
onlyLetters(23) <= "1111";
onlyLetters(24) <= "1010";
onlyLetters(25) <= "1011";
onlyLetters(26) <= "1100";
onlyLetters(27) <= "1101";
onlyLetters(28) <= "1110";
onlyLetters(29) <= "1111";
onlyLetters(30) <= "1111";
onlyLetters(31) <= "1110";

process(MCLK)

-- Algorithm uses clock ticks to determine the random index.
-- The reason why we have two different cycles (maxCycle1 and maxCycle2) is 
-- using one cycle will not be a random, since going most significant bit
-- is not changing as fast as the least significant bit, we will be produce
-- close numbers on each press. Thats why we are using two cycles and their
-- least significant bits.

variable maxCycle1 : INTEGER range 0 to 1073741823;
variable maxCycle2 : INTEGER range 2147483646 downto 1073741823;

-- Counter itself changes overtime, saved versions will freeze when user presses the button.
-- It is done to freeze the seen output as the same until the button is pressed again.

variable onlyNumericCounter : INTEGER range 0 to 173741823;
variable onlyNumericCounterSaved : INTEGER range 0 to 1073741823;
	
variable onlyLetterCounter : INTEGER range 0 to 173741823;
variable onlyLetterCounterSaved : INTEGER range 0 to 1073741823;

begin

	if rising_edge(MCLK) then
			maxCycle1 := maxCycle1 + 1;
			maxCycle2 := maxCycle2 - 1;
			onlyNumericCounter := onlyNumericCounter + 1;
			onlyLetterCounter := onlyLetterCounter + 1;
			
			if(maxCycle1 = 1073741823-1) then
				maxCycle1 := 0;
			end if;
			if(maxCycle2 = 1073741823) then
				maxCycle2 := 2147483646;
			end if;
			
			if(onlyNumericCounter = 173741823-1) then
				onlyNumericCounter := 0;
			end if;
			
			if(onlyLetterCounter = 173741823-1) then
				onlyLetterCounter := 0;
			end if;
			
			if BUTTON = '1' then

      -- When user wants to produce number & letters combined, we do not need to use
      -- indexing to the arrays, thus we can use random numbers. That is why clkRandom is being used.

			clkRandom(31 downto 16) <= std_logic_vector(to_unsigned(maxCycle1, 16));
			clkRandom(15 downto 0) <= std_logic_vector(to_unsigned(maxCycle2, 16));
			onlyNumericCounterSaved := onlyNumericCounter;
			onlyLetterCounterSaved := onlyLetterCounter;
			end if;
			
			case passwordMode is
				when "000" =>

          -- If none of the switches are active, showing 0 on the screen.

					RightToLeftLedDisplay <= x"00000000";
				when "100" =>

          -- If the first switch is activated, we are producing number between 0 to 32, than accessing
          -- to the array to get a random number.

          -- We used dividing before modding is that, we do not want to all indexes to be same.
          -- That would happen because counter saved is freezed in time.

					RightToLeftLedDisplay(31 downto 28) <= onlyNumeric((onlyNumericCounterSaved / 2) mod 32);
					RightToLeftLedDisplay(27 downto 24) <= onlyNumeric((onlyNumericCounterSaved / 4) mod 32);
					RightToLeftLedDisplay(23 downto 20) <= onlyNumeric((onlyNumericCounterSaved / 8) mod 32);
					RightToLeftLedDisplay(19 downto 16) <= onlyNumeric((onlyNumericCounterSaved / 16) mod 32);
					RightToLeftLedDisplay(15 downto 12) <= onlyNumeric((onlyNumericCounterSaved / 32) mod 32);
					RightToLeftLedDisplay(11 downto 8) <= onlyNumeric((onlyNumericCounterSaved / 64) mod 32);
					RightToLeftLedDisplay(7 downto 4) <= onlyNumeric((onlyNumericCounterSaved / 128) mod 32);
					RightToLeftLedDisplay(3 downto 0) <= onlyNumeric((onlyNumericCounterSaved / 256) mod 32);
				when "010" =>

          -- If the second switch is activated, we are producing number between 0 to 32, than accessing
          -- to the array to get a random letter.

          -- We used dividing before modding is that, we do not want to all indexes to be same.
          -- That would happen because counter saved is freezed in time.

					RightToLeftLedDisplay(31 downto 28) <= onlyLetters((onlyNumericCounterSaved / 2) mod 32);
					RightToLeftLedDisplay(27 downto 24) <= onlyLetters((onlyNumericCounterSaved / 4) mod 32);
					RightToLeftLedDisplay(23 downto 20) <= onlyLetters((onlyNumericCounterSaved / 8) mod 32);
					RightToLeftLedDisplay(19 downto 16) <= onlyLetters((onlyNumericCounterSaved / 16) mod 32);
					RightToLeftLedDisplay(15 downto 12) <= onlyLetters((onlyNumericCounterSaved / 32) mod 32);
					RightToLeftLedDisplay(11 downto 8) <= onlyLetters((onlyNumericCounterSaved / 64) mod 32);
					RightToLeftLedDisplay(7 downto 4) <= onlyLetters((onlyNumericCounterSaved / 128) mod 32);
					RightToLeftLedDisplay(3 downto 0) <= onlyLetters((onlyNumericCounterSaved / 256) mod 32);
				when "110" =>
        
          -- If both switches are active, we can use random bits since we do not need mapping to the array,
        
					RightToLeftLedDisplay(31 downto 28) <= clkRandom(31 downto 28);
					RightToLeftLedDisplay(27 downto 24) <= clkRandom(27 downto 24);
					RightToLeftLedDisplay(23 downto 20) <= clkRandom(23 downto 20);
					RightToLeftLedDisplay(19 downto 16) <= clkRandom(19 downto 16);
					RightToLeftLedDisplay(15 downto 12) <= clkRandom(15 downto 12);
					RightToLeftLedDisplay(11 downto 8) <= clkRandom(11 downto 8);
					RightToLeftLedDisplay(7 downto 4) <= clkRandom(7 downto 4);
					RightToLeftLedDisplay(3 downto 0) <= clkRandom(3 downto 0);
				when others =>
					NULL;
			end case;
			
	end if;
	
end process;

process(DigitToLed)
	begin
		case DigitToLed is
    
			when "0000" => SevenSegmentDisplay <= "0000001"; -- 0
			when "0001" => SevenSegmentDisplay <= "1001111"; -- 1
			when "0010" => SevenSegmentDisplay <= "0010010"; -- 2
			when "0011" => SevenSegmentDisplay <= "0000110"; -- 3
			when "0100" => SevenSegmentDisplay <= "1001100"; -- 4
			when "0101" => SevenSegmentDisplay <= "0100100"; -- 5
			when "0110" => SevenSegmentDisplay <= "0100000"; -- 6
			when "0111" => SevenSegmentDisplay <= "0001101"; -- 7
			when "1000" => SevenSegmentDisplay <= "0000000"; -- 8
			when "1001" => SevenSegmentDisplay <= "0000100"; -- 9
			when "1010" => SevenSegmentDisplay <= "0001000"; -- A
			when "1011" => SevenSegmentDisplay <= "1100000"; -- B
			when "1100" => SevenSegmentDisplay <= "0110001"; -- C
			when "1101" => SevenSegmentDisplay <= "1000010"; -- D
			when "1110" => SevenSegmentDisplay <= "0110000"; -- E
			when others => SevenSegmentDisplay <= "0111000"; -- F
		end case;
	end process;
	
process(MXSelect, RightToLeftLedDisplay)
	begin
		case MXSelect is
			when "000" => DigitToLed <= RightToLeftLedDisplay(3 downto 0);
			when "001" => DigitToLed <= RightToLeftLedDisplay(7 downto 4);
			when "010" => DigitToLed <= RightToLeftLedDisplay(11 downto 8);
			when "011" => DigitToLed <= RightToLeftLedDisplay(15 downto 12);
			when "100" => DigitToLed <= RightToLeftLedDisplay(19 downto 16);
			when "101" => DigitToLed <= RightToLeftLedDisplay(23 downto 20);
			when "110" => DigitToLed <= RightToLeftLedDisplay(27 downto 24);
			when others => DigitToLed <= RightToLeftLedDisplay(31 downto 28);
		end case;
	end process;
	
process(MXSelect, aen)
begin
	SegmentBlock <= "11111111";
	if (aen(conv_integer(MXSelect))) = '1' then
		SegmentBlock(conv_integer(MXSelect)) <= '0';
	end if;
end process;

process(MCLK)
begin
	if rising_edge(MCLK) AND MCLK = '1' then
		DividedClock <= DividedClock + 1;
	end if;
end process;

end Behavioral;
