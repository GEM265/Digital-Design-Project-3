library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity alu_testbench is
end alu_testbench;

architecture Behavioral of alu_testbench is
    -- Component declaration for the ALU
    component alu
        Port ( sel : in STD_LOGIC_VECTOR(3 downto 0);
               a : in STD_LOGIC_VECTOR(5 downto 0);
               b : in STD_LOGIC_VECTOR(5 downto 0);
               r : out STD_LOGIC_VECTOR(5 downto 0));
    end component;
    
    -- Test signals
    signal sel : STD_LOGIC_VECTOR(3 downto 0);
    signal a : STD_LOGIC_VECTOR(5 downto 0);
    signal b : STD_LOGIC_VECTOR(5 downto 0);
    signal r : STD_LOGIC_VECTOR(5 downto 0);
    
    -- Clock for timing (not required for combinational logic but useful for simulation)
    signal clk : STD_LOGIC := '0';
    constant clk_period : time := 10 ns;
    
    -- Expected results type and signals
    type result_array is array (0 to 15) of STD_LOGIC_VECTOR(5 downto 0);
    signal expected_results : result_array;

begin
    -- Instantiate the ALU
    uut: alu port map (
        sel => sel,
        a => a,
        b => b,
        r => r
    );
    
    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Main test process
    test_process: process
        variable total_tests : integer := 0;
        variable passed_tests : integer := 0;
        variable line_out : line;
        
        -- Procedure to run a single test
        procedure run_test(
            test_a : in STD_LOGIC_VECTOR(5 downto 0);
            test_b : in STD_LOGIC_VECTOR(5 downto 0);
            test_sel : in STD_LOGIC_VECTOR(3 downto 0);
            expected : in STD_LOGIC_VECTOR(5 downto 0);
            operation_code : in integer
        ) is
            variable line_out : line;
        begin
            -- Apply inputs
            a <= test_a;
            b <= test_b;
            sel <= test_sel;
            wait for 20 ns; -- Allow propagation
            
            -- Check result
            total_tests := total_tests + 1;
            if r = expected then
                passed_tests := passed_tests + 1;
                write(line_out, string'("PASS: "));
            else
                write(line_out, string'("FAIL: "));
            end if;
            
            -- Write operation name based on code
            case operation_code is
                when 0 => write(line_out, string'("Addition"));
                when 1 => write(line_out, string'("Addition Carry"));
                when 2 => write(line_out, string'("Subtraction"));
                when 3 => write(line_out, string'("Subtraction Borrow"));
                when 4 => write(line_out, string'("Multiplication Low"));
                when 5 => write(line_out, string'("Multiplication High"));
                when 6 => write(line_out, string'("Multiplication Low"));
                when 7 => write(line_out, string'("Multiplication High"));
                when 8 => write(line_out, string'("Bitwise NOT"));
                when 9 => write(line_out, string'("Bitwise AND"));
                when 10 => write(line_out, string'("Bitwise OR"));
                when 11 => write(line_out, string'("Bitwise XOR"));
                when 12 => write(line_out, string'("Shift Left Logical"));
                when 13 => write(line_out, string'("Shift Left Logical"));
                when 14 => write(line_out, string'("Shift Right Logical"));
                when 15 => write(line_out, string'("Shift Right Arithmetic"));
                when others => write(line_out, string'("Unknown"));
            end case;
            
            write(line_out, string'(" | a="));
            write(line_out, to_integer(unsigned(test_a)));
            write(line_out, string'(" b="));
            write(line_out, to_integer(unsigned(test_b)));
            write(line_out, string'(" sel="));
            write(line_out, to_integer(unsigned(test_sel)));
            write(line_out, string'(" | Expected="));
            write(line_out, to_integer(unsigned(expected)));
            write(line_out, string'(" Got="));
            write(line_out, to_integer(unsigned(r)));
            writeline(output, line_out);
        end procedure;
        
    begin
        write(line_out, string'("=== ALU Testbench Started ==="));
        writeline(output, line_out);
        
        -- Test Case 1: a = 4, b = 2
        write(line_out, string'("Test Case 1: a = 4 (000100), b = 2 (000010)"));
        writeline(output, line_out);
        
        -- Calculate expected results for test case 1
        expected_results(0) <= "000110";  -- 4 + 2 = 6
        expected_results(1) <= "000000";  -- carry of 4+2 = 0
        expected_results(2) <= "000010";  -- 4 - 2 = 2
        expected_results(3) <= "000000";  -- borrow of 4-2 = 0
        expected_results(4) <= "001000";  -- low 6 bits of 4*2 = 8
        expected_results(5) <= "000000";  -- high 6 bits of 4*2 = 0
        expected_results(6) <= "001000";  -- same as 4
        expected_results(7) <= "000000";  -- same as 5
        expected_results(8) <= "111011";  -- NOT 4 = NOT(000100) = 111011
        expected_results(9) <= "000000";  -- 4 AND 2 = 000100 AND 000010 = 000000
        expected_results(10) <= "000110"; -- 4 OR 2 = 000100 OR 000010 = 000110
        expected_results(11) <= "000110"; -- 4 XOR 2 = 000100 XOR 000010 = 000110
        expected_results(12) <= "010000"; -- 4 << 2 = 000100 << 2 = 010000
        expected_results(13) <= "010000"; -- same as 12
        expected_results(14) <= "000001"; -- 4 >> 2 = 000100 >> 2 = 000001
        expected_results(15) <= "000001"; -- 4 >> 2 (arithmetic) = 000001
        
        for i in 0 to 15 loop
            run_test("000100", "000010", std_logic_vector(to_unsigned(i, 4)), 
                    expected_results(i), i);
        end loop;
        
        write(line_out, string'(""));
        writeline(output, line_out);
        
        -- Test Case 2: a = 49, b = 50
        write(line_out, string'("Test Case 2: a = 49 (110001), b = 50 (110010)"));
        writeline(output, line_out);
        
        -- Calculate expected results for test case 2
        expected_results(0) <= "100011";  -- 49 + 50 = 99, but 99 > 63, so 99 mod 64 = 35 = 100011
        expected_results(1) <= "000001";  -- carry of 49+50 = 1 (since 99 > 63)
        expected_results(2) <= "111111";  -- 49 - 50 = -1, in 6-bit 2's complement = 111111
        expected_results(3) <= "000001";  -- borrow of 49-50 = 1
        expected_results(4) <= "010010";  -- low 6 bits of 49*50 = 2450, 2450 mod 64 = 18 = 010010
        expected_results(5) <= "100110";  -- high 6 bits of 49*50 = 2450, 2450 div 64 = 38 = 100110
        expected_results(6) <= "010010";  -- same as 4
        expected_results(7) <= "100110";  -- same as 5
        expected_results(8) <= "001110";  -- NOT 49 = NOT(110001) = 001110
        expected_results(9) <= "110000";  -- 49 AND 50 = 110001 AND 110010 = 110000
        expected_results(10) <= "110011"; -- 49 OR 50 = 110001 OR 110010 = 110011
        expected_results(11) <= "000011"; -- 49 XOR 50 = 110001 XOR 110010 = 000011
        expected_results(12) <= "000100"; -- 49 << 50 = 49 << (50 mod 8) = 49 << 2 = 000100
        expected_results(13) <= "000100"; -- same as 12
        expected_results(14) <= "011000"; -- 49 >> 50 = 49 >> 2 = 011000
        expected_results(15) <= "111000"; -- 49 >> 2 (arithmetic, sign extend) = 111000
        
        for i in 0 to 15 loop
            run_test("110001", "110010", std_logic_vector(to_unsigned(i, 4)), 
                    expected_results(i), i);
        end loop;
        
        write(line_out, string'(""));
        writeline(output, line_out);
        
        -- Test Case 3: a = 63, b = 63
        write(line_out, string'("Test Case 3: a = 63 (111111), b = 63 (111111)"));
        writeline(output, line_out);
        
        -- Calculate expected results for test case 3
        expected_results(0) <= "111110";  -- 63 + 63 = 126, 126 mod 64 = 62 = 111110
        expected_results(1) <= "000001";  -- carry of 63+63 = 1
        expected_results(2) <= "000000";  -- 63 - 63 = 0
        expected_results(3) <= "000000";  -- borrow of 63-63 = 0
        expected_results(4) <= "000001";  -- low 6 bits of 63*63 = 3969, 3969 mod 64 = 1 = 000001
        expected_results(5) <= "111110";  -- high 6 bits of 63*63 = 3969, 3969 div 64 = 62 = 111110
        expected_results(6) <= "000001";  -- same as 4
        expected_results(7) <= "111110";  -- same as 5
        expected_results(8) <= "000000";  -- NOT 63 = NOT(111111) = 000000
        expected_results(9) <= "111111";  -- 63 AND 63 = 111111
        expected_results(10) <= "111111"; -- 63 OR 63 = 111111
        expected_results(11) <= "000000"; -- 63 XOR 63 = 000000
        expected_results(12) <= "111000"; -- 63 << 63 = 63 << (63 mod 8) = 63 << 7 = 63 << 3 = 111000
        expected_results(13) <= "111000"; -- same as 12
        expected_results(14) <= "000111"; -- 63 >> 63 = 63 >> 7 = 63 >> 3 = 000111
        expected_results(15) <= "111111"; -- 63 >> 3 (arithmetic, sign extend) = 111111
        
        for i in 0 to 15 loop
            run_test("111111", "111111", std_logic_vector(to_unsigned(i, 4)), 
                    expected_results(i), i);
        end loop;
        
        -- Print summary
        write(line_out, string'(""));
        writeline(output, line_out);
        write(line_out, string'("=== Test Summary ==="));
        writeline(output, line_out);
        write(line_out, string'("Total Tests: "));
        write(line_out, total_tests);
        writeline(output, line_out);
        write(line_out, string'("Passed: "));
        write(line_out, passed_tests);
        writeline(output, line_out);
        write(line_out, string'("Failed: "));
        write(line_out, total_tests - passed_tests);
        writeline(output, line_out);
        
        if passed_tests = total_tests then
            write(line_out, string'("ALL TESTS PASSED!"));
        else
            write(line_out, string'("SOME TESTS FAILED!"));
        end if;
        writeline(output, line_out);
        
        write(line_out, string'("=== Testbench Complete ==="));
        writeline(output, line_out);
        
        wait; -- End simulation
    end process;

end Behavioral;