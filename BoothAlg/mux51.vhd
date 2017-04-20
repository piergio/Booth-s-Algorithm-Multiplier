library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity MUX51_generic is 
	generic (n: integer := 8 );
	port (		A   : in  std_logic_vector(n-1 downto 0);
			B   : in  std_logic_vector(n-1 downto 0);
			C   : in  std_logic_vector(n-1 downto 0);
			D   : in  std_logic_vector(n-1 downto 0);
			E   : in  std_logic_vector(n-1 downto 0);
			sel : in  std_logic_vector(2 downto 0);
			Y   : out std_logic_vector(n-1 downto 0)
		 );
end MUX51_generic ;


architecture behavioral of MUX51_generic  is

begin
	process(A,B,C,D,E,sel)
	begin		
		case sel is
			when  "000"  =>  Y <= A;
			when  "001"  =>  Y <= B;
			when  "010"  =>  Y <= B;
			when  "011"  =>  Y <= D;
			when  "100"  =>  Y <= E;
			when  "101"  =>  Y <= C;
			when  "110"  =>  Y <= C;
			when  "111"  =>  Y <= A;
			when others => Y <= (others => '0');
  		end case;
	end process;

end behavioral;

