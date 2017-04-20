library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity boothEnc is
	generic(n : integer := 8);
	port (
			B : in  std_logic_vector(n-1 downto 0);
			Y : out std_logic_vector(3*(n/2)-1 downto 0)
	);
end entity boothEnc;

architecture RTL of boothEnc is
	
	component encoder
		port(
			B : in  std_logic_vector(2 downto 0);
			Vp : out std_logic_vector(2 downto 0)
		);
	end component encoder;
	
	-- The following is an array made up of N/2 signals of 3 bits each
	--It is needed for having the B input data divided into 3 bits for each group
	type enc is array (0 to n/2-1) of std_logic_vector(2 downto 0);
	signal inEnc  : enc;
	 
begin
	
	-- The first three bits are set down here
	inEnc(0)(0) <= '0';	-- it corresponds to B[-1] which is '0'
	inEnc(0)(1) <= B(0);	-- it is the first bit
	inEnc(0)(2) <= B(1); -- it is the second bit
	
	-- The other bits are picked up in such way as to get the third most significant bit among the previous group of three bits
	forenc : for i in 1 to n/2-1 generate
	begin
		inEnc(i)(0) <= B(2*i-1);	-- it takes the previous bit
		inEnc(i)(1) <= B(2*i);
		inEnc(i)(2) <= B(2*i+1);
	end generate;
	
	-- The below "for generate" instantiates N/2 encoders and connects to them the right data
	enc_generate : for i in 0 to n/2-1 generate
	begin 
	enc : encoder 
		port map(B => inEnc(i),	-- it connects the B input of the encoder to the inEnc matrix signal, row by row
					Vp => Y((i+1)*3-1 downto (i+1)*3-3));	-- it connects the Vp output of the encoder to the Y signal,
	end generate;													-- which is the output of the Booth Encoder
	
end architecture RTL;
