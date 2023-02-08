-----------------------------------
-- vec2str_package.vhdl          --
-- Conversion from std_logic and --
-- std_logic_vector to string    --
-- Sven Knutsson                 --
-----------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE vec2str_package IS
   FUNCTION vec2str(vec: STD_LOGIC)
   RETURN STRING;
   FUNCTION vec2str(vec: STD_LOGIC_VECTOR)
   RETURN STRING;
END PACKAGE vec2str_package;

PACKAGE BODY vec2str_package IS
   FUNCTION vec2str(vec: STD_LOGIC)
      RETURN STRING IS
     VARIABLE stmp:string(1 TO 1);
      BEGIN
         IF (vec = '0') THEN
            stmp(1) := '0';
         ELSIF (vec = '1') THEN
            stmp(1) := '1';
         ELSIF (vec = 'X') then
            stmp(1) := 'X';
         ELSIF (vec = 'Z') then
            stmp(1) := 'Z';
         ELSE
            stmp(1) := '-';
         END IF;
       RETURN stmp;
   END FUNCTION vec2str;

   FUNCTION vec2str(vec: STD_LOGIC_VECTOR)
      RETURN STRING IS
     VARIABLE stmp: string(vec'left+1 downto 1);
      BEGIN
         FOR i IN vec'REVERSE_RANGE LOOP
            IF (vec(i) = '0') THEN
               stmp(i+1) := '0';
            ELSIF (vec(i) = '1') THEN
               stmp(i+1) := '1';
            ELSIF (vec(i) = 'X') then
               stmp(i+1) := 'X';
            ELSIF (vec(i) = 'Z') then
               stmp(i+1) := 'Z';
            ELSE
               stmp(i+1) := '-';
            END IF;
         END LOOP;
       RETURN stmp;
   END FUNCTION vec2str;

END PACKAGE BODY vec2str_package;

