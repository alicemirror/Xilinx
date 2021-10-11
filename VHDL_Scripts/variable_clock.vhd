library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity variable_clock is
    Port ( 
      clk_i    : in  STD_LOGIC;
      resetn_i : in  STD_LOGIC;
      ticks_i  : in  STD_LOGIC_VECTOR (7 downto 0);
      clk_o    : out STD_LOGIC
    );
end variable_clock;

architecture Behavioral of variable_clock is
  signal s_counter: natural range 0 to 2**ticks_i'length-1 := 0;
  signal s_clk_out: STD_LOGIC := '0';
begin

process (clk_i, resetn_i)
begin
  if resetn_i = '0' then
    s_counter <= 0;
    s_clk_out <= '0';
  elsif rising_edge(clk_i) then
    if s_counter >= unsigned(ticks_i) then -- >= because the value can change
      s_counter <= 0;
      s_clk_out <= not s_clk_out;
    else
      s_counter <= s_counter + 1;
    end if;
    clk_o <= s_clk_out;
  end if;
end process;

end Behavioral;