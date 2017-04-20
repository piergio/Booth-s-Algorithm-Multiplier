library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
	port	(	B : in std_logic_vector(2 downto 0);
				Vp : out std_logic_vector(2 downto 0)
			);
end entity encoder;

architecture behavioral of encoder is
	
begin
		process(B)
		begin
			case B is
				when  "000"	=>  Vp <= "000"; -- A
				when  "001"	=>  Vp <= "001"; -- B
				when  "010"	=>  Vp <= "001"; -- B
				when  "011"	=>  Vp <= "011"; -- D
				when  "100"	=>  Vp <= "100"; -- E
				when  "101"	=>  Vp <= "101"; -- C 
				when  "110"	=>  Vp <= "110"; -- C 
				when  "111"	=>  Vp <= "111"; -- A
				when others =>	Vp <= "000";
	  		end case;
		end process;
end architecture behavioral;
