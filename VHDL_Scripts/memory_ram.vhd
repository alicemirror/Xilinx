-- from Micheal Kellett: https://www.element14.com/community/groups/fpga-group/blog/2021/07/31/cheap-cyclone-10

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.NUMERIC_STD.all;


entity mem_inf_sp_1024_12 is
     port(
         we : in STD_LOGIC;
         en : in STD_LOGIC;
         clk : in STD_LOGIC;
         address : in STD_LOGIC_VECTOR(9 downto 0);
         data : in STD_LOGIC_VECTOR(11 downto 0);
         q : out STD_LOGIC_VECTOR(11 downto 0)
         );
end mem_inf_sp_1024_12;

--}} End of automatically maintained section

architecture mem_inf_sp_1024_12 of mem_inf_sp_1024_12 is   

    type ram_type is array (0 to 1023) of std_logic_vector(11 downto 0);   -- array must be 0 - n, if declared the other way wit downto to match Xilinx example then Quartus fitter fails
    signal ram : ram_type;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if we = '1' then
                    ram(to_integer(unsigned((address)))) <= data;
                end if;
                q <= ram(to_integer(unsigned((address))));
            end if;
        end if;
    end process;

end mem_inf_sp_1024_12;


