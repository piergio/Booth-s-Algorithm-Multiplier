library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA is 
	generic (n: integer);
	Port (	A:	In	std_logic_vector(n-1 downto 0);
		B:	In	std_logic_vector(n-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(n-1 downto 0);
		Co:	Out	std_logic);
end RCA; 

architecture STRUCTURAL of RCA is

  signal STMP : std_logic_vector(n-1 downto 0);
  signal CTMP : std_logic_vector(n downto 0);

  component FA 
	port ( A:	In	std_logic;
		B:	In	std_logic;
		Ci:	In	std_logic;
		S:	Out	std_logic;
		Co:	Out	std_logic);
  end component; 

begin

  	CTMP(0) <= Ci;
	S <= STMP;
  	Co <= CTMP(n);

  
  
  ADDER1: for I in 1 to n generate
    FAI : FA 
	  port Map (A(I-1), B(I-1), CTMP(I-1), STMP(I-1), CTMP(I)); 
  end generate;
	
end STRUCTURAL;


architecture BEHAVIORAL of RCA is
signal sum: std_logic_vector(n downto 0);
begin
  
  sum <= (('0' & A) + ('0' & B))+Ci; --sum is on n+1 bits to avoid overflow
  S <= sum(n-1 downto 0); --the lower n bits are used as output sum signal
  Co <= sum(n); --the MSB rappresent the carry out of the sum

  
end BEHAVIORAL;

configuration CFG_RCA_STRUCTURAL of RCA is
  for STRUCTURAL 
    for ADDER1
      for all : FA
        use configuration WORK.CFG_FA_BEHAVIORAL;
      end for;
    end for;
  end for;
end CFG_RCA_STRUCTURAL;

configuration CFG_RCA_BEHAVIORAL of RCA is
  for BEHAVIORAL 
  end for;
end CFG_RCA_BEHAVIORAL;
