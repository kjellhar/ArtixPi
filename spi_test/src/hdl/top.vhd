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
    
    component spi_slave is
        Generic (   
            N : positive := 32;                                             -- 32bit serial word length is default
            CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
            CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
            PREFETCH : positive := 3);                                      -- prefetch lookahead cycles
        Port (  
            clk_i : in std_logic := 'X';                                    -- internal interface clock (clocks di/do registers)
            spi_ssel_i : in std_logic := 'X';                               -- spi bus slave select line
            spi_sck_i : in std_logic := 'X';                                -- spi bus sck clock (clocks the shift register core)
            spi_mosi_i : in std_logic := 'X';                               -- spi bus mosi input
            spi_miso_o : out std_logic := 'X';                              -- spi bus spi_miso_o output
            di_req_o : out std_logic;                                       -- preload lookahead data request line
            di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel load data in (clocked in on rising edge of clk_i)
            wren_i : in std_logic := 'X';                                   -- user data write enable
            wr_ack_o : out std_logic;                                       -- write acknowledge
            do_valid_o : out std_logic;                                     -- do_o data valid strobe, valid during one clk_i rising edge.
            do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked out on falling clk_i)
            --- debug ports: can be removed for the application circuit ---
            do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
            wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
            rx_bit_next_o : out std_logic;                                  -- debug: internal rx bit
            state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
            sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
        );                      
    end component;
    

    signal clk100m : std_logic; 
    signal spi_ss_n : std_logic;
    signal spi_clk : std_logic;
    signal spi_miso : std_logic;
    signal spi_mosi : std_logic;
    
    signal di_req : std_logic;
    signal di : std_logic_vector(7 downto 0);
    signal wren : std_logic;
    signal wr_ack : std_logic;
    signal do_valid : std_logic;
    signal do : std_logic_vector (7 downto 0);    
    
    
    signal di_reg : std_logic_vector (7 downto 0) := X"00";
    signal do_reg : std_logic_vector (7 downto 0);

    signal di_data_ready : std_logic := '1';
       
begin
    clkgen : clk_wiz_0
        port map ( 
            -- Clock in ports
            clk_in1 => clk1,
            -- Clock out ports  
            clk_out1 => clk100m              
        );
        
    clk1_en <= '1';
    
    spi_ss_n <= PI_GPIO8;
    spi_clk <= PI_GPIO11;
    PI_GPIO9 <= spi_miso;
    spi_mosi <= PI_GPIO10;
    
    
    u_spi_slave : spi_slave
        Generic map (   
            N => 8,
            CPOL => '0',
            CPHA => '0',
            PREFETCH => 3)
        Port map(  
            clk_i => clk100m,
            spi_ssel_i => spi_ss_n,
            spi_sck_i => spi_clk,
            spi_mosi_i => spi_mosi,
            spi_miso_o => spi_miso,
            di_req_o => di_req,
            di_i => di,
            wren_i => wren,
            wr_ack_o => wr_ack,
            do_valid_o => do_valid,
            do_o => do);                      
        
        
        
    process
        variable counter : integer range 0 to 255 := 0;
    
    begin
        wait until rising_edge (clk100m);
 
        if do_valid = '1' then
            do_reg <= do;
        end if;            
        
        if di_data_ready = '1' then
            di_reg <= do_reg;
            wren <= '1';
            di_data_ready <= '0';
        else
            wren <= '0';
        end if;
        
        if wr_ack = '1' then
            di_data_ready <= '1';
        end if;
        
    end process;

    di <= di_reg;
    --usr_led1 <= reg_di(0);
    --usr_led2 <= reg_di(1);


end Behavioral;
