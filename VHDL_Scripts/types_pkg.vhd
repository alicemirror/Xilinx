-- collection of functions used by Catalin Baetoniu for The Art of FPGA Design. 
-- https://www.element14.com/community/groups/fpga-group/blog/2018/07/11/the-art-of-fpga-design

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.all; 
use IEEE.math_real.all;  

package TYPES_PKG is
  type BOOLEAN_VECTOR is array(NATURAL range <>) of BOOLEAN;   -- this type is already defined in VHDL-2008, use only for VHDL-93 implementations
  type INTEGER_VECTOR is array(NATURAL range <>) of INTEGER;   -- this type is already defined in VHDL-2008, use only for VHDL-93 implementations
  type UNSIGNED_VECTOR is array(INTEGER range <>) of UNSIGNED; -- works only in VHDL-2008
  type SIGNED_VECTOR is array(INTEGER range <>) of SIGNED;     -- works only in VHDL-2008

  type SFIXED is array(INTEGER range <>) of STD_LOGIC;     -- arbitrary precision fixed point signed number, like SIGNED but lower bound can be negative, OK even in VHDL-93
  type SFIXED_VECTOR is array(INTEGER range <>) of SFIXED; -- unconstrained array of SFIXED, works only in VHDL-2008
  type CFIXED is record RE,IM:SFIXED; end record;          -- arbitrary precision fixed point complex signed number, works only in VHDL-2008
  type CFIXED_VECTOR is array(INTEGER range <>) of CFIXED; -- unconstrained array of CFIXED, works only in VHDL-2008

  function TO_SFIXED(R:REAL;H,L:INTEGER) return SFIXED; -- returns SFIXED(H downto L) result
  function TO_SFIXED(R:REAL;HL:SFIXED) return SFIXED; -- returns SFIXED(HL'high downto HL'low) result
  
  function RESIZE(X:SFIXED;H,L:INTEGER) return SFIXED;
  function RESIZE(X:SFIXED;HL:SFIXED) return SFIXED;
  
  function MIN(A,B:INTEGER) return INTEGER;
  function MIN(A,B,C:INTEGER) return INTEGER;
  function MIN(A,B,C,D:INTEGER) return INTEGER;
  function MED(A,B,C:INTEGER) return INTEGER;
  function MAX(A,B:INTEGER) return INTEGER;
  function MAX(A,B,C:INTEGER) return INTEGER;
  function MAX(A,B,C,D:INTEGER) return INTEGER;

  function "+"(X,Y:SFIXED) return SFIXED;
  function "*"(X,Y:SFIXED) return SFIXED;
  function "*"(X:SFIXED;Y:STD_LOGIC) return SFIXED;
end TYPES_PKG;  

package body TYPES_PKG is
  function TO_SFIXED(R:REAL;H,L:INTEGER) return SFIXED is
    variable RR:REAL;
    variable V:SFIXED(H downto L);
  begin
    assert (R<2.0**H) and (R>=-2.0**H) report "TO_SFIXED vector truncation!" severity warning;
    if R<0.0 then
      V(V'high):='1';
      RR:=R+2.0**V'high;
    else
      V(V'high):='0';
      RR:=R;
    end if;
    for K in V'high-1 downto V'low loop
      if RR>=2.0**K then
        V(K):='1';
        RR:=RR-2.0**K;
      else 
        V(K):='0';
      end if;
    end loop;
    return V;
  end; 

  function TO_SFIXED(R:REAL;HL:SFIXED) return SFIXED is
  begin
    return TO_SFIXED(R,HL'high,HL'low);
  end;  
  
  function RESIZE(X:SFIXED;H,L:INTEGER) return SFIXED is 
    variable R:SFIXED(H downto L);
  begin 
    for K in R'range loop 
      if K<X'low then 
        R(K):='0';           -- zero pad X LSBs 
      elsif K>X'high then 
        R(K):=X(X'high);     -- sign extend X MSBs 
      else 
        R(K):=X(K);
      end if;
    end loop;
    return R;
  end;

  function RESIZE(X:SFIXED;HL:SFIXED) return SFIXED is 
  begin 
    return RESIZE(X,HL'high,HL'low);
  end; 

  function MIN(A,B:INTEGER) return INTEGER is
  begin
    if A<B then
      return A;
    else
      return B;
    end if;
  end;

  function MIN(A,B,C:INTEGER) return INTEGER is
  begin
    return MIN(MIN(A,B),C);
  end;

  function MIN(A,B,C,D:INTEGER) return INTEGER is
  begin
    return MIN(MIN(A,B),MIN(C,D));
  end;

  function MED(A,B,C:INTEGER) return INTEGER is
  begin
    return MAX(MIN(A,B),MIN(MAX(A,B),C));
  end;

  function MAX(A,B:INTEGER) return INTEGER is
  begin
    if A>B then
      return A;
    else
      return B;
    end if;
  end;

  function MAX(A,B,C:INTEGER) return INTEGER is
  begin
    return MAX(MAX(A,B),C);
  end;

  function MAX(A,B,C,D:INTEGER) return INTEGER is
  begin
    return MAX(MAX(A,B),MAX(C,D));
  end;
  
  function "+"(X,Y:SFIXED) return SFIXED is
    variable SX,SY,SR:SIGNED(MAX(X'high,Y'high)+1-MIN(X'low,Y'low) downto 0);
    variable R:SFIXED(MAX(X'high,Y'high)+1 downto MIN(X'low,Y'low));
  begin
    for K in SX'range loop
      if K<X'low-Y'low then
        SX(K):='0';           -- zero pad X LSBs
      elsif K>X'high-R'low then 
        SX(K):=X(X'high);     -- sign extend X MSBs
      else 
        SX(K):=X(R'low+K);
      end if;
    end loop;
    for K in SY'range loop
      if K<Y'low-X'low then 
        SY(K):='0';           -- zero pad Y LSBs
      elsif K>Y'high-R'low then 
        SY(K):=Y(Y'high);     -- sign extend Y MSBs
      else 
        SY(K):=Y(R'low+K);
      end if;
    end loop;
    SR:=SX+SY; -- SIGNED addition
    for K in SR'range loop 
      R(R'low+K):=SR(K);
    end loop;
    return R;
  end; 

function "*"(X,Y:SFIXED) return SFIXED is
    variable SX:SIGNED(X'high-X'low downto 0);
    variable SY:SIGNED(Y'high-Y'low downto 0);
    variable SR:SIGNED(SX'high+SY'high+1 downto 0);
    variable R:SFIXED(X'high+Y'high+1 downto X'low+Y'low);
  begin
    for K in SX'range loop
      SX(K):=X(X'low+K);
    end loop;
    for K in SY'range loop
      SY(K):=Y(Y'low+K);
    end loop;
    SR:=SX*SY; -- SIGNED multiplication
    for K in SR'range loop
      R(R'low+K):=SR(K);
    end loop;
    return R;
  end;

  function "*"(X:SFIXED;Y:STD_LOGIC) return SFIXED is
  begin
    if Y='1' then
      return X;
    else
      return TO_SFIXED(0.0,X);
    end if;
  end;
       
    
end TYPES_PKG;
