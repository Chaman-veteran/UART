--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:56:26 01/13/2023
-- Design Name:   
-- Module Name:   /home/jprevost/Bureau/2A/archi/uart/UART/testRxUnit.vhd
-- Project Name:  projet_uart
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
 
ENTITY testRxUnit IS
END testRxUnit;
 
ARCHITECTURE behavior OF testRxUnit IS 
 
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
         DRdy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enableRx : std_logic := '0';
	signal enableTx : std_logic := '0';
   signal read : std_logic := '0';
   signal rxd : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enableRX,
          read => read,
          rxd => rxd,
          data => data,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy
        );

   -- Instantiate the clkUnit
   enableRx <= clk and reset;

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      reset <= '1',
					'0' after 2200 ns,
					'1' after 2250 ns, 
					'0' after 4100 ns, 
					'1' after 4150 ns,
					'0' after 6100 ns,
					'1' after 6150 ns;
      rxd <= '1';
      read <= '0';

		-- first test : normal behavior
      wait for 200 ns;
      rxd <= '0',  -- start bit
             '1' after 160 ns,  -- data bit 0
             '0' after 320 ns,  -- data bit 1
             '1' after 480 ns,  -- data bit 2
             '0' after 640 ns,  -- data bit 3
             '1' after 800 ns,  -- data bit 4
             '0' after 960 ns,  -- data bit 5
             '1' after 1120 ns,  -- data bit 6
             '0' after 1280 ns,  -- data bit 7
             '0' after 1440 ns,  -- parite bit
             '1' after 1600 ns,  -- stop bit
				 -- second test : the received byte is incorrect (parity is incorrect)
				 '0' after 1960 ns,  -- start bit
             '1' after 2120 ns,  -- data bit 0
             '0' after 2380 ns,  -- data bit 1
             '1' after 2540 ns,  -- data bit 2
             '0' after 2700 ns,  -- data bit 3
             '1' after 2860 ns,  -- data bit 4
             '0' after 3020 ns,  -- data bit 5
             '1' after 3180 ns,  -- data bit 6
             '0' after 3340 ns,  -- data bit 7
             '1' after 3500 ns,  -- parity bit incorrect
             '1' after 3660 ns,  -- stop bit
				 -- third test : the stop bit is incorrect
				 '0' after 3960 ns,  -- start bit
				 '1' after 4120 ns,  -- data bit 0
				 '0' after 4280 ns,  -- data bit 1
				 '1' after 4440 ns,  -- data bit 2
				 '0' after 4600 ns,  -- data bit 3
				 '1' after 4760 ns,  -- data bit 4
				 '0' after 4920 ns,  -- data bit 5
				 '1' after 5080 ns,  -- data bit 6
				 '0' after 5240 ns,  -- data bit 7
				 '0' after 5400 ns,  -- parity bit 
				 '0' after 5560 ns,  -- stop bit is incorrect
				 '1' after 5700 ns,
				 -- fourth test: byte reception is ok, but read comes too late
				 '0' after 5960 ns,  -- start bit
             '1' after 6120 ns,  -- data bit 0
             '0' after 6280 ns,  -- data bit 1
             '1' after 6440 ns,  -- data bit 2
             '0' after 6600 ns,  -- data bit 3
             '1' after 6760 ns,  -- data bit 4
             '0' after 6920 ns,  -- data bit 5
             '1' after 7080 ns,  -- data bit 6
             '0' after 7240 ns,  -- data bit 7
             '0' after 7400 ns,  -- parity bit 
             '1' after 7560 ns;  -- stop bit

		read <= '1' after 1700 ns,
			     '0' after 1760 ns,
				  -- delayed read
				  '1' after 7800 ns,
				  '0' after 7850 ns;
		

		
      wait;
   end process;

END;
