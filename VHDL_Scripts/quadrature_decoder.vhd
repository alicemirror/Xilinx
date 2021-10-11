----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.07.2021 21:17:08
-- Design Name: 
-- Module Name: quadrature_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- for blog post
-- 
-- Based on
-- https://www.hackmeister.dk/2010/07/using-a-quadrature-encoder-as-input-to-fpga/
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity quadrature_decoder is
    Port ( QuadA : in  STD_LOGIC;
           QuadB : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           nReset : in STD_LOGIC;
           Position : out  unsigned (5 downto 0));
end quadrature_decoder;

architecture Behavioral of quadrature_decoder is

signal QuadA_Delayed: std_logic_vector(2 downto 0) := (others=>'0');
signal QuadB_Delayed: std_logic_vector(2 downto 0) := (others=>'0');

signal Count_Enable: STD_LOGIC;
signal Count_Direction: STD_LOGIC;

-- signal Count: unsigned(5 downto 0) := "000000";
signal Count: unsigned(Position'length-1 downto 0) := (others=>'0');

begin

process (Clk, nReset)
begin
   if (nReset = '0') then
      Count <= (others=>'0');
      QuadA_Delayed <= (others=>'0');
      QuadB_Delayed <= (others=>'0');
   elsif rising_edge(Clk) then
      QuadA_Delayed <= (QuadA_Delayed(1), QuadA_Delayed(0), QuadA);
      QuadB_Delayed <= (QuadB_Delayed(1), QuadB_Delayed(0), QuadB);
      if Count_Enable='1' then
         if Count_Direction='1' then
            Count <= Count + 1;
            Position <= Count;
         else
            Count <= Count - 1;
            Position <= Count;
         end if;
      end if;
   end if;
end process;

Count_Enable <= QuadA_Delayed(1) xor QuadA_Delayed(2) xor QuadB_Delayed(1)
            xor QuadB_Delayed(2);
Count_Direction <= QuadA_Delayed(1) xor QuadB_Delayed(2);

end Behavioral;
