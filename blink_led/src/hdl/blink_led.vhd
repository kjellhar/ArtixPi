----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2016 03:17:35 AM
-- Design Name: 
-- Module Name: blink_led - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blink_led is
    Port ( 
        clk1 : in STD_LOGIC;
        clk1_en : out std_logic;
        usr_led1 : out std_logic;
        usr_led2 : out std_logic);
end blink_led;

architecture Behavioral of blink_led is

    constant div1_period : integer := 100000000;
    constant div2_period : integer := 30000000;

    component clk_wiz_0
    port (-- Clock in ports
        clk_in1           : in     std_logic;
     -- Clock out ports
        clk_out1          : out    std_logic);
    end component;

    signal clk100m : std_logic;
    signal clk_en_i : std_logic := '1';    
    signal div1 : integer range 0 to div1_period/2 - 1 := 0;
    signal div2 : integer range 0 to div2_period/2 - 1 := 0;
    
    signal led1 : std_logic := '0';
    signal led2 : std_logic := '0';


begin
    clkgen : clk_wiz_0
    port map ( 
        -- Clock in ports
        clk_in1 => clk1,
        -- Clock out ports  
        clk_out1 => clk100m              
    );
    
    
    process
    begin
        wait until rising_edge(clk100m);
        div1 <= div1 + 1;
        div2 <= div2 + 1;
        
        if div1 = 0 then
            led1 <= not led1;
        end if;
        
        if div2 = 0 then
            led2 <= not led2;
        end if;
    
    end process;

    usr_led1 <= led1;
    usr_led2 <= led2;
    clk1_en <= clk_en_i;


end Behavioral;
