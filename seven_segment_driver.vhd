----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:58 07/15/2020 
-- Design Name: 
-- Module Name:    seven_segment_driver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Need at least a 70Hz refresh rate for segments


entity seven_segment_driver is

	port(

		CLK 	: in std_logic;
		SEL	: out std_logic_vector(5 downto 0);
		SEG	: out std_logic_vector(6 downto 0);
		NUM	: in integer range 0 to 999999
	);
	
	
end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
	-- constants
	constant clk_65hz	: natural := 200000;
	
	-- signals
	-- signal number				: integer range 0 to 999999 := 0;
	signal segment_mux		: integer range 0 to 5 := 0;
	signal segment				: integer range 0 to 9;
	signal refresh_counter	: natural range 0 to clk_65hz := 0;
	
	
	-- digit store
	type digit_segment_array is array(0 to 5) of integer range 0 to 9;
	signal digit_segment : digit_segment_array :=(others => 0);

	-- BCD custom type
	type BCD is array(0 to 9) of std_logic_vector(6 downto 0);
	constant digit : BCD := ("1111110", "0110000", "1101101",
									"1111001", "0110011",	"1011011",
									"1011111", "1110000", "1111111", "1111011");
									
									
-- FUNCTIONS and PROCEDURES
-- converts integer to BCD
FUNCTION inttoBCD(input : integer) return std_logic_vector is
	variable result : std_logic_vector(6 downto 0);
	begin
		case input is
			when 0 => result := digit(0);
			when 1 => result := digit(1);
			when 2 => result := digit(2);
			when 3 => result := digit(3);
			when 4 => result := digit(4);
			when 5 => result := digit(5);
			when 6 => result := digit(6);
			when 7 => result := digit(7);
			when 8 => result := digit(8);
			when 9 => result := digit(9);
			when others => result := (others => 'X');
		end case;
		return result;
	end inttoBCD;

-- takes a number and returns it's digits (6 digits)	
PROCEDURE getDigit(signal number : in integer range 0 to 999999; signal digit_1, digit_2, digit_3, digit_4, digit_5, digit_6 : out integer range 0 to 9) is
	-- some variables
	type digit_buffer is array(0 to 5) of integer range 0 to 9;
	variable D : digit_buffer;
	variable temp : integer range 0 to 999999 := number;
	

	begin
		if (temp > 99999) then
			D(5) := temp/100000;
			temp := temp - D(5)*100000;
		else
			D(5) := 0;
		end if;
		
		if (temp > 9999) then
			D(4) := temp/10000;
			temp := temp - D(4)*10000;
		else
			D(4) := 0;
		end if;
		
		if (temp > 999) then
			D(3) := temp/1000;
			temp := temp - D(3)*1000;
		else
			D(3) := 0;
		end if;
		
		if (temp > 99) then
			D(2) := temp/100;
			temp := temp - D(2)*100;
		else
			D(2) := 0;
		end if;

		if (temp > 9) then
			D(1) := temp/10;
			temp := temp - D(1)*10;
		else
			D(1) := 0;
		end if;
		D(0) := temp;
		digit_1 <= D(0);
		digit_2 <= D(1);
		digit_3 <= D(2);
		digit_4 <= D(3);
		digit_5 <= D(4);
		digit_6 <= D(5);
	end getDigit;


begin
-- 65hz clock process
	p_clk_65hz : process(CLK) is
	begin
		if rising_edge(CLK) then

			if (refresh_counter < clk_65hz) then
				refresh_counter <= refresh_counter + 1;
			else
				refresh_counter <= 0;
				if (segment_mux = 5) then
					segment_mux <= 0;
				else 
					segment_mux <= segment_mux + 1;
				end if;
				case segment_mux is
					when 0 => segment <= digit_segment(0); SEL <= "111110";
					when 1 => segment <= digit_segment(1); SEL <= "111101";
					when 2 => segment <= digit_segment(2); SEL <= "111011";
					when 3 => segment <= digit_segment(3); SEL <= "110111";
					when 4 => segment <= digit_segment(4); SEL <= "101111";
					when 5 => segment <= digit_segment(5); SEL <= "011111";
					when others => segment <= 0;
				end case;
			end if;
		end if;
	end process p_clk_65hz;


-- get digits
getDigit(NUM, digit_segment(0), digit_segment(1), digit_segment(2), digit_segment(3), digit_segment(4), digit_segment(5));


SEG <= not inttoBCD(segment);
end Behavioral;
