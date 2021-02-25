----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:14:40 07/16/2020 
-- Design Name: 
-- Module Name:    UART_RX - Behavioral 
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


entity UART_RX is

	generic(
		-- 50000000Mhz clock
		-- 9600 Baud rate
		clocks_per_bit : integer := (50000000/9600) -- 5208
	);
	port(
		CLK 				: in std_logic;
		RX					: in std_logic;
		RECEIVED_DATA	: out std_logic_vector(7 downto 0);
		DATA_VALID		: out std_logic;
		state_led		: out std_logic_vector(3 downto 0)

	);

end UART_RX;

architecture Behavioral of UART_RX is

-- state signal
type state is (idle, start_bit, busy_receiving_data ,transmission_over);

-- signals
signal RX_state 		: state := idle;
signal baud_counter	: integer range 0 to (clocks_per_bit - 1) := 0;
signal bit_counter 	: integer range 0 to 8 := 0;
signal RX_buffer		: std_logic_vector(8 downto 0);

-- state machine process
begin
	p_RX : process(CLK)
	begin
		if rising_edge(CLK) then
			case RX_state is
				when idle 							=>
					DATA_VALID <= '0';
					state_led(3) <= '0';
					state_led(0) <= '1';
					if RX = '0' then
						RX_state <= start_bit;
					end if;
				when start_bit 					=>
					state_led(0) <= '0';
					state_led(1) <= '1';
					if baud_counter < (clocks_per_bit - 1)/2 then
						baud_counter <= baud_counter + 1;
					else
						if RX = '0' then
							RX_state <= busy_receiving_data;
						else
							RX_state <= idle;
						end if;
						baud_counter <= 0;
					end if;
				when busy_receiving_data		=>
					state_led(1) <= '0';
					state_led(2) <= '1';
					if baud_counter < (clocks_per_bit - 1) then
						baud_counter <= baud_counter + 1;
					else
						baud_counter <= 0;
						RX_buffer(bit_counter) <= RX;
						if bit_counter < 8 then
							bit_counter <= bit_counter + 1;
						else
							RX_state <= transmission_over;
						end if;
					end if;
				when transmission_over			=>
					state_led(2) <= '0';
					state_led(3) <= '1';
					bit_counter <= 0;
					baud_counter <= 0;
					RX_state <= idle;
					RECEIVED_DATA <= RX_buffer(7 downto 0);
					-- turns out setting DATA_VALID before switching states to transmission over can mess things up.
					DATA_VALID <= '1';
				when others 						=>
					report "I'm DONE! ";
			end case;
		end if;
	end process p_RX;
end Behavioral;

