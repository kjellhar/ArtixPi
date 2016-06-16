----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2016 06:00:47 AM
-- Design Name: 
-- Module Name: spi_tb1 - Behavioral
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

entity spi_tb1 is
--  Port ( );
end spi_tb1;

architecture Behavioral of spi_tb1 is

component top
    Port ( clk1 : in STD_LOGIC;
           clk1_en : out STD_LOGIC;
           usr_led1 : out std_logic;
           usr_led2 : out std_logic;
           PI_GPIO8 : in std_logic;     -- SPI SS_N
           PI_GPIO9 : in std_logic;     -- SPI_CLK
           PI_GPIO10 : in std_logic;    -- SPI_MOSI
           PI_GPIO11 : out std_logic);  -- SPI_MISO
    end component;


    signal clk1 : std_logic := '0';
    signal clk1_en : std_logic;
    signal usr_led1 : std_logic;
    signal usr_led2 : std_logic;
    signal spi_ss_n : std_logic := '1';
    signal spi_clk : std_logic := '1';
    signal spi_mosi : std_logic := '0';
    signal spi_miso : std_logic;
    
    signal test_run : std_logic := '0';
    
    
    signal data : std_logic_vector (7 downto 0) := X"3E";

    
    
begin

    process
        variable index : integer := 0;
    
    begin
        wait for 100 ns;
        test_run <= '1';
        wait for 100 ns;
    
        spi_ss_n <= '0';
        wait for 5 us;
    
        for index in 7 downto 0 loop
            spi_mosi <= data(index);
            spi_clk <= '0';
            wait for 1 us;
            spi_clk <= '1';
            wait for 1 us;
            
        end loop;
        
        wait for 5 us;
        spi_ss_n <= '1';
    
    
        wait for 10 us;
        test_run <= '0';
        
        wait;
    
    end process;


    u_dut: top 
    Port map ( 
        clk1 => clk1,
        clk1_en => clk1_en,
        usr_led1 => usr_led1,
        usr_led2 => usr_led2,
        PI_GPIO8 => spi_ss_n,
        PI_GPIO9 => spi_clk,
        PI_GPIO10 => spi_mosi,
        PI_GPIO11 => spi_miso);


    process
    begin
        wait until test_run='1';
    
        if test_run='1' then
            clk1 <= '0';
            wait for 50 ns;
            clk1 <= '1';
            wait for 50 ns;
            
        else 
            wait;
        end if;
        
    end process;

end Behavioral;
