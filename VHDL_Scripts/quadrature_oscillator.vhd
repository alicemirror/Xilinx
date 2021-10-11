library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity quadrature_oscillator is
  Port (
    i_clk: in std_logic;
    i_nReset: in std_logic;
    o_outputs: out std_logic_vector (3 downto 0)
   );
end quadrature_oscillator;

--architecture Behavioral of quadrature_oscillator is
--  signal s_pattern: std_logic_vector (6 downto 0) := "0011001";
--  signal s_counter: natural range 0 to 3 := 0;

--begin

--process (i_clk, i_nReset)
--begin
--  if i_nReset = '0' then
--    s_counter <= 0;
--  elsif rising_edge(i_clk) then
--    if s_counter = 3 then 
--      s_counter <= 0;
--    else
--      s_counter <= s_counter + 1;
--    end if;
--    o_outputs(0) <= s_pattern(s_counter + 3); 
--    o_outputs(1) <= s_pattern(s_counter + 2); 
--    o_outputs(2) <= s_pattern(s_counter + 1); 
--    o_outputs(3) <= s_pattern(s_counter + 0);
--  end if;
--end process;

--end Behavioral;


--architecture Behavioral of quadrature_oscillator is
--  signal s_counter: UNSIGNED (1 downto 0) := "11"; -- status before clock strikes 0
--  signal s_buffer: std_logic_vector (3 downto 0) := "1100"; -- status before clock strikes 0

--begin

--process (i_clk, i_nReset)
--begin
--  if i_nReset = '0' then
--    s_counter <= "11"; -- status before clock strikes 0
--    s_buffer <= "1100"; -- status before clock strikes 0
--  elsif rising_edge(i_clk) then
--    if s_counter = "11" then 
--      s_counter <= (others => '0');
--    else
--      s_counter <= (s_counter) + 1;
--    end if;
--    s_buffer <= s_buffer (2 downto 0) & not(s_counter(1));
--    o_outputs <= s_buffer;
--  end if;
--end process;

--end Behavioral;

-- jon clift state machine
-- https://www.element14.com/community/groups/fpga-group/blog/2021/08/04/learning-xilinx-zynq-a-quadrature-oscillator#comment-283287

---------------------------------------------------------------  
--- (Filename: quad.vhd)                                    ---  
--- (Target device: 16CL016YU256C8G)                        ---  
---                                                         ---  
--- Quadrature generator                                    ---  
--- using classic two-process FSM (finite state machine)    ---  
---                                                         ---  
--- Jon Clift 5th August 2021                               ---  
---                                                         ---  
---------------------------------------------------------------  
--- Rev    Date         Comments                            ---  
--- 1.0    05-Aug-21                                        ---  
---------------------------------------------------------------  

library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

architecture arch_quad_top of quadrature_oscillator is

type StateType is (deg0, deg90, deg180, deg270);
signal present_state, next_state: StateType;
signal quad: std_logic_vector(3 downto 0);
signal next_a, next_b: std_logic;

begin

   --- first process runs from the 48MHz clock input on CLKi
   --- this moves us on to the next state
   --- and latches the new outputs

    clocked_stuff: process (i_clk) begin
        if (i_clk'event and i_clk = '1') then
            present_state <= next_state;
            quad(0) <= next_a;
            quad(1) <= next_b;
            quad(2) <= not next_a;
            quad(3) <= not next_b;
            end if;
      end process clocked_stuff;

   --- second process is all the combinatorial stuff
   --- ...what the next state is
   --- and what the outputs are going to be when clocked

    combi_stuff: process (present_state) begin
      case present_state is
         when deg0 =>
            next_state <= deg90;
            next_a <= '1';
            next_b <= '0';
         when deg90 =>
            next_state <= deg180;
            next_a <= '1';
            next_b <= '1';
         when deg180 =>
            next_state <= deg270;
            next_a <= '0';
            next_b <= '1';
         when deg270 =>
            next_state <= deg0;
            next_a <= '0';
            next_b <= '0';
         end case;
      end process combi_stuff;

      --- connect servo outs to the MKR pins

      o_outputs <= quad;

end arch_quad_top;