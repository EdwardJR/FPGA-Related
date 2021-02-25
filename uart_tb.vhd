--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:56:32 09/03/2020
-- Design Name:   
-- Module Name:   A:/FPGA_FILES/UART/uart_tb.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY uart_tb IS
END uart_tb;
 
ARCHITECTURE behavior OF uart_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART
    PORT(
         CLK : IN  std_logic;
         SEG : OUT  std_logic_vector(6 downto 0);
         SEL : OUT  std_logic_vector(5 downto 0);
         RX : IN  std_logic;
         TX : OUT  std_logic;
         LED : OUT  std_logic;
         state_led : OUT  std_logic_vector(3 downto 0);
         STEP : OUT  std_logic_vector(4 downto 0);
         DIR : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RX : std_logic := '0';

 	--Outputs
   signal SEG : std_logic_vector(6 downto 0);
   signal SEL : std_logic_vector(5 downto 0);
   signal TX : std_logic;
   signal LED : std_logic;
   signal state_led : std_logic_vector(3 downto 0);
   signal STEP : std_logic_vector(4 downto 0);
   signal DIR : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART PORT MAP (
          CLK => CLK,
          SEG => SEG,
          SEL => SEL,
          RX => RX,
          TX => TX,
          LED => LED,
          state_led => state_led,
          STEP => STEP,
          DIR => DIR
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      RX <= '1';
		
		wait for 100 ns;
		
		RX <= '0';

      wait;
   end process;

END;
