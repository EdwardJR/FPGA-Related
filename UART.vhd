----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:16 07/15/2020 
-- Design Name: 
-- Module Name:    UART - Behavioral 
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


entity UART is
	port(
		CLK 			: in std_logic;
		SEG 			: out std_logic_vector(6 downto 0);
		SEL 			: out std_logic_vector(5 downto 0);
		RX				: in std_logic;
		TX				: out std_logic;
		LED			: out std_logic;
		state_led	: out std_logic_vector(3 downto 0);
		STEP 			: out std_logic_vector(4 downto 0);
		DIR			: out std_logic_vector(4 downto 0)
		-- STEP			: out std_logic_vector(4 downto 0);
		
	);

end UART;

architecture Behavioral of UART is
	-- uart data received
	signal uart_data 			: std_logic_vector(7 downto 0);
	signal data_valid_rx		: std_logic;
	signal data_valid_tx		: std_logic;
	signal tx_busy				: std_logic;
	signal tx_over				: std_logic;
	signal packet_signal 	: std_logic_vector(11 downto 0);
	signal packet_done		: std_logic := '0';
	-- packet debug signals
	--signal packet_view		: std_logic_vector(4 downto 0);
	signal debug				: std_logic;

	COMPONENT UART_RX
		generic(
			clocks_per_bit : integer := 50000000/9600
		);
		port(
			CLK 				: in std_logic;
			RX					: in std_logic;
			RECEIVED_DATA	: out std_logic_vector(7 downto 0);
			DATA_VALID		: out std_logic;
			state_led		: out std_logic_vector(3 downto 0)
		
		);
		end COMPONENT;
	COMPONENT UART_TX
		generic(
			clocks_per_bit : integer := 50000000/9600
		);
		port(
			CLK 				: in std_logic;
			DATA_IN 			: in std_logic_vector(7 downto 0);
			TX					: out std_logic;
			TRANSMIT_OVER  : out std_logic;
			BUSY				: out std_logic;
			DATA_VALID		: in std_logic
		
		);
		end COMPONENT;
		
	COMPONENT synchronizer
		port(
			CLK 				: in std_logic;
			DATA_VALID		: in std_logic;
			BUSY				: in std_logic;
			TRANSMIT_OVER	: in std_logic;
			POKE				: out std_logic
		);
	end COMPONENT;
	COMPONENT seven_segment_driver
		port(
			CLK 	: in std_logic;
			SEG 	: out std_logic_vector(6 downto 0);
			SEL 	: out std_logic_vector(5 downto 0);
			NUM	: in integer range 0 to 999999
		);
	end COMPONENT;
	
	COMPONENT Packet_Manager
		port(
			CLK 		: in std_logic;
			START 	: in std_logic;
			COM_IN	: in std_logic_vector(7 downto 0);
			DONE		: out std_logic;
			PACKET	: out std_logic_vector(11 downto 0)  -- 3 bits for motor select, 1 bit for direction select, 8 bits for steps
		);
	end COMPONENT;
	COMPONENT stepper_driver
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
	end COMPONENT;
	
	
	signal number : integer range 0 to 999999 := 0;
begin
-- debug
--	p_packet_view : process(CLK) is
--	begin
--		if rising_edge(CLK) then
--			if packet_done = '1' and packet_motor = '0' and packet_direction = '1' and packet_steps = '1' then
--				packet_LED(2 downto 0) <= packet_signal(11 downto 9);
--			elsif packet_done = '1' and packet_direction = '0' and packet_steps = '1' and packet_motor = '1' then
--				packet_LED(0 downto 0) <= packet_signal(8 downto 8);
--			elsif packet_done = '1' and packet_steps = '0' and packet_motor = '1' and packet_direction = '1' then
--				packet_LED(4 downto 0) <= packet_signal(4 downto 0);
--			end if;
--		end if;
--	end process p_packet_view;
	
	-- number <= uart_data;
	LED <= debug;
	number <= to_integer(unsigned(uart_data));
	
	
	Driver1 			: seven_segment_driver 
		PORT MAP (CLK => CLK, SEG => SEG, SEL => SEL, NUM => number);
	RX_RECEIVER_1 	: UART_RX
		PORT MAP (CLK => CLK, RX => RX, RECEIVED_DATA => uart_data, DATA_VALID => data_valid_rx, state_led => state_led);
	TX_TRANSCEIVER_1 : UART_TX
		PORT MAP	(CLK => CLK, DATA_IN => uart_data, TX => TX, TRANSMIT_OVER => tx_over, BUSY => tx_busy, DATA_VALID => data_valid_tx);
	RX_TX_SYNC_1	: synchronizer
		PORT MAP (CLK => CLK, DATA_VALID => data_valid_rx, BUSY => tx_busy, TRANSMIT_OVER => tx_over, POKE => data_valid_tx);
	Packet_Manager_1 : Packet_Manager
		PORT MAP (CLK => CLK, START => data_valid_rx, COM_IN => uart_data, DONE => packet_done, PACKET => packet_signal);
	stepper_driver_1 : stepper_driver
		PORT MAP (CLK => CLK, PACKET_IN => packet_signal, START_STEP => packet_done, DIR => DIR, STEP => STEP, DEBUG => debug);
end Behavioral;

