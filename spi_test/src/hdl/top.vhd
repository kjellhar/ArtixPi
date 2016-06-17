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
use IEEE.numeric_std.all;

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
           PI_GPIO9 : out std_logic;     -- SPI_MISO
           PI_GPIO10 : in std_logic;    -- SPI_MOSI
           PI_GPIO11 : in std_logic);  -- SPI_CLK
end top;

architecture Behavioral of top is

    component clk_wiz_0
    port (-- Clock in ports
        clk_in1           : in     std_logic;
        -- Clock out ports
        clk_out1          : out    std_logic);
    end component;
    
    component spi_slave 
        Generic (
            N : positive := 8;
            CPOL : std_logic := '0';           
            CPHA : std_logic := '0'        
            );
    
        Port ( clk : in STD_LOGIC;
                
               -- External SPI signals  
               spi_ss_n : in STD_LOGIC;
               spi_clk : in STD_LOGIC;
               spi_mosi : in STD_LOGIC;
               spi_miso : out STD_LOGIC;
               
               -- Internal data signals
               di : out STD_LOGIC_VECTOR (N-1 downto 0);        -- Data received from SPI
               do : in STD_LOGIC_VECTOR (N-1 downto 0);         -- Data to be transmitted over SPI
               
               di_valid : out std_logic;     -- High for one clock cycle to indicate a new word is present
               do_wren : in std_logic;       -- Write a data word to the transmit register               
               do_wrack : out std_logic);    -- High for one clock cycle when the transmission starts.
                                             -- The next data word can be written as soon as this signal goes low.
     end component;
    

    signal clk100m : std_logic; 
    
    signal do_req : std_logic;
    signal di_valid : std_logic;
    signal do : std_logic_vector(7 downto 0);
    signal di : std_logic_vector(7 downto 0);
    signal do_wren : std_logic := '0';
    signal do_wrack : std_logic;
    
    signal reg_do : std_logic_vector (7 downto 0) := "00000000";
    signal reg_di : std_logic_vector (7 downto 0);
       
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
        generic map (
            N => 8,
            CPOL => '0',
            CPHA => '0'
        )
        port map (
            clk => clk100m,
            spi_ss_n => PI_GPIO8,
            spi_clk => PI_GPIO11,
            spi_mosi => PI_GPIO10,
            spi_miso => PI_GPIO9,

            di => di,
            do => do,
             
            di_valid => di_valid,
            do_wren => do_wren,               
            do_wrack => do_wrack    
        );
        
        
        
    process
        variable counter : integer range 0 to 255 := 0;
    
    begin
        wait until rising_edge (clk100m);
        
        if di_valid='1' then
            reg_di <= di;      
            counter := counter + 1;
            
            reg_do <= std_logic_vector (TO_UNSIGNED(counter, 8));
        end if;
        
        if di_valid='1' then
            do_wren <= '1';
        else
            do_wren <= '0';
        end if;
        
        
        
    end process;
    
    usr_led1 <= reg_di(0);
    usr_led2 <= reg_di(1);
    
    do <= reg_do;

end Behavioral;
