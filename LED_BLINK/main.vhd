----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:34:28 08/06/2019 
-- Design Name: 
-- Module Name:    main - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity main is
	port (
		CLK_50MHz: in std_logic;
		LED: out std_logic
--		LED2: out std_logic
	);
end main;

architecture Behavioral of main is
	signal Counter: std_logic_vector(24 downto 0);
	signal CLK_1Hz: std_logic;
--	signal CLK_05Hz: std_logic;
begin

	Prescaler: process(CLK_50MHz)
	begin
		if rising_edge(CLK_50MHz) then
			if Counter < "1011111010111100001000000" then
				Counter <= Counter + 1;
			else
				CLK_1Hz <= not CLK_1Hz;
				Counter <= (others => '0');
			end if;
		end if;
	end process Prescaler;

	LED <= CLK_1Hz;


end Behavioral;

