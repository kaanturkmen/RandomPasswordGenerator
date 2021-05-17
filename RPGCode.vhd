----------------------------------------------------------------------------------
-- University: Koç University
-- Students: Kaan Türkmen - Can Usluel
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

type vectorArray is array (0 to 9) of std_logic_vector(3 downto 0);
signal onlyNumeric: vectorArray;

begin

-- 1 2 3 4 5 6 7 8 - Numbers
-- A B C D Letters
-- - _ Special Characters

MXSelect <= DividedClock(19 downto 17);
aen <= "11111111";


onlyNumeric(0) <= "0000";
onlyNumeric(1) <= "0001";
onlyNumeric(2) <= "0010";
onlyNumeric(3) <= "0011";
onlyNumeric(4) <= "0100";
onlyNumeric(5) <= "0101";
onlyNumeric(6) <= "0110";
onlyNumeric(7) <= "0111";
onlyNumeric(8) <= "1000";
onlyNumeric(9) <= "1000";

process(MCLK)
variable clockCycle : INTEGER range 0 to 50*10**6;
variable maxCycle1 : INTEGER range 0 to 1073741823;
variable maxCycle2 : INTEGER range 1073741823 to 2147483646;

variable onlyNumericCounter : INTEGER range 0 to 173741823;

variable onlyNumericCounterSaved : INTEGER range 0 to 1073741823;

begin
	
	if rising_edge(MCLK) then
			clockCycle := clockCycle + 1;
			maxCycle1 := maxCycle1 + 1;
			maxCycle2 := maxCycle2 + 1;
			onlyNumericCounter := onlyNumericCounter + 1;
			
			if(clockCycle = 50*10**6-1) then
				clockCycle := 0;
			end if;
			
			if(maxCycle1 = 1073741823-1) then
				maxCycle1 := 0;
			end if;
			if(maxCycle2 = 2147483646-1) then
				maxCycle2 := 1073741823;
			end if;
			
			if(onlyNumericCounter = 173741823-1) then
				onlyNumericCounter := 0;
			end if;
			
			if BUTTON = '1' then
			clkRandom(31 downto 16) <= std_logic_vector(to_unsigned(maxCycle1, 16));
			clkRandom(15 downto 0) <= std_logic_vector(to_unsigned(maxCycle2, 16));
			onlyNumericCounterSaved := onlyNumericCounter;
			end if;
			
			case passwordMode is
				when "000" =>
					RightToLeftLedDisplay <= x"00000000";
				when "100" =>
					RightToLeftLedDisplay(31 downto 28) <= onlyNumeric((onlyNumericCounterSaved / 10) mod 10);
					RightToLeftLedDisplay(27 downto 24) <= onlyNumeric((onlyNumericCounterSaved / 100) mod 10);
					RightToLeftLedDisplay(23 downto 20) <= onlyNumeric((onlyNumericCounterSaved / 1000) mod 10);
					RightToLeftLedDisplay(19 downto 16) <= onlyNumeric((onlyNumericCounterSaved / 10000) mod 10);
					RightToLeftLedDisplay(15 downto 12) <= onlyNumeric((onlyNumericCounterSaved / 100000) mod 10);
					RightToLeftLedDisplay(11 downto 8) <= onlyNumeric((onlyNumericCounterSaved / 1000000) mod 10);
					RightToLeftLedDisplay(7 downto 4) <= onlyNumeric((onlyNumericCounterSaved / 10000000) mod 10);
					RightToLeftLedDisplay(3 downto 0) <= onlyNumeric((onlyNumericCounterSaved / 100000000) mod 10);
				when "010" =>
					RightToLeftLedDisplay <= x"00000000";
				when "001" =>
					RightToLeftLedDisplay <= x"00000000";
				when "110" =>
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