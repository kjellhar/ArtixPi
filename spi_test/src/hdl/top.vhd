----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2016 03:43:39 AM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port ( clk1 : in STD_LOGIC;
           clk1_en : out STD_LOGIC;
           usr_led1 : out std_logic;
           usr_led2 : out std_logic;
           PI_GPIO8 : in std_logic;     -- SPI SS_N
           PI_GPIO9 : in std_logic;     -- SPI_CLK
           PI_GPIO10 : in std_logic;    -- SPI_MOSI
           PI_GPIO11 : out std_logic);  -- SPI_MISO
end top;

architecture Behavioral of top is

    component clk_wiz_0
    port (-- Clock in ports
        clk_in1           : in     std_logic;
        -- Clock out ports
        clk_out1          : out    std_logic);
    end component;
    
    component spi_slave
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
    end component;    
    

    signal clk100m : std_logic; 
    
    signal spi_busy : std_logic;
    signal spi_data_valid : std_logic;
    signal spi_reg_in : std_logic_vector(7 downto 0);
    signal spi_reg_out : std_logic_vector(7 downto 0) := "00000000";
       
begin
    clkgen : clk_wiz_0
        port map ( 
            -- Clock in ports
            clk_in1 => clk1,
            -- Clock out ports  
            clk_out1 => clk100m              
        );
        
    clk1_en <= '1';
    
    
    u_spi_slave : spi_slave
        port map (
            clk => clk100m,
            enable => '1',
            spi_ss_n => PI_GPIO8,
            spi_clk => PI_GPIO9,
            spi_mosi => PI_GPIO10,
            spi_miso => PI_GPIO11,
            reg_in => spi_reg_in,
            reg_out => spi_reg_out,
            busy => spi_busy,
            data_valid => spi_data_valid
        );
        
        usr_led1 <= spi_reg_in(0);
        usr_led2 <= spi_reg_in(1);

end Behavioral;
