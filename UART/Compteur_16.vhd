----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:35:06 01/04/2023 
-- Design Name: 
-- Module Name:    Instants_Reception - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Compteur_16 is
    Port ( enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RxD : in  STD_LOGIC;
           tmpclk : out  STD_LOGIC;
           tmprxd : out  STD_LOGIC);
end Compteur_16;

architecture Behavioral of Compteur_16 is

begin
	process(enable, reset)
		variable value : natural:= 0;
		variable start : boolean := false;
		variable cptBit : natural := 0;
	begin
		if RxD = '0' and not start then
			start := true;
		end if;
		
		if cptBit = 11 then
			start := false;
			cptBit := 0;
		end if;
		
		if reset = '0' then
			value := 0;
			cptBit := 0;
		elsif (rising_edge(enable) and start) then
			if value = 7 then -- milieu d'une clk
				tmprxd <= RxD;
				value := value + 1;
				tmpclk <= 1;
			elsif value = 15 then 
				-- fin de cycle
				value := 0;
				cptBit := cptBit + 1;
			else value := value + 1;
				tmpclk <= 0;
			end if;
		end if;
	end process;

end Behavioral;

