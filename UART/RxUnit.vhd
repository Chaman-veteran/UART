library IEEE;
 use IEEE.std_logic_1164.all;
 
 entity RxUnit is
   port (
     clk, reset       : in  std_logic;
     enable           : in  std_logic;
     read             : in  std_logic;
     rxd              : in  std_logic;
     data             : out std_logic_vector(7 downto 0);
     Ferr, OErr, DRdy : out std_logic;
	 temprxd, tempclk : out std_logic;
	 state_debug : out natural);
 end RxUnit;
 
 architecture RxUnit_arch of RxUnit is
	 COMPONENT Compteur_16
		PORT(
			enable : IN std_logic;
			reset : IN std_logic;
			RxD : IN std_logic;          
			tmpclk : OUT std_logic;
			tmprxd : OUT std_logic
			);
		END COMPONENT;
		signal tmpclk : std_logic;
		signal tmprxd : std_logic;
		signal cpt_bit : natural := 0;
		signal parite : std_logic;
		signal ferror, oerror, dready : std_logic;
		signal bitStop : std_logic;
		signal error : std_logic;
 begin
	Ferr <= ferror;
	OErr <= oerror;
	DRdy <= dready;
	temprxd <= tmprxd;
	tempclk <= tmpclk;

	process(tmpclk, reset)
		variable tmp_dat : std_logic_vector(7 downto 0) := "00000000";
		-- variable error : std_logic;
	begin
		if reset = '0' then
			cpt_bit <= 0;
			parite <= '0';
			error <= '0';
			data <= "00000000";
		elsif (rising_edge(tmpclk)) then
			case cpt_bit is
				when 0 => -- bit start
					BitStop <= '0';
					if (tmprxd = '0') then
						-- bitStart ok
						cpt_bit <= cpt_bit + 1;
					else
						-- bitStart nok: 
						-- on fait rien
					end if;
				when 9 => -- bit parité
					if (parite = tmprxd) then 
						-- parité ok
						-- on ne fait rien
					else
						error <= '1';
					end if;
					cpt_bit <= cpt_bit + 1;
				when 10 => -- bit stop
					bitStop <= '1';
					if error = '0' then
						data <= tmp_dat;
					end if;
					cpt_bit <= 0;
				when others => -- bits de l'octet
					tmp_dat(8 - cpt_bit) := tmprxd;  -- voir le sens ?
					-- bit parite
					parite <= parite and tmprxd;
					cpt_bit <= cpt_bit + 1;
			end case;
		end if;
	end process;

	-- process assurant que OErr et FErr ne sont à 1 que pendant 1 enableRx
	process(clk, reset)
		type State is (Nominal, Clear, Dreadry, Oerr);
		variable etat : State := Nominal;
	begin
		if (reset = '0') then
			dready <= '0';
			ferror <= '0';
			oerror <= '0';
			etat := Nominal;
			state_debug <= 0;
		elsif (rising_edge(clk)) then
			case etat is
			when Nominal =>
				state_debug <= 1;
				if bitStop = '1' then
				-- vérification de la conformité du bitStop
					if (tmprxd = '1' and error = '0') then
						-- pas d'erreur, fin de transmission
						dready <= '1';
						etat := Dreadry;
					else
						ferror <= '1';
						etat := Clear;
					end if;
				end if;
			when Dreadry =>
				state_debug <= 2;
				-- vérification que le processeur a lu la donnée, sinon erreur
				if (read = '1') then
					--ok
					etat := Clear;
				else
					oerror <= '1';
					etat := Oerr;
				end if;
				dready <= '0';
			when Oerr => 
				state_debug <= 3;
				etat := Clear;
				oerror <= '0';
			when Clear => -- (reset) etat dans lequel on est après l'envoi complet d'une trame
				state_debug <= 4;
				dready <= '0'; -- ne reste up qu'une clk
				ferror <= '0';
				oerror <= '0';
				if (rising_edge(tmpclk)) then
					etat := Nominal;
				end if;
			end case;
		end if;
	end process;

	Inst_Compteur_16: Compteur_16 PORT MAP(
		enable => enable,
		reset => reset,
		RxD => rxd,
		tmpclk => tmpclk,
		tmprxd => tmprxd
	);

 end RxUnit_arch;
