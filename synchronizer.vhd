----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:06:07 07/17/2020 
-- Design Name: 
-- Module Name:    synchronizer - Behavioral 
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

-- this component synchronizes the data flow between UART_RX and UART_TX
entity synchronizer is
	port(
		CLK 				: in std_logic;
		DATA_VALID 		: in std_logic;
		BUSY 				: in std_logic;
		TRANSMIT_OVER	: in std_logic;
		POKE				: out std_logic -- pokes the transmitter to start transmitting
	
	);
	
	

end synchronizer;

architecture Behavioral of synchronizer is

	-- signals
	signal data_wait : std_logic := '0';

begin
	p_sync : process(CLK) is
		begin
			if rising_edge(CLK) then
				if DATA_VALID = '1' and BUSY = '1' then
					data_wait <= '1';
				elsif data_wait = '0' and TRANSMIT_OVER = '1' then
					data_wait <= '0';
				end if;
			end if;
	end process p_sync;
	
	POKE <= DATA_VALID when data_wait = '0' else '1';

end Behavioral;

