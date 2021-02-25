----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:31:14 07/16/2020 
-- Design Name: 
-- Module Name:    UART_TX - Behavioral 
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


entity UART_TX is
	generic (
		clocks_per_bit : integer := (50000000/9600) -- 5208 clock cycles
		
	);

	port (
		CLK 				: in std_logic;
		DATA_IN 			: in std_logic_vector(7 downto 0);
		TX					: out std_logic;
		TRANSMIT_OVER	: out std_logic;
		BUSY				: out std_logic;
		DATA_VALID		: in std_logic
	);

end UART_TX;

architecture Behavioral of UART_TX is
	-- state machine for the transfer unit will have 3 states; idle, busy, done.
	type state is (idle, busy_transmitting_data, transmission_over);
	signal TX_state : state := idle;
	
	-- signals
	signal TX_data 		: std_logic_vector(9 downto 0) := (others => '0');
	signal bit_counter 	: integer range 0 to 9 := 0;
	signal baud_counter 	: integer range 0 to clocks_per_bit - 1 := 0;
	
	-- data buffer
	

begin
	p_TX : process(CLK) is
	begin
		if rising_edge(CLK) then
			case TX_state is
				when idle =>
				
					TX <= '1';
					TRANSMIT_OVER <= '0';
					BUSY <= '0';
					if (DATA_VALID = '1') then
						TX_state <= busy_transmitting_data;
						TX_data <= '1'&DATA_IN&'0';
						BUSY <= '1';
					end if;
				when busy_transmitting_data =>
					TX <= TX_data(bit_counter);
					if baud_counter < (clocks_per_bit - 1) then
						baud_counter <= baud_counter + 1;
					else
						baud_counter <= 0;
						if (bit_counter < 9) then
							bit_counter <= bit_counter + 1;
						else
							TX_state <= transmission_over;
						end if;
					end if;

				when transmission_over =>
					bit_counter 	<= 0;
					baud_counter 	<= 0;
					TRANSMIT_OVER 	<= '1';
					TX_state 		<= idle;
					BUSY <= '0';
					TX_data <= (others => '0');

				
			end case;
		end if;
	end process p_TX;


end Behavioral;

