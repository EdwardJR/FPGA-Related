----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:20:13 08/28/2020 
-- Design Name: 
-- Module Name:    Packet_Manager - Behavioral 
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


-- packet size 12 bits
-- 3 consecutive data ins
entity Packet_Manager is
	port (
		CLK 		: in std_logic;
		START 	: in std_logic;
		COM_IN	: in std_logic_vector(7 downto 0);
		DONE		: out std_logic;
		PACKET	: out std_logic_vector(11 downto 0)  -- 3 bits for motor select, 1 bit for direction select, 8 bits for steps
	);

end Packet_Manager;

architecture Behavioral of Packet_Manager is
	-- packet 
	signal direction		: std_logic_vector(0 downto 0);
	signal steps			: std_logic_vector(7 downto 0);
	signal motor			: std_logic_vector(2 downto 0);
	signal packet_out 	: std_logic_vector(11 downto 0);
	signal data_valid		: std_logic;
	signal packet_ready 	: std_logic := '0';
	
	-- counter 
	signal packet_counter : integer range 0 to 2;
	
	
begin

	data_valid <= START;
	DONE <= packet_ready;
	PACKET <= packet_out;
	p_record : process(CLK) is
	begin
		if rising_edge(CLK) then
		packet_ready <= '0';
			if data_valid = '1' and packet_counter = 0 then
				
				packet_counter <= packet_counter + 1;
				packet_out(11 downto 9) <= COM_IN(2 downto 0);
			elsif data_valid = '1' and packet_counter = 1 then
				packet_counter <= packet_counter + 1;
				packet_out(8 downto 8) <= COM_IN(0 downto 0);
			elsif data_valid = '1' and packet_counter = 2 then
				packet_counter <= 0;
				packet_out(7 downto 0) <= COM_IN(7 downto 0);
				packet_ready <= '1';
			end if;
		end if;
	end process p_record;

end Behavioral;

