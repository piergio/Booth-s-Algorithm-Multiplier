library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity boothMult is
	generic (	nBits : integer := 8
				);
	port	(	A : in	std_logic_vector(nBits-1 downto 0);
				B : in	std_logic_vector(nBits-1 downto 0);
				P : out std_logic_vector(2*(nBits)-1 downto 0)
			);
end entity boothMult;

architecture MIXED of boothMult is
	
	component twoComplGen
		generic(n : integer := 8);
		port(
			A : in  std_logic_vector(n+(n-1)*2 downto 0);
			Z : out std_logic_vector(n+(n-1)*2 downto 0)
		);
	end component twoComplGen;
	
	component MUX51_generic
		generic(n : integer := 8);
		port(
			A   : in  std_logic_vector(n-1 downto 0);
			B   : in  std_logic_vector(n-1 downto 0);
			C   : in  std_logic_vector(n-1 downto 0);
			D   : in  std_logic_vector(n-1 downto 0);
			E   : in  std_logic_vector(n-1 downto 0);
			sel : in  std_logic_vector(2 downto 0);
			Y   : out std_logic_vector(n-1 downto 0)
		);
	
	end component MUX51_generic; 
	
	component RCA
		generic(n : integer := 8);
		port(
			A  : in  std_logic_vector(n-1 downto 0);
			B  : in  std_logic_vector(n-1 downto 0);
			Ci : in  std_logic;
			S  : out std_logic_vector(n-1 downto 0);
			Co : out std_logic
		);
	end component RCA;
	
	component boothEnc
		generic(n : integer := 8);
		port(
			B : in  std_logic_vector(n-1 downto 0);
			Y : out std_logic_vector(3*(n/2)-1 downto 0)
		);
	end component boothEnc;
	
	constant encbits : integer := 3*(nBits/2);
	
	type add_o is array (0 to (nBits/2-2)) of std_logic_vector(2*(nBits)-1 downto 0); -- The adders' output is a matrix and has (N/2)-1 rows and 2*N colomns which are equal to twice the number of data bits.

	type mux_s is array (0 to (nBits/2-1)) of std_logic_vector(2 downto 0);					 -- The muxs' selector is a matrix and has (N/2)-1 rows which correspond to the number of muxs
																														 -- and 3 colomns which is equal to the exact number of bits needed for each group.
	type mux_o is array (0 to (nBits/2-1)) of std_logic_vector(2*(nBits)-1 downto 0); -- The muxs' output is a matrix and has (N/2)-1 rows which correspond to the number of muxs
																														 -- and 2*N colomns which is equal to twice the number of data bits.
	
	signal add_out	: add_o;
	signal mux_sel	: mux_s;
	signal mux_out	: mux_o;
	
	-- the below vectors are sized in this way for allowing to shift the input data until it is needed with respect to the number of bits 	
	signal mData: std_logic_vector(nBits+(nBits-1)*2 downto 0); 	
	signal twoCdata: std_logic_vector(nBits+(nBits-1)*2 downto 0);
	
	signal enc_out	: std_logic_vector(encbits-1 downto 0); -- the enc_out signal is a vector sized with encbits, which correspond to 3*(N/2) 
	
	begin

	-- The below code instantiates the twoComplGEn block which provides the two's complement of input data A
	twoCompl : twoComplGen
		generic map	(
					n => nBits
		)
		port map (
					A => mData,
					Z => twoCdata	-- two's complement data
				 );
	
	mData(3*nBits-2 downto 2*nBits-1) <= (others => '0');	--	Starting from the MSB, it assigns N(databits) bits to '0' 
	mData((nBits-1)*2 downto nBits-1) <= A;	--	After the MSB-N bits, it assigns vectors N(databits) bits to the input A 
	mData(nBits-2 downto 0) <= (others => '0');	--	It assigns N(databits)-1 bits to '0'. The number of zeros corresponds to the maximum number of shifts it is needed.
																	-- For instance: assuming A is a N=8-bit binary number, you need to multiply by at maximum 2^(N-1)=128, where N=8
	
	-- The below code instantiates the Booth Encoder and connects the input to the provided data B and the output to the enc_out signal
	enc : boothEnc
		generic map(
			n => nBits
		)
		port map(
			B => B,
			Y => enc_out
		);

	-- The below "for generate" connects the output signal enc_out of the boothenc to the mux_sel signal which is a matrix.
	-- The selector is essential for selecting the different muxs.
	forENCconn : for i in 0 to (nBits/2-1)  generate	-- from 0 to the maximum number of muxs needed
	begin																	
		mux_sel(i) <= enc_out(3*i+2 downto 3*i);				-- it takes 3 bits from enc_out at each iteration. In this way, the mux sel matrix is having 3 bits for each and every row.
	end generate;
	
	-- The below "for generate" instantiates N/2 muxs and connects to them the right data
	mux_gen: for i in 0 to (nBits/2-1) generate
	begin
		mux: MUX51_generic 
			
			generic map(
						n => 2*nBits
			)
			port map(	A => (OTHERS => '0'),	-- this is always equal to 0
						B => mData(3*nBits-2-2*i downto nBits-1-2*i),	-- each iteration, it assigns the input data A for the first time, and the multiplied version for the next iterations, with respect to the number of data bits.
						C => twoCdata(3*nBits-2-2*i downto nBits-1-2*i), -- each iteration, it assigns the two's complemented input data A for the first time, and the multiplied version for the next iterations, with respect to the number of data bits. 
						D => mData(3*nBits-2-2*i-1 downto nBits-1-2*i-1),	-- each iteration, it assigns the input data A multiplied by 2(shifted by 1 bit) compared to the B input of the mux.
						E => twoCdata(3*nBits-2-2*i-1 downto nBits-1-2*i-1), -- each iteration, it assigns the two's complemented input data A multiplied by 2(shifted by 1 bit) compared to the B input of the mux.
						sel => mux_sel(i),	-- it connects the mux sel to the signal mux_sel, row by row.
						Y => mux_out(i));		-- it connects the output of the mux to the signal mux_out, row by row.
	
	end generate mux_gen;
	
	-- The below code instantiates 1 RCA and connects the outputs of the muxs to RCA inputs 
	sum1 : RCA
		   generic map(
		   			n => 2*nBits
		   )
		   port map(
					A => mux_out(1),	-- it connects the A RCA input to the first mux's mux_out signal
					B => mux_out(0),	-- it connects the B RCA input to the second mux's mux_out signal
		   			Ci => '0',
		   			S => add_out(0),	-- it connects the S RCA output to the first element of the add_out matrix signal
					Co => open			-- don't care
		   );
		   
	-- The below code instantiates the remaining RCAs and connects the outputs of one mux to one RCA input and the output of the previous RCA to the other RCA input		
	forsumi : for i in 1 to (nBits/2-2) generate
	sumi :	RCA
			generic map(
					n => 2*nBits
			)
			port map(
					A  => mux_out(i+1),	-- it connects the A RCA input to the mux_out signal
					B  => add_out(i-1),	-- it connects the B RCA input to the RCA output at the previous stage
					Ci => '0',
					S  => add_out(i),
					Co => open				-- don't care
			);	
	end generate;
	
	P <= add_out(nBits/2-2);		-- We take the last element(last row) of the add_out matrix signal to see the computed result
	
end architecture MIXED;
