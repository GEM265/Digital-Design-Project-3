library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Full Adder using only logic gates
entity full_adder is
    Port ( a, b, cin : in STD_LOGIC;
           sum, cout : out STD_LOGIC);
end full_adder;

architecture Behavioral of full_adder is
begin
    -- Sum = A XOR B XOR Cin
    sum <= a xor b xor cin;
    -- Carry = (A AND B) OR (A AND Cin) OR (B AND Cin)
    cout <= (a and b) or (a and cin) or (b and cin);
end Behavioral;

------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Adder Unit using only logic gates (Full Adders)
entity adder is
    Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
           b : in STD_LOGIC_VECTOR(5 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           r : out STD_LOGIC_VECTOR(5 downto 0));
end adder;

architecture Behavioral of adder is
    component full_adder
        Port ( a, b, cin : in STD_LOGIC;
               sum, cout : out STD_LOGIC);
    end component;
    
    signal b_inv : STD_LOGIC_VECTOR(5 downto 0);
    signal b_mux : STD_LOGIC_VECTOR(5 downto 0);
    signal carry : STD_LOGIC_VECTOR(6 downto 0);
    signal sum_out : STD_LOGIC_VECTOR(5 downto 0);
    signal cin_init : STD_LOGIC;
    
begin
    -- Invert b for subtraction (one's complement)
    b_inv <= not b;
    
    -- Select b or ~b based on sel(1) - using AND/OR gates
    gen_b_mux: for i in 0 to 5 generate
        b_mux(i) <= (b(i) and not sel(1)) or (b_inv(i) and sel(1));
    end generate;
    
    -- Initial carry: 0 for addition, 1 for subtraction (two's complement)
    cin_init <= sel(1);
    carry(0) <= cin_init;
    
    -- Ripple carry adder using full adders
    gen_adder: for i in 0 to 5 generate
        fa: full_adder port map(
            a => a(i),
            b => b_mux(i),
            cin => carry(i),
            sum => sum_out(i),
            cout => carry(i+1)
        );
    end generate;
    
    -- Output selection using multiplexer built from logic gates
    with sel select
        r <= sum_out when "00",                    -- Addition result
             "00000" & carry(6) when "01",         -- Addition carry
             sum_out when "10",                    -- Subtraction result  
             "00000" & (not carry(6)) when "11",   -- Subtraction borrow
             "000000" when others;
            
end Behavioral;

------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Multiplier using only logic gates (Array Multiplier)
entity mult is
    Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
           b : in STD_LOGIC_VECTOR(5 downto 0);
           sel : in STD_LOGIC;
           r : out STD_LOGIC_VECTOR(5 downto 0));
end mult;

architecture Behavioral of mult is
    component full_adder
        Port ( a, b, cin : in STD_LOGIC;
               sum, cout : out STD_LOGIC);
    end component;
    
    -- Partial products (6x6 array)
    signal pp : STD_LOGIC_VECTOR(35 downto 0); -- 6x6 = 36 partial products
    
    -- Intermediate sums and carries for array multiplier
    signal s : STD_LOGIC_VECTOR(34 downto 0); -- Sum outputs (increased size)
    signal c : STD_LOGIC_VECTOR(34 downto 0); -- Carry outputs (increased size)
    
    -- Final product
    signal product : STD_LOGIC_VECTOR(11 downto 0);
    
begin
    -- Generate partial products using AND gates
    gen_pp_row: for i in 0 to 5 generate
        gen_pp_col: for j in 0 to 5 generate
            pp(i*6 + j) <= a(j) and b(i);
        end generate;
    end generate;
    
    -- Array multiplier structure using full adders
    -- Row 0: Direct assignment (no addition needed)
    product(0) <= pp(0); -- a(0)*b(0)
    
    -- Row 1: Add pp(1) and pp(6)
    fa_1_0: full_adder port map(pp(1), pp(6), '0', s(0), c(0));
    product(1) <= s(0);
    
    -- Row 2: Add pp(2), pp(7), pp(12) with carry from row 1
    fa_2_0: full_adder port map(pp(2), pp(7), c(0), s(1), c(1));
    fa_2_1: full_adder port map(s(1), pp(12), '0', s(2), c(2));
    product(2) <= s(2);
    
    -- Row 3: Add pp(3), pp(8), pp(13), pp(18) with carries
    fa_3_0: full_adder port map(pp(3), pp(8), c(1), s(3), c(3));
    fa_3_1: full_adder port map(s(3), pp(13), c(2), s(4), c(4));
    fa_3_2: full_adder port map(s(4), pp(18), '0', s(5), c(5));
    product(3) <= s(5);
    
    -- Row 4: Add pp(4), pp(9), pp(14), pp(19), pp(24) with carries
    fa_4_0: full_adder port map(pp(4), pp(9), c(3), s(6), c(6));
    fa_4_1: full_adder port map(s(6), pp(14), c(4), s(7), c(7));
    fa_4_2: full_adder port map(s(7), pp(19), c(5), s(8), c(8));
    fa_4_3: full_adder port map(s(8), pp(24), '0', s(9), c(9));
    product(4) <= s(9);
    
    -- Row 5: Add pp(5), pp(10), pp(15), pp(20), pp(25), pp(30) with carries
    fa_5_0: full_adder port map(pp(5), pp(10), c(6), s(10), c(10));
    fa_5_1: full_adder port map(s(10), pp(15), c(7), s(11), c(11));
    fa_5_2: full_adder port map(s(11), pp(20), c(8), s(12), c(12));
    fa_5_3: full_adder port map(s(12), pp(25), c(9), s(13), c(13));
    fa_5_4: full_adder port map(s(13), pp(30), '0', s(14), c(14));
    product(5) <= s(14);
    
    -- Row 6: Continue for remaining rows to get full 12-bit product
    fa_6_0: full_adder port map(pp(11), pp(16), c(10), s(15), c(15));
    fa_6_1: full_adder port map(s(15), pp(21), c(11), s(16), c(16));
    fa_6_2: full_adder port map(s(16), pp(26), c(12), s(17), c(17));
    fa_6_3: full_adder port map(s(17), pp(31), c(13), s(18), c(18));
    fa_6_4: full_adder port map(s(18), '0', c(14), s(19), c(19));
    product(6) <= s(19);
    
    -- Row 7
    fa_7_0: full_adder port map(pp(17), pp(22), c(15), s(20), c(20));
    fa_7_1: full_adder port map(s(20), pp(27), c(16), s(21), c(21));
    fa_7_2: full_adder port map(s(21), pp(32), c(17), s(22), c(22));
    fa_7_3: full_adder port map(s(22), '0', c(18), s(23), c(23));
    fa_7_4: full_adder port map(s(23), '0', c(19), s(24), c(24));
    product(7) <= s(24);
    
    -- Row 8
    fa_8_0: full_adder port map(pp(23), pp(28), c(20), s(25), c(25));
    fa_8_1: full_adder port map(s(25), pp(33), c(21), s(26), c(26));
    fa_8_2: full_adder port map(s(26), '0', c(22), s(27), c(27));
    fa_8_3: full_adder port map(s(27), '0', c(23), s(28), c(28));
    fa_8_4: full_adder port map(s(28), '0', c(24), s(29), c(29));
    product(8) <= s(29);
    
    -- Row 9
    fa_9_0: full_adder port map(pp(29), pp(34), c(25), s(30), c(30));
    fa_9_1: full_adder port map(s(30), '0', c(26), s(31), c(31));
    fa_9_2: full_adder port map(s(31), '0', c(27), s(32), c(32));
    fa_9_3: full_adder port map(s(32), '0', c(28), s(33), c(33));
    fa_9_4: full_adder port map(s(33), '0', c(29), s(34), c(34));
    product(9) <= s(34);
    
    -- Final additions for highest bits
    fa_10_0: full_adder port map(pp(35), '0', c(30), product(10), product(11));
    
    -- Output selection using multiplexer built from logic gates
    gen_output: for i in 0 to 5 generate
        r(i) <= (product(i) and not sel) or (product(i+6) and sel);
    end generate;
    
end Behavioral;
------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Shifter using only logic gates (Barrel Shifter)
entity shifter is
    Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
           b : in STD_LOGIC_VECTOR(2 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           r : out STD_LOGIC_VECTOR(5 downto 0));
end shifter;

architecture Behavioral of shifter is
    -- Intermediate signals for each shift stage
    signal stage0 : STD_LOGIC_VECTOR(5 downto 0);
    signal stage1 : STD_LOGIC_VECTOR(5 downto 0);
    signal stage2 : STD_LOGIC_VECTOR(5 downto 0);
    signal stage3 : STD_LOGIC_VECTOR(5 downto 0);
    
    -- Shift direction control
    signal shift_left : STD_LOGIC;
    signal shift_right_log : STD_LOGIC;
    signal shift_right_arith : STD_LOGIC;
    
    -- Fill bits for different shift types
    signal fill_bit : STD_LOGIC;
    
begin
    -- Decode shift type using logic gates
    shift_left <= (not sel(1) and not sel(0)) or (not sel(1) and sel(0));
    shift_right_log <= sel(1) and not sel(0);
    shift_right_arith <= sel(1) and sel(0);
    
    -- Determine fill bit using logic gates only
    fill_bit <= (shift_right_arith and a(5)) or ((shift_left or shift_right_log) and '0');
    
    stage0 <= a;
    
    -- Stage 1: Shift by 1 if b(0) = 1
    -- Bit 0
    stage1(0) <= 
        (stage0(0) and (not b(0))) or                              -- No shift
        (fill_bit and shift_left and b(0)) or                      -- Left shift (fill)
        (stage0(1) and (shift_right_log or shift_right_arith) and b(0)); -- Right shift
    
    -- Bit 1    
    stage1(1) <= 
        (stage0(1) and (not b(0))) or                              -- No shift
        (stage0(0) and shift_left and b(0)) or                     -- Left shift
        (stage0(2) and (shift_right_log or shift_right_arith) and b(0)); -- Right shift
        
    -- Bit 2
    stage1(2) <= 
        (stage0(2) and (not b(0))) or                              -- No shift
        (stage0(1) and shift_left and b(0)) or                     -- Left shift
        (stage0(3) and (shift_right_log or shift_right_arith) and b(0)); -- Right shift
        
    -- Bit 3
    stage1(3) <= 
        (stage0(3) and (not b(0))) or                              -- No shift
        (stage0(2) and shift_left and b(0)) or                     -- Left shift
        (stage0(4) and (shift_right_log or shift_right_arith) and b(0)); -- Right shift
        
    -- Bit 4
    stage1(4) <= 
        (stage0(4) and (not b(0))) or                              -- No shift
        (stage0(3) and shift_left and b(0)) or                     -- Left shift
        (stage0(5) and (shift_right_log or shift_right_arith) and b(0)); -- Right shift
        
    -- Bit 5
    stage1(5) <= 
        (stage0(5) and (not b(0))) or                              -- No shift
        (stage0(4) and shift_left and b(0)) or                     -- Left shift
        (fill_bit and (shift_right_log or shift_right_arith) and b(0)); -- Right shift (fill)
    
    -- Stage 2: Shift by 2 if b(1) = 1
    -- Bit 0
    stage2(0) <= 
        (stage1(0) and (not b(1))) or                              -- No shift
        (fill_bit and shift_left and b(1)) or                      -- Left shift (fill)
        (stage1(2) and (shift_right_log or shift_right_arith) and b(1)); -- Right shift
        
    -- Bit 1
    stage2(1) <= 
        (stage1(1) and (not b(1))) or                              -- No shift
        (fill_bit and shift_left and b(1)) or                      -- Left shift (fill)
        (stage1(3) and (shift_right_log or shift_right_arith) and b(1)); -- Right shift
        
    -- Bit 2
    stage2(2) <= 
        (stage1(2) and (not b(1))) or                              -- No shift
        (stage1(0) and shift_left and b(1)) or                     -- Left shift
        (stage1(4) and (shift_right_log or shift_right_arith) and b(1)); -- Right shift
        
    -- Bit 3
    stage2(3) <= 
        (stage1(3) and (not b(1))) or                              -- No shift
        (stage1(1) and shift_left and b(1)) or                     -- Left shift
        (stage1(5) and (shift_right_log or shift_right_arith) and b(1)); -- Right shift
        
    -- Bit 4
    stage2(4) <= 
        (stage1(4) and (not b(1))) or                              -- No shift
        (stage1(2) and shift_left and b(1)) or                     -- Left shift
        (fill_bit and (shift_right_log or shift_right_arith) and b(1)); -- Right shift (fill)
        
    -- Bit 5
    stage2(5) <= 
        (stage1(5) and (not b(1))) or                              -- No shift
        (stage1(3) and shift_left and b(1)) or                     -- Left shift
        (fill_bit and (shift_right_log or shift_right_arith) and b(1)); -- Right shift (fill)
    
    -- Stage 3: Shift by 4 if b(2) = 1
    -- Bit 0
    stage3(0) <= 
        (stage2(0) and (not b(2))) or                              -- No shift
        (fill_bit and shift_left and b(2)) or                      -- Left shift (fill)
        (stage2(4) and (shift_right_log or shift_right_arith) and b(2)); -- Right shift
        
    -- Bit 1
    stage3(1) <= 
        (stage2(1) and (not b(2))) or                              -- No shift
        (fill_bit and shift_left and b(2)) or                      -- Left shift (fill)
        (stage2(5) and (shift_right_log or shift_right_arith) and b(2)); -- Right shift
        
    -- Bit 2
    stage3(2) <= 
        (stage2(2) and (not b(2))) or                              -- No shift
        (fill_bit and shift_left and b(2)) or                      -- Left shift (fill)
        (fill_bit and (shift_right_log or shift_right_arith) and b(2)); -- Right shift (fill)
        
    -- Bit 3
    stage3(3) <= 
        (stage2(3) and (not b(2))) or                              -- No shift
        (fill_bit and shift_left and b(2)) or                      -- Left shift (fill)
        (fill_bit and (shift_right_log or shift_right_arith) and b(2)); -- Right shift (fill)
        
    -- Bit 4
    stage3(4) <= 
        (stage2(4) and (not b(2))) or                              -- No shift
        (stage2(0) and shift_left and b(2)) or                     -- Left shift
        (fill_bit and (shift_right_log or shift_right_arith) and b(2)); -- Right shift (fill)
        
    -- Bit 5
    stage3(5) <= 
        (stage2(5) and (not b(2))) or                              -- No shift
        (stage2(1) and shift_left and b(2)) or                     -- Left shift
        (fill_bit and (shift_right_log or shift_right_arith) and b(2)); -- Right shift (fill)
    
    r <= stage3;
    
end Behavioral;

------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Logic Unit using only logic gates
entity logic_unit is
    Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
           b : in STD_LOGIC_VECTOR(5 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           r : out STD_LOGIC_VECTOR(5 downto 0));
end logic_unit;

architecture Behavioral of logic_unit is
begin
    -- Implement multiplexer using logic gates
    gen_logic: for i in 0 to 5 generate
        r(i) <= (not a(i) and not sel(1) and not sel(0)) or        -- NOT a when sel=00
                (a(i) and b(i) and not sel(1) and sel(0)) or       -- AND when sel=01
                ((a(i) or b(i)) and sel(1) and not sel(0)) or      -- OR when sel=10
                ((a(i) xor b(i)) and sel(1) and sel(0));           -- XOR when sel=11
    end generate;
end Behavioral;

------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Main ALU Implementation
entity alu is
    Port ( sel : in STD_LOGIC_VECTOR(3 downto 0);
           a : in STD_LOGIC_VECTOR(5 downto 0);
           b : in STD_LOGIC_VECTOR(5 downto 0);
           r : out STD_LOGIC_VECTOR(5 downto 0));
end alu;

architecture Behavioral of alu is
    component adder
        Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
               b : in STD_LOGIC_VECTOR(5 downto 0);
               sel : in STD_LOGIC_VECTOR(1 downto 0);
               r : out STD_LOGIC_VECTOR(5 downto 0));
    end component;
    
    component mult
        Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
               b : in STD_LOGIC_VECTOR(5 downto 0);
               sel : in STD_LOGIC;
               r : out STD_LOGIC_VECTOR(5 downto 0));
    end component;
    
    component logic_unit
        Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
               b : in STD_LOGIC_VECTOR(5 downto 0);
               sel : in STD_LOGIC_VECTOR(1 downto 0);
               r : out STD_LOGIC_VECTOR(5 downto 0));
    end component;
    
    component shifter
        Port ( a : in STD_LOGIC_VECTOR(5 downto 0);
               b : in STD_LOGIC_VECTOR(2 downto 0);
               sel : in STD_LOGIC_VECTOR(1 downto 0);
               r : out STD_LOGIC_VECTOR(5 downto 0));
    end component;
    
    signal adder_out : STD_LOGIC_VECTOR(5 downto 0);
    signal mult_out : STD_LOGIC_VECTOR(5 downto 0);
    signal logic_out : STD_LOGIC_VECTOR(5 downto 0);
    signal shifter_out : STD_LOGIC_VECTOR(5 downto 0);
    
begin
    -- Instantiate all units
    adder_inst: adder port map(
        a => a,
        b => b,
        sel => sel(1 downto 0),
        r => adder_out
    );
    
    mult_inst: mult port map(
        a => a,
        b => b,
        sel => sel(0),
        r => mult_out
    );
    
    logic_inst: logic_unit port map(
        a => a,
        b => b,
        sel => sel(1 downto 0),
        r => logic_out
    );
    
    shifter_inst: shifter port map(
        a => a,
        b => b(2 downto 0),
        sel => sel(1 downto 0),
        r => shifter_out
    );
    
    -- Output multiplexer using logic gates
    gen_output: for i in 0 to 5 generate
        r(i) <= (adder_out(i) and not sel(3) and not sel(2)) or     -- 00: Adder
                (mult_out(i) and not sel(3) and sel(2)) or          -- 01: Multiplier
                (logic_out(i) and sel(3) and not sel(2)) or         -- 10: Logic
                (shifter_out(i) and sel(3) and sel(2));             -- 11: Shifter
    end generate;
    
end Behavioral;