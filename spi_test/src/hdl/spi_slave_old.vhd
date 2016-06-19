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
end spi_slave;

architecture Behavioral of spi_slave is

    -- constants to control FlipFlop synthesis
    constant CAPTURE_EDGE  : std_logic := (CPOL xnor CPHA);
    constant CHANGE_EDGE : std_logic := (CPOL xor CPHA);

    type spi_state_t is (
        IDLE,
        INIT_TRANSACTION,
        SHIFTING_DATA,
        WORD_COMPLETE
    );

    signal spi_state : spi_state_t := IDLE;
    signal spi_state_next : spi_state_t;
    
    signal spi_clk_buf : std_logic := CPOL;
    signal spi_capture_edge : std_logic;
    signal spi_change_edge : std_logic;
 
    signal di_buf : std_logic;
    signal di_reg : std_logic_vector(N-1 downto 0);
    signal do_reg : std_logic_vector(N-1 downto 0);
    signal do_i : std_logic_vector(N-1 downto 0);
    
    signal bit_counter : integer range 0 to N-1 := 0;

begin

    -- state register 
    process
    begin
        wait until rising_edge (clk);
        
        if spi_ss_n='1' then
            spi_state <= IDLE;        
        else
            spi_state <= spi_state_next;
        end if;
    end process;
    
    -- Next state logic
    process (
        spi_state,
        spi_ss_n,
        bit_counter)
    begin
     
        spi_state_next <= spi_state;
     
        case (spi_state) is
            when IDLE =>
                if spi_ss_n='0' then
                    spi_state_next <= INIT_TRANSACTION;
                end if;
            
            when INIT_TRANSACTION =>
                spi_state_next <= SHIFTING_DATA;
            
            when SHIFTING_DATA =>
                if bit_counter=N-1 then
                    spi_state_next <= WORD_COMPLETE;
                end if;
                
            when WORD_COMPLETE =>
                if bit_counter = 0 then
                    spi_state_next <= INIT_TRANSACTION;
                end if;
                
            when others => 
                spi_state_next <= IDLE;
        end case;

    
    end process;
    
    
    -- SPI clock edge detector
    process
    begin
        wait until rising_edge(clk);
        spi_clk_buf <= spi_clk;
        
        if (spi_clk_buf= not spi_clk) and spi_clk=CAPTURE_EDGE then 
            spi_capture_edge <= '1';
        else 
            spi_capture_edge <= '0';
        end if;

        if (spi_clk_buf= not spi_clk) and spi_clk=CHANGE_EDGE then 
            spi_change_edge <= '1';
        else 
            spi_change_edge <= '0';
        end if;                
    end process;

    -- Input shift register
    process
    begin
        wait until rising_edge(clk);
        di_buf <= spi_mosi;
        
        if spi_capture_edge='1' then
            di_reg <= di_reg(N-2 downto 0) & di_buf;
            bit_counter <= bit_counter + 1;
            
        end if;
    end process;
    
    
    -- output received data word
    process
    begin
        wait until rising_edge(clk);
        
        di_valid <= '0';
        
        if spi_state=WORD_COMPLETE and bit_counter=0 then
            di <= di_reg;
            di_valid <= '1';
        end if;
    end process;
    
    
    -- get data word for tx
    process
    begin
        wait until rising_edge(clk);
        
        if do_wren='1' then
            do_i <= do;
        end if;
    end process;
    
    -- output shift register
    process
    begin
        wait until rising_edge(clk);
        
        do_wrack <= '0';
        if spi_state = IDLE then
            do_reg <= X"00";
        elsif spi_state = INIT_TRANSACTION then
            do_reg <= do_i;
            do_wrack <= '1';
        elsif spi_change_edge='1' and bit_counter /= 0 then
            do_reg <= do_reg(N-2 downto 0) & '0';
        end if;
    end process;
    
    spi_miso <= do_reg(7);

end Behavioral;
