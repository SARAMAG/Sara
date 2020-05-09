
 
 // Behavioral description of four-to-one line multiplexer
 
 
 
 module  mux_4TO1_beh
 
 (  output reg  Y,  
 
 input  A, B, C, D,  
 
 input  [1: 0] select
 
 );
 
 
 always  @ (A, B, C, D,  select) // Verilog 2001, 2005 syntax  
 
 case  (select)  
 2’b00: Y = A;  
 2’b01: Y =B;  
 2’b10: Y = C;  
 2’b11: Y = D;  
 
 endcase 
 
 
 endmodule 
 
 