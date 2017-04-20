library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity twoComplGen is
	generic(n : integer := 8);
	port (
		A : in std_logic_vector(n+(n-1)*2 downto 0);
		Z : out std_logic_vector(n+(n-1)*2 downto 0)
	);
end entity twoComplGen;

architecture RTL of twoComplGen is
	
	signal AtwoCompl : std_logic_vector(n+(n-1)*2 downto 0);	
	
begin
	process(A, AtwoCompl)
	begin
		AtwoCompl <= not(A) + '1';
		Z <= AtwoCompl;
	end process;
	
end architecture RTL;
