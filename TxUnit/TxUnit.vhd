library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0)
	 -- etat_dbg : out natural
	 );
end TxUnit;

architecture behavorial of TxUnit is
	signal bufferT : std_logic_vector(7 downto 0);
	signal registerT : std_logic_vector(7 downto 0);
	signal par : std_logic;
	signal bufferE : std_logic; -- bufferE = 1 ssi bufferT vide

begin
	process (clk, reset)
		TYPE type_etat is (Attente, Chargement, BitStart, Emission, Parite, BitStop); 
		variable etat : type_etat := Attente;
		variable cpt : natural := 7;
	begin
		if reset = '0' then
			-- On remet les variables/signaux a 0 a reset
			etat := Attente;
			-- etat_dbg <= 0;
			-- Valeur par défaut des signaux
			bufE <= '1';
			bufferE <= '1';
			regE <= '1';
			txd <= '1';
			par <= '0';
			cpt := 8;
		elsif rising_edge(clk) then
			bufE <= bufferE;
			-- factorisation du if
			-- Rq: pour attente et chargement il n'est pas nécessaire
			if ld = '1' and bufferE = '1' then
				-- stockage de data dans le buffer par anticipation
				bufferT <= data;
				bufferE <= '0';
			else
				-- NOP
					end if;
			-- Cas nominal du process a chaque front montant de **clk**
			case etat is
				when Attente =>
					-- etat_dbg <= 1;
					if ld = '1' then
						bufferT <= data;
						bufferE <= '0';
						etat := Chargement;
					else
						-- NOP
						bufE <= '1';
					end if;
				when Chargement =>
					-- etat_dbg <= 2;
					registerT <= bufferT;
					bufferE <= '1';
					regE <= '0';
					etat := BitStart;
				when BitStart =>
					if enable = '1' then
						-- etat_dbg <= 3;
						txd <= '0';
						etat := Emission;
					end if;
				when Emission =>
					if enable = '1' then
						-- lowering CPT
						cpt := cpt - 1;
						-- etat_dbg <= 4;
						txd <= registerT(cpt);
						par <= par xor registerT(cpt);
						
						if cpt > 0 then
							-- On reste dans l'etat Emission
						else
							etat := Parite;
						end if;
					end if;
				when Parite =>
					if enable = '1' then
						-- etat_dbg <= 5;					
						txd <= par;
						etat := BitStop;
					end if;
				when BitStop =>
					if enable = '1' then
						-- etat_dbg <= 6;
						txd <= '1';
						regE <= '1';
						par <= '0';
						cpt := 8;
						if bufferE = '0' or ld = '1' then
							-- dans le cas ou un ordre est donné au dernier moment (ld = '1'), 
							-- il faut directement repasser en Chargement
							etat := Chargement;
						else
							etat := Attente;
						end if;
					end if;
			end case;
		end if;
	end process;
end behavorial;
