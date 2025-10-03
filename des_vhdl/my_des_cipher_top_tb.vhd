library ieee;
use ieee.std_logic_1164.all;

entity my_des_cipher_top_tb is
    Generic (   
        CLK_PERIOD : time := 10 ns                     -- clock period (default 100MHz)
    );
end my_des_cipher_top_tb;

architecture behavior of my_des_cipher_top_tb is

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock period
    constant CLOCK_PERIOD : time := CLK_PERIOD;          -- clock

    --=============================================================================================
    -- Signals
    --=============================================================================================
    --- clock and reset signals ---
    signal clock            : std_logic := '1';                 -- 100MHz clock
    signal reset            : std_logic := '1';                 -- reset active high
    --- input data ---
    signal key_in           : std_logic_vector (0 to 63);   -- key input
    signal data_in          : std_logic_vector (0 to 63);   -- data input
    --- control signals ---
    signal funct_select     : std_logic;                        -- function select: '1' = encryption, '0' = decryption
    signal lddata           : std_logic;                        -- data strobe (active high)
    signal core_busy        : std_logic;
    signal des_out_rdy      : std_logic;
    --- output data ---
    signal data_out         : std_logic_vector (0 to 63);   -- data output

begin

    --=============================================================================================
    -- INSTANTIATION FOR THE DEVICE UNDER TEST
    --=============================================================================================
	Inst_des_cipher_top_dut: entity work.des_cipher_top
        port map(
            --
            -- Core Interface 
            --
            key_in            => key_in,            -- input for key
            
            function_select   => funct_select,      -- function	select: '1' = encryption, '0' = decryption
            
            data_in           => data_in,           -- input for data
            
            data_out          => data_out,          -- output for data
            
            lddata            => lddata,            -- data strobe (active high)
            core_busy         => core_busy,         -- active high when encrypting/decryption data 
            des_out_rdy       => des_out_rdy,       -- active high when encryption/decryption of data is done
            
            reset             => reset,             -- active high
            clock             => clock              -- master clock
            
        );

    --=============================================================================================
    -- CLOCK GENERATION
    --=============================================================================================
    clock_proc: process is
    begin
        loop
            clock <= not clock;
            wait for CLOCK_PERIOD / 2;
        end loop;
    end process clock_proc;
	 
    --=============================================================================================
    -- TEST BENCH STIMULI
    --=============================================================================================
    -- This testbench exercises the DES toplevel with the test cases.
	 
	 -- xA7m!2Qz = 7841376D2132517A
	 -- Lc#9%pHd = 4C63233925704864
	 -- qZ$Yd*0V = 715A2459642A3056
	 -- Ns&K3eMb = 4E73264B33654D62
	 -- iR@8^wTc = 695240385E775463

	 -- backflip = 6261636B666C6970  
	 -- campfire = 63616D7066697265  
	 -- driftman = 64726966746D616E  
	 -- headline = 686561646C696E65  
	 -- pinecone = 70696E65636F6E65

    test : process is
    begin
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
		  lddata            <= '1';
		  funct_select      <= '1';
		  
		  -- Key #1
		  key_in <= X"7841376D2132517A";
		  
		  data_in <= X"6261636B666C6970";
		  wait until des_out_rdy = '1';
		  data_in <= X"63616D7066697265";
		  wait until des_out_rdy = '1';
		  data_in <= X"64726966746D616E";
		  wait until des_out_rdy = '1';
		  data_in <= X"686561646C696E65";
		  wait until des_out_rdy = '1';
		  data_in <= X"70696E65636F6E65";
		  wait until des_out_rdy = '1';
		  
		  -- Key #2
		  key_in <= X"4C63233925704864";
		  
		  data_in <= X"6261636B666C6970";
		  wait until des_out_rdy = '1';
		  data_in <= X"63616D7066697265";
		  wait until des_out_rdy = '1';
		  data_in <= X"64726966746D616E";
		  wait until des_out_rdy = '1';
		  data_in <= X"686561646C696E65";
		  wait until des_out_rdy = '1';
		  data_in <= X"70696E65636F6E65";
		  wait until des_out_rdy = '1';
		  
		  -- Key #3
		  key_in <= X"715A2459642A3056";
		  
		  data_in <= X"6261636B666C6970";
		  wait until des_out_rdy = '1';
		  data_in <= X"63616D7066697265";
		  wait until des_out_rdy = '1';
		  data_in <= X"64726966746D616E";
		  wait until des_out_rdy = '1';
		  data_in <= X"686561646C696E65";
		  wait until des_out_rdy = '1';
		  data_in <= X"70696E65636F6E65";
		  wait until des_out_rdy = '1';
		  
		  -- Key #4
		  key_in <= X"4E73264B33654D62";
		  
		  data_in <= X"6261636B666C6970";
		  wait until des_out_rdy = '1';
		  data_in <= X"63616D7066697265";
		  wait until des_out_rdy = '1';
		  data_in <= X"64726966746D616E";
		  wait until des_out_rdy = '1';
		  data_in <= X"686561646C696E65";
		  wait until des_out_rdy = '1';
		  data_in <= X"70696E65636F6E65";
		  wait until des_out_rdy = '1';
		  
		  -- Key #5
		  key_in <= X"695240385E775463";
		  
		  data_in <= X"6261636B666C6970";
		  wait until des_out_rdy = '1';
		  data_in <= X"63616D7066697265";
		  wait until des_out_rdy = '1';
		  data_in <= X"64726966746D616E";
		  wait until des_out_rdy = '1';
		  data_in <= X"686561646C696E65";
		  wait until des_out_rdy = '1';
		  data_in <= X"70696E65636F6E65";
		  wait until des_out_rdy = '1';
		  
		  -- Ciphertextin.txt in hexadecimal:
		  -- 96D482941F0F8105
		  -- C96671268BB68A6C
		  -- 061FBAF6A4B93742
		  -- F6E25C30FD1B6766
		  -- 16944D7BFF7F4E9A
		  
		  funct_select      <= '0';
		  
		  -- Key #1
		  key_in <= X"7841376D2132517A";
		  
		  data_in <= X"96D482941F0F8105";
		  wait until des_out_rdy = '1';
		  data_in <= X"C96671268BB68A6C";
		  wait until des_out_rdy = '1';
		  data_in <= X"061FBAF6A4B93742";
		  wait until des_out_rdy = '1';
		  data_in <= X"F6E25C30FD1B6766";
		  wait until des_out_rdy = '1';
		  data_in <= X"16944D7BFF7F4E9A";
		  wait until des_out_rdy = '1';
		  
		  -- Key #2
		  key_in <= X"4C63233925704864";
		  
		  data_in <= X"96D482941F0F8105";
		  wait until des_out_rdy = '1';
		  data_in <= X"C96671268BB68A6C";
		  wait until des_out_rdy = '1';
		  data_in <= X"061FBAF6A4B93742";
		  wait until des_out_rdy = '1';
		  data_in <= X"F6E25C30FD1B6766";
		  wait until des_out_rdy = '1';
		  data_in <= X"16944D7BFF7F4E9A";
		  wait until des_out_rdy = '1';
		  
		  -- Key #3
		  key_in <= X"715A2459642A3056";
		  
		  data_in <= X"96D482941F0F8105";
		  wait until des_out_rdy = '1';
		  data_in <= X"C96671268BB68A6C";
		  wait until des_out_rdy = '1';
		  data_in <= X"061FBAF6A4B93742";
		  wait until des_out_rdy = '1';
		  data_in <= X"F6E25C30FD1B6766";
		  wait until des_out_rdy = '1';
		  data_in <= X"16944D7BFF7F4E9A";
		  wait until des_out_rdy = '1';
		  
		  -- Key #4
		  key_in <= X"4E73264B33654D62";
		  
		  data_in <= X"96D482941F0F8105";
		  wait until des_out_rdy = '1';
		  data_in <= X"C96671268BB68A6C";
		  wait until des_out_rdy = '1';
		  data_in <= X"061FBAF6A4B93742";
		  wait until des_out_rdy = '1';
		  data_in <= X"F6E25C30FD1B6766";
		  wait until des_out_rdy = '1';
		  data_in <= X"16944D7BFF7F4E9A";
		  wait until des_out_rdy = '1';
		  
		  -- Key #5
		  key_in <= X"695240385E775463";
		  
		  data_in <= X"96D482941F0F8105";
		  wait until des_out_rdy = '1';
		  data_in <= X"C96671268BB68A6C";
		  wait until des_out_rdy = '1';
		  data_in <= X"061FBAF6A4B93742";
		  wait until des_out_rdy = '1';
		  data_in <= X"F6E25C30FD1B6766";
		  wait until des_out_rdy = '1';
		  data_in <= X"16944D7BFF7F4E9A";
		  wait until des_out_rdy = '1';
		  
        reset <= '1';
        wait; -- stop simulation
    end process test;
END;