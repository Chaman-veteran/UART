library IEEE;
 use IEEE.std_logic_1164.all;
 
 entity RxUnit is
   port (
     clk, reset       : in  std_logic;
     enable           : in  std_logic;
     read             : in  std_logic;
     rxd              : in  std_logic;
     data             : out std_logic_vector(7 downto 0);
     Ferr, OErr, DRdy : out std_logic);
	  -- temprxd, tempclk : out std_logic;
	  --parite, iserror : out std_logic);
 end RxUnit;
 
 architecture RxUnit_arch of RxUnit is
	 type Tcompteur is (Idle, Counting, Sending);
	 signal currTCount : Tcompteur := Idle;
	 signal to_count : natural;
	 signal cptBitCounter : natural;
	 signal tmprxd : std_logic;
	 signal tmpclk : std_logic;
	 -- signals for the builder
	 type TBuilder is (Idle, Receiving, Parity, BitStop, ReadCheck);
	 signal currTBuild : Tbuilder := Idle;
	 signal cptBitBuilder : natural;
	 signal error : std_logic;
	 signal tmpDat : std_logic_vector(7 downto 0);
	 signal par : std_logic;
 begin
	-- temprxd <= tmprxd;
	-- tempclk <= tmpclk;
	-- parite <= par;
	-- iserror <= error;
	-- process for the counter
	process (enable, reset)
	begin
		if (reset = '0') then
			-- signals back to their default value
			tmpclk <= '0';
			tmprxd <= '1';
			currTCount <= Idle;
		elsif rising_edge(enable) then
			case currTCount is 
				when Idle =>
					if (rxd = '0') then
						to_count <= 7;
						cptBitCounter <= 11;
						currTCount <= Counting;
					else -- rxd = '0'
						
						null;
					end if;
				when Counting =>
					if (to_count > 0) then
						to_count <= to_count - 1;
					else -- to_count = 0
						tmprxd <= rxd;
						cptBitCounter <= cptBitCounter - 1;
						tmpclk <= '1';
						currTCount <= Sending;
					end if;
				when Sending =>
					if (cptBitCounter > 0) then
						to_count <= 14;
						tmpclk <= '0';
						currTCount <= Counting;
					else -- cptBitCounter = 0
						tmpclk <= '0';
						currTCount <= Idle;
					end if;
			end case;
		end if;
	end process;

	-- process for building the data
	process (clk, reset)
	begin
		if (reset = '0') then
			-- signals back to their default value
			Ferr <= '0';
			OErr <= '0';
			DRdy <= '0';
			currTBuild <= Idle;
			data <= (others => '0');
			tmpDat <= (others => '0');
		elsif rising_edge(clk) then
			case currTBuild is 
				when Idle=>
					if (tmpclk = '1') then
						cptBitBuilder <= 0;
						par <= '0';
						error <= '0';
						currTBuild <= Receiving;
					else -- tmpclk = 0
						Ferr <= '0';
						OErr <= '0';
					end if;
				when Receiving =>
					if (tmpclk = '0') then
						-- synchronized on tmpclk, so we wait
						null;
					elsif (tmpclk = '1' and cptBitBuilder < 8) then 
						-- continue receiving a bit
						par <= par xor tmprxd;
						tmpdat (7 - cptBitBuilder) <= tmprxd;
						cptBitBuilder <= cptBitBuilder + 1;
					else -- tmpclk = 1 and cptBitBuilder = 8
						-- received all the bits, change state
						-- check if the parity bit is ok
						error <= (par xor tmprxd);
						currTBuild <= Parity;
					end if;
				when Parity =>
					if (tmpclk = '0') then 
						null;
					else -- tmpclk = 1
						-- check if the stop bit's value is equal to 1
						error <= error or (not tmprxd);
						currTBuild <= BitStop;
					end if;
				when BitStop =>
					if (error = '1') then
						-- there was an error during the reception of the byte
						Ferr <= '1';
						currTBuild <= Idle;
					else -- error = 0
						data <= tmpDat;
						DRdy <= '1';
						currTBuild <= ReadCheck;
					end if;
				when ReadCheck =>
					if (read = '0') then
						-- the processor did not read the data
						DRdy <= '0';
						OErr <= '1';
					else
						-- read OK
						DRdy <= '0';
					end if;
					currTbuild <= Idle;
			end case;
		end if;
	end process;
 end RxUnit_arch;
