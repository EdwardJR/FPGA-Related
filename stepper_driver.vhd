----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:50:12 08/28/2020 
-- Design Name: 
-- Module Name:    stepper_driver - Behavioral 
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
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

-- for now we have a constant step speed of 1HZ
-- will change to be dynamic later on

entity stepper_driver is
	generic(
		packet_size : std_logic_vector(11 downto 0) := (others => '0')
	);
	port(
		CLK 			: in std_logic;
		PACKET_IN	: in std_logic_vector(packet_size'HIGH downto packet_size'LOW);
		START_STEP	: in std_logic;
		DIR			: out std_logic_vector(4 downto 0);
		STEP 			: out std_logic_vector(4 downto 0);
		DEBUG			: out std_logic
		
	);

end stepper_driver;

architecture Behavioral of stepper_driver is
	-- packet parse
	-- signal packet_temp	: std_logic_vector(packet_size'left downto packet_size'right);
	signal direction		: std_logic_vector(0 downto 0);
	signal motor			: std_logic_vector(2 downto 0);
	signal step_count		: std_logic_vector(7 downto 0);
--	signal step_signals	: std_logic_vector(4 downto 0);
	
	
	-- counter set up
	constant period 		: natural := 24999999;
	signal delay 			: integer range 0 to period := 0;
	signal pulse 			: std_logic := '0';
	signal step_counter 	: integer range 0 to 256 := 0;

	-- step generator set up
	type step_generator_state is (idle, gen_high, gen_low);
	signal step_state : step_generator_state := idle;
	
begin
	DEBUG <= pulse;
	p_step_gen: process(CLK) is
	begin
		if rising_edge(CLK) then
			case motor is
				when "001" =>
				STEP(0) <= pulse;
				DIR(0 downto 0) <= direction;
				when "010" =>
				STEP(1) <= pulse;
				DIR(1 downto 1) <= direction;
				when "011" =>
				STEP(2) <= pulse;
				DIR(2 downto 2) <= direction;
				when "100" =>
				STEP(3) <= pulse;
				DIR(3 downto 3) <= direction;
				when "101" =>
				STEP(4) <= pulse;
				DIR(4 downto 4) <= direction;
				when others => 
				STEP(0) <= '0';
				STEP(1) <= '0';
				STEP(2) <= '0';
				STEP(3) <= '0';
				STEP(4) <= '0';
			end case;
			if START_STEP = '1' then
				motor 		<= PACKET_IN(11 downto 9);
				direction 	<= PACKET_IN(8 downto 8);
				step_count	<= PACKET_IN(7 downto 0);
			end if;
			case step_state is
				when idle =>
				step_counter <= 0;
				pulse <= '0';
				if START_STEP = '1' then
					motor 		<= PACKET_IN(11 downto 9);
					direction 	<= PACKET_IN(8 downto 8);
					step_count	<= PACKET_IN(7 downto 0);
					step_state  <= gen_high;
					
				end if;
				when gen_high =>
					pulse <= '1';
					if delay = period then
						step_state <= gen_low;
						delay <= 0;
					else
						delay <= delay + 1;
					end if;
				when gen_low =>
					pulse <= '0';
					if delay = period then
						delay <= 0;
						step_counter <= step_counter + 1;
						if step_counter = unsigned(step_count) - 1 then
							step_state <= idle;
							step_counter <= 0;
						else
							step_state <= gen_high;
						end if;
					else
						delay <= delay + 1;
					end if;
			end case;
		end if;
	end process p_step_gen;

end Behavioral;





--			case gcode is
--				when idle =>
--				if START_STEP = '1' then
--					-- parse the packet
--					motor 		<= PACKET_IN(11 downto 9);
--					direction 	<= PACKET_IN(8 downto 8);
--					step_count	<= PACKET_IN(7 downto 0);
--					gcode <= step_gen;
--				end if;
--				when step_gen =>
--					step_counter <= to_unsigned(step_count);
--					gcode <= select_motor;
--				when select_motor =>
--					case motor is
--						when "001" =>
--							DIR <= direction;
--							if step_generator_counter < step_counter then
--								if delay < clk_1hz then
--									delay <= delay + 1
--								else
--									step_generator <= not step_generator;
--									STEP(0) <= step_generator;
--									step_generator_counter <= step_generator_counter + 1;
--									delay <= 0;
--								end if;
--							else
--								
--							end if;
--							
--						when "010" =>
--						when "011" =>
--						when "100" =>
--						when "101" =>
--					end case;
--				
--				
--			end case;
--

