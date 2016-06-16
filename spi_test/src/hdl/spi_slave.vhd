----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2016 04:17:04 AM
-- Design Name: 
-- Module Name: spi_slave - Behavioral
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

entity spi_slave is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           spi_ss_n : in STD_LOGIC;
           spi_clk : in STD_LOGIC;
           spi_mosi : in STD_LOGIC;
           spi_miso : out STD_LOGIC;
           reg_in : out STD_LOGIC_VECTOR (7 downto 0);
           reg_out : in STD_LOGIC_VECTOR (7 downto 0);
           busy : out STD_LOGIC;
           data_valid : out STD_LOGIC);
end spi_slave;

architecture Behavioral of spi_slave is

    signal bit_counter : integer range 0 to 7 := 0;
    signal prev_spi_clk : std_logic;
    signal reg_in_i : std_logic_vector (7 downto 0);
    signal reg_out_i : std_logic_vector (7 downto 0);

begin

    process
    
    begin
        wait until rising_edge(clk);
        busy <= '0';
        data_valid <= '0';
        
        if enable='1' then
            if spi_ss_n='1' then
                bit_counter <= 0;
                reg_out_i <= reg_out;
                
            else
                busy <= '1';
                
                -- Detect rising edge on SPI clock
                if spi_clk='1' and prev_spi_clk='0' then  
                    if bit_counter=7 then
                        bit_counter <= 0;
                        reg_in <= spi_mosi & reg_in_i(7 downto 1);
                        data_valid <= '1';
                        reg_out_i <= reg_out;
                        
                        
                    else
                        bit_counter <= bit_counter + 1;
                        reg_in_i <= spi_mosi & reg_in_i(7 downto 1);
                        
                        reg_out_i <= reg_out_i(6 downto 0) & '0';    
                    
                    end if;
                
                end if;
                prev_spi_clk <= spi_clk;
                
            end if;
            
                
        end if;
    end process;


end Behavioral;
