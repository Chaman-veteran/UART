--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:50:15 01/13/2023
-- Design Name:   
-- Module Name:   /media/quentin/d0333baa-bef8-4d5a-8315-2c0f07cad24a1/Documents/Annee_2/Archi/UART_Emission_FRATY_MAILLET/UART/test_RxUnit.vhdl
-- Project Name:  test_Rx2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_RxUnit IS
END test_RxUnit;
 
ARCHITECTURE behavior OF test_RxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         Ferr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic;
         temprxd : OUT std_logic;
			tempclk : OUT std_logic;
			state_debug : out natural
        );
    END COMPONENT;
    

   --Inputs
   signal clk     : std_logic    := '0';
   signal reset   : std_logic    := '0';
   signal enable  : std_logic    := '0';
   signal read    : std_logic    := '0';
   signal rxd     : std_logic    := '1';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;
   signal temprxd : std_logic;
	signal tempclk : std_logic;
	signal state_debug	: natural;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
          read => read,
          rxd => rxd,
          data => data,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy,
			 temprxd => temprxd,
			 tempclk => tempclk,
			 state_debug => state_debug
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   enable <= clk and reset;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      read <= '0';
      wait for 100 ns;
      reset <= '1';
      -- bit start
      rxd <= '0';
      wait for 16*clk_period;
      
      -- on envoie 01010101
      rxd <= '0';
      wait for 16*clk_period;
      rxd <= '1';
      wait for 16*clk_period;
      rxd <= '0';
      wait for 16*clk_period;
      rxd <= '1';
      wait for 16*clk_period;
      rxd <= '0';
      wait for 16*clk_period;
      rxd <= '1';
      wait for 16*clk_period;
      rxd <= '0';
      wait for 16*clk_period;
      rxd <= '1';
      wait for 16*clk_period;

      -- bit de partié
      rxd <= '0';
      wait for 16*clk_period;
      rxd <= '1';
		wait for 8*clk_period;
		-- bit stop
		wait for clk_period;
		read <= '1';
		wait for 8*clk_period;
		read <= '0';

      wait for clk_period*10;


      wait;
   end process;

END;
      -- insert stimulus here 
