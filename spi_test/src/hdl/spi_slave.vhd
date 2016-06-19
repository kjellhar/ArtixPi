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
    Generic (
        N : positive := 8  
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
           
           data_valid : out std_logic;     -- High for one clock cycle to indicate a new word is present
           do_wren : in std_logic;       -- Write a data word to the transmit register               
           data_busy : out std_logic);    -- High for one clock cycle when the transmission starts.
                                         -- The next data word can be written as soon as this signal goes low.
end spi_slave;

architecture Behavioral of spi_slave is

    
    signal do_buf : std_logic_vector(N-1 downto 0);
    signal do_i : std_logic_vector(N-1 downto 0);
    
    
    -- Signals used in the spi_clk domain
    signal di_reg : std_logic_vector(N-1 downto 0);
    signal di_buf : std_logic_vector(N-1 downto 0);    
    signal in_count : integer range 0 to N-1 := 0;
    signal di_valid : std_logic;
    
    signal do_reg : std_logic_vector(N-1 downto 0);
    signal out_count : integer range 0 to N-1 := 0;
    signal do_busy : std_logic;
    
    
    
    
    -- Signals used to sync between spi_clk and clk
    signal di_valid_sr : std_logic_vector (0 to 1);
    signal do_busy_sr : std_logic_vector (0 to 1);

begin

    -- output data buffer
    process
    begin
        wait until rising_edge (clk);
        if do_wren='1' then
            do_buf <= do;
        end if;

    end process;
    
   

    -- Input shift register
    process (spi_clk, spi_ss_n)
    begin
        if spi_ss_n = '1' then
            in_count <= 0;
            
        elsif rising_edge(spi_clk) then        
            in_count <= in_count + 1;
        
            if in_count=7 then
                di_buf <= di_reg(N-2 downto 0) & spi_mosi;   
            else
                di_reg <= di_reg(N-2 downto 0) & spi_mosi;
            end if;
        end if;
    end process;

    di_valid <= '1' when in_count=7 else '0';
    
    
    -- output shift register
    process (spi_clk, spi_ss_n)
    begin
        if spi_ss_n = '1' then
            out_count <= 0;
        
        elsif falling_edge(spi_clk) then
            
            out_count <= out_count + 1;
            
            if out_count = 0 then
                do_reg <= do_buf(N-2 downto 0) & '0';
            else
                do_reg <= do_reg(N-2 downto 0) & '0';
            end if;            
        end if;
    end process;
    
    spi_miso <= do_buf(N-1) when out_count=0 else do_reg(N-1);
    do_busy <= '1' when out_count=7 else
               '1' when out_count=7 and spi_ss_n='0' else
               '0';
    
    -- Sync spi_clk -> clk
    process
    begin
        wait until rising_edge(clk);
        di_valid_sr <= di_valid & di_valid_sr(0 to 0);
        do_busy_sr <= do_busy & do_busy_sr(0 to 0);        
        
    end process;    
    
    di <= di_buf;
    data_valid <= di_valid_sr(1);
    data_busy <= do_busy_sr(1);

    

end Behavioral;
