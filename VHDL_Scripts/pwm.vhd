--**********************************************************************
-- Copyright (c) 2011-2014 by XESS Corp <http://www.xess.com>.
-- All rights reserved.
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 3.0 of the License, or (at your option) any later version.
-- 
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.  If not, see 
-- <http://www.gnu.org/licenses/>.
--**********************************************************************

--*********************************************************************
-- Module for generating repetitive pulses.
--*********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

package PulsePckg is

  constant HI   : std_logic := '1';
  constant LO   : std_logic := '0';
  constant ONE  : std_logic := '1';

end package;

--*********************************************************************
-- PWM module.
--*********************************************************************

library IEEE;
use IEEE.MATH_REAL.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.PulsePckg.all;

entity Pwm is
  port (
    n_reset_i : in  std_logic;          -- async reset
    clk_i  : in  std_logic;             -- Input clock.
    duty_i : in  std_logic_vector (5 downto 0);      -- Duty-cycle input.
    band_i : in  std_logic_vector (3 downto 0);      -- number of clock-ticks to keep both signals low before rising edge
    pwmA_o  : out std_logic;            -- PWM output.
    pwmB_o  : out std_logic             -- PWM output inverse.
    );
end entity;

architecture arch of Pwm is
  signal timer_r       : natural range 0 to 2**duty_i'length-1;
begin

  clocked: process(clk_i, n_reset_i)
  begin
    pwmA_o   <= LO;
    pwmB_o   <= LO;
    
    -- async reset
    if n_reset_i = '0' then
        timer_r <= 0;
        
    elsif rising_edge(clk_i) then
      -- timer
      timer_r <= timer_r + 1;
      -- output a
      if timer_r < unsigned(duty_i) and timer_r >= unsigned(band_i)  then
        pwmA_o <= HI;
      end if;
      -- output b
      if timer_r >= to_integer(unsigned(band_i)) + to_integer(unsigned(duty_i)) then 		
        pwmB_o <= HI;
      end if;
    end if; -- rising_edge
  end process clocked;
  
  
end architecture;
