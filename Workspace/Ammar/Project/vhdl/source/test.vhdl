library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vector_sorter is
    port (
        in_vector_1: in std_logic_vector(15 downto 0);
        in_vector_2: in std_logic_vector(15 downto 0);
        in_vector_3: in std_logic_vector(15 downto 0);
        in_vector_4: in std_logic_vector(15 downto 0);
        out_vector_1: out std_logic_vector(15 downto 0);
        out_vector_2: out std_logic_vector(15 downto 0);
        out_vector_3: out std_logic_vector(15 downto 0);
        out_vector_4: out std_logic_vector(15 downto 0)
    );
end entity;

architecture sort_arch of vector_sorter is
    signal temp_vector_1: std_logic_vector(15 downto 0) := (others => '0');
    signal temp_vector_2: std_logic_vector(15 downto 0) := (others => '0');
    signal temp_vector_3: std_logic_vector(15 downto 0) := (others => '0');
    signal temp_vector_4: std_logic_vector(15 downto 0) := (others => '0');
begin
    process (in_vector_1, in_vector_2, in_vector_3, in_vector_4)
        variable swapped: boolean := true;
		variable i : integer := 0;

    begin
        while swapped loop
            swapped := false;
            
            if in_vector_1 < in_vector_2 then
                temp_vector_1 <= in_vector_1;
                in_vector_1 <= in_vector_2;
                in_vector_2 <= temp_vector_1;
                swapped := true;
            end if;
            
            if in_vector_2 < in_vector_3 then
                temp_vector_2 <= in_vector_2;
                in_vector_2 <= in_vector_3;
                in_vector_3 <= temp_vector_2;
                swapped := true;
            end if;
            
            if in_vector_3 < in_vector_4 then
                temp_vector_3 <= in_vector_3;
                in_vector_3 <= in_vector_4;
                in_vector_4 <= temp_vector_3;
                swapped := true;
            end if;
        end loop;
        
        out_vector_1 <= in_vector_1;
        out_vector_2 <= in_vector_2;
        out_vector_3 <= in_vector_3;
        out_vector_4 <= in_vector_4;
    end process;
end architecture;
