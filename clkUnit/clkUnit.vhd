library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is
  signal top : std_logic := '0';
  constant facteur : natural := 16;
begin
	enableRX <= clk and reset;
	
  div : process (clk, reset)
    variable cpt : integer range 0 to facteur-1 := 0;
  begin 
    if reset = '0' then
      enableTX <= '0';
      cpt := 0;
    elsif rising_edge(clk) then
      if(cpt = facteur - 1) then
        cpt := 0;
      else
        cpt := cpt + 1;
      end if;
      if cpt = 0 then
        enableTX <= '1';
      else
        enableTX <= '0';
      end if;
    end if;
  end process;

end behavorial;
