----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:48:40 07/17/2020 
-- Design Name: 
-- Module Name:    Buffer - Behavioral 
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

-- implementing a ring buffer

entity ring_buffer is
	generic(
		RAM_DEPTH	: natural := 1024;
		RAM_WIDTH	: natural := 8
	);
	port(
		CLK 			: in std_logic;
		reset			: in std_logic;
		DATA_IN		: in std_logic_vector(RAM_WIDTH - 1 downto 0);
		DATA_OUT 	: out std_logic_vector(RAM_WIDTH - 1 downto 0);
		
		-- write port
		write_en		: in std_logic;
		
		-- read port
		read_en		: in std_logic;
		read_valid	: out std_logic;
		
		-- flags
		empty			: out std_logic;	
		empty_next	: out std_logic;
		full			: out std_logic;
		full_next	: out std_logic;
		
		-- FIFO element count
		fill_count	: out integer range RAM_DEPTH - 1 downto 0
	);
	

end ring_buffer;

architecture Behavioral of ring_buffer is

	-- signals and custom ram type
	type ram_type is array(0 to RAM_DEPTH - 1) of std_logic_vector(DATA_IN'range);
	signal ram 	: ram_type;
	
	-- new subtype; integer with the length of the RAM.
	subtype index_type is integer range ram_type'range;
	signal head	: index_type;
	signal tail	: index_type;
	
	signal empty_i			: std_logic;
	signal full_i 			: std_logic;
	signal fill_count_i	: integer range RAM_DEPTH - 1 downto 0;
	
	-- using a custom wrapper to wrap head and tail around because they are integers
	PROCEDURE incr(signal index : inout index_type) is
	begin
		if index = index_type'high then
			index <= index_type'low;
		else
			index <= index + 1;
		end if;
	end PROCEDURE;
begin
	-- internal signals to output ports
	empty 		<= empty_i;
	full			<= full_i;
	fill_count	<= fill_count_i;
	
	empty_i 		<= '1' when fill_count_i = 0 else '0';
	empty_next	<= '1' when fill_count_i <= 1 else '0';
	
	full_i		<= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';
	full_next 	<= '1' when fill_count_i >= RAM_DEPTH - 2 else '0';
	
	p_head : process(CLK) is
	begin
		if rising_edge(CLK) then
			if reset = '1' then
				head <= 0;
			else
				if write_en = '1' and full_i = '0' then
					incr(head);
				end if;
			end if;
		end if;
	end process p_head;
	p_tail : process(CLK) is
	begin
		if rising_edge(CLK) then
			if reset = '1' then
				tail <= 0;
				read_valid <= '0';
			else
				read_valid <= '0';
				if read_en = '1' and empty_i = '0' then
					incr(tail);
					read_valid <= '1';
				end if;
			end if;
		end if;
	end process p_tail;
	
	-- This is how we infer block ram in ISE
	-- Basically you have to read and write every clock cycle
	
	p_RAM : process(CLK) is
	begin
		if rising_edge(CLK) then
			ram(head) 	<= DATA_IN;
			DATA_OUT		<= ram(tail);
		end if;
	end process p_RAM;

	p_fill_count : process(CLK) is
	begin
		if rising_edge(CLK) then
			if head > tail then
				fill_count_i <= head - tail;
			else
				fill_count_i <= head - tail + RAM_DEPTH;
			end if;
		end if;
	end process p_fill_count;
	
end Behavioral;

