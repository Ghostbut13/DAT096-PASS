LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity shift_register is
    generic (
        num_vectors : positive := 4    -- number of std_logic_vectors in the shift register
   );
    port (
        clk : in std_logic;            -- clock input
        reset : in std_logic;          -- reset input
        data_in : in std_logic_vector(num_vectors-1 downto 0);   -- input data
        shift_out : out std_logic_vector(num_vectors-1 downto 0)  -- output data
    );
end shift_register;

architecture Behavioral of shift_register is
    type reg_type is array(0 to num_vectors-1) of std_logic_vector(data_in'range);
    signal reg : reg_type := (others => (others => '0'));  -- initialize the register to all zeros

begin
    process (clk, reset)
    begin
        if reset = '1' then
            reg <= (others => (others => '0'));  -- reset the register to all zeros
        elsif rising_edge(clk) then
            reg(0) <= data_in;  -- input data goes into first vector in register
            for i in 1 to num_vectors-1 loop
                reg(i) <= reg(i-1);  -- shift data through the register
            end loop;
        end if;
    end process;

    shift_out <= reg(num_vectors-1) when not reset = '1' else (others => '0');  -- output data from last vector in register
end Behavioral;
