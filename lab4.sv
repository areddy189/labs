`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  logic f0,f1,f2,f3,w,x,y,z; // The variables we want to use
  assign right[3:0] = {f0,f1,f2,f3};  // Connect fx to right[3] ... right[0]
  assign {w,x,y,z} = pb[3:0]; // w,x,y,z = pb[3],pb[2],pb[1],pb[0]
  // Your code goes here...
  assign red = pb[0];
  assign ss0[6:0] = pb[6:0];
  bargraph b1 (pb[15:0], {left, right});
  decode3to8 d1 (pb[2:0], {ss0[7], ss1[7], ss2[7], ss3[7], ss4[7], ss5[7], ss6[7], ss7[7]});
endmodule

// Add more modules down here...
module bargraph (
  input logic [15:0] in,
  output logic [15:0] out
  );
  assign out[15] = in[15];
  assign out[14] = in[14] | out[15];
  assign out[13] = in[13] | out[14];
  assign out[12] = in[12] | out[13];
  assign out[11] = in[11] | out[12];
  assign out[10] = in[10] | out[11];
  assign out[9] = in[9] | out[10];
  assign out[8] = in[8] | out[9];
  assign out[7] = in[7] | out[8];
  assign out[6] = in[6] | out[7];
  assign out[5] = in[5] | out[6];
  assign out[4] = in[4] | out[5];
  assign out[3] = in[3] | out[4];
  assign out[2] = in[2] | out[3];
  assign out[1] = in[1] | out[2];
  assign out[0] = in[0] | out[1];
endmodule


module decode3to8 (
  input logic [2:0] in,
  output logic [7:0] out
  );
  assign out[7] = ~|in;
  assign out[6] = ~in[2] & ~in[1] & in[0];
  assign out[5] = ~in[2] & in[1] & ~in[0];
  assign out[4] = ~in[2] & in[1] & in[0];
  assign out[3] = in[2] & ~in[1] & ~in[0];
  assign out[2] = in[2] & ~in[1] & in[0];
  assign out[1] = in[2] & in[1] & ~in[0];
  assign out[0] = in[2] & in[1] & in[0];
endmodule
  
  
  
  
