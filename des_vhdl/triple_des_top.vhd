library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity triple_des_top is
    Port (
        data_in     : in  std_logic_vector(0 to 63);
        data_out    : out std_logic_vector(0 to 63);

        key1        : in  std_logic_vector(0 to 63);
        key2        : in  std_logic_vector(0 to 63);
        key3        : in  std_logic_vector(0 to 63);

        data_ready  : in  std_logic;
        des_out_rdy : out std_logic;
        func_select : in  std_logic; -- '1' = encrypt, '0' = decrypt

        reset       : in  std_logic;
        clock       : in  std_logic
    );
end triple_des_top;

architecture Behavioral of triple_des_top is

    -- State machine definition
    type des3_state_type is (
        IDLE,
        LOAD_KEY1, RUN_DES1, WAIT_DES1,
        LOAD_KEY2, RUN_DES2, WAIT_DES2,
        LOAD_KEY3, RUN_DES3, WAIT_DES3,
        OUTPUT_READY
    );
    signal state : des3_state_type := IDLE;

    -- Internal data and keys
    signal current_key   : std_logic_vector(0 to 63);
    signal des_input     : std_logic_vector(0 to 63);
    signal des_output    : std_logic_vector(0 to 63);

    signal stage1_out, stage2_out : std_logic_vector(0 to 63);

    -- Control signals
    signal key_ready     : std_logic := '0';
    signal des_data_ready: std_logic := '0';
    signal des_done      : std_logic;
    signal des_busy      : std_logic;
    signal des_func_sel  : std_logic;
    signal key_select    : std_logic_vector(3 downto 0);
    signal key_round_in  : std_logic_vector(0 to 47);

begin

    -- Instantiate DES core
    des_inst: entity work.des_top
        port map (
            key_round_in    => key_round_in,
            data_in         => des_input,
            data_out        => des_output,

            KeySelect       => key_select,
            key_ready       => key_ready,
            data_ready      => des_data_ready,
            func_select     => des_func_sel,

            des_out_rdy     => des_done,
            core_busy       => des_busy,

            reset           => reset,
            clock           => clock
        );

    -- State machine process
    process(clock, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            des_out_rdy <= '0';
        elsif rising_edge(clock) then
            case state is

                when IDLE =>
                    des_out_rdy <= '0';
                    if data_ready = '1' then
                        des_input <= data_in;
                        state <= LOAD_KEY1;
                    end if;

                when LOAD_KEY1 =>
                    if func_select = '1' then  -- Encrypt
                        current_key <= key1;
                        des_func_sel <= '1';
                    else                       -- Decrypt
                        current_key <= key3;
                        des_func_sel <= '0';
                    end if;
                    des_data_ready <= '0';
                    state <= RUN_DES1;

                when RUN_DES1 =>
                    if key_ready = '1' then
                        des_data_ready <= '1';
                        state <= WAIT_DES1;
                    end if;

                when WAIT_DES1 =>
                    if des_done = '1' then
                        stage1_out <= des_output;
                        des_data_ready <= '0';
                        state <= LOAD_KEY2;
                    end if;

                when LOAD_KEY2 =>
                    if func_select = '1' then
                        current_key <= key2;
                        des_func_sel <= '0';
                    else
                        current_key <= key2;
                        des_func_sel <= '1';
                    end if;
                    des_data_ready <= '0';
                    state <= RUN_DES2;

                when RUN_DES2 =>
                    if key_ready = '1' then
                        des_input <= stage1_out;
                        des_data_ready <= '1';
                        state <= WAIT_DES2;
                    end if;

                when WAIT_DES2 =>
                    if des_done = '1' then
                        stage2_out <= des_output;
                        des_data_ready <= '0';
                        state <= LOAD_KEY3;
                    end if;

                when LOAD_KEY3 =>
                    if func_select = '1' then
                        current_key <= key3;
                        des_func_sel <= '1';
                    else
                        current_key <= key1;
                        des_func_sel <= '0';
                    end if;
                    des_data_ready <= '0';
                    state <= RUN_DES3;

                when RUN_DES3 =>
                    if key_ready = '1' then
                        des_input <= stage2_out;
                        des_data_ready <= '1';
                        state <= WAIT_DES3;
                    end if;

                when WAIT_DES3 =>
                    if des_done = '1' then
                        data_out <= des_output;
                        des_out_rdy <= '1';
                        des_data_ready <= '0';
                        state <= OUTPUT_READY;
                    end if;

                when OUTPUT_READY =>
                    des_out_rdy <= '1';
                    if data_ready = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

    -- Stub for key_round_in and KeySelect
    -- In practice, you must connect current_key to your key_schedule module
    -- to produce key_round_in and assert key_ready when done.

end Behavioral;
