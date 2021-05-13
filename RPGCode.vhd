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
use IEEE.NUMERIC_STD.ALL;


entity RPGCode is
		Generic (N : INTEGER:=50*10**6); --50*10ˆ6 Hz Clock
	Port (MCLK : in STD_LOGIC;
		S : in STD_LOGIC_VECTOR(2 downto 0);
		B : in STD_LOGIC;
		X : out STD_LOGIC);
end RPGCode;

architecture Behavioral of RPGCode is

begin

-- 0 1 2 3 4 5 6 7 8 9 - Numbers
-- A B C D E F Letters
-- . - _ Special Characters

process(MCLK)
variable clockCycle : INTEGER range 0 to 50*10**6;
begin
	
	if rising_edge(MCLK) then
			clockCycle := clockCycle + 1;
			if(clockCycle = 50*10**6-1) then
				clockCycle := 0;
			end if;
	end if;
	
end process;

process(B)
	begin
		for I in 0 to 8 loop
			case S is
				when "000" =>
					X <= '0';
				when "100" =>
					X <= clockCycle mod 10;
				when "010" =>
					X <= clockCycle mod 6;
				when "001" =>
					X <= clockCycle mod 3;
				when others =>
					NULL;
			end case;
			-- Check segment and display in the led area.
		end loop;
	end process;
	

end Behavioral;

