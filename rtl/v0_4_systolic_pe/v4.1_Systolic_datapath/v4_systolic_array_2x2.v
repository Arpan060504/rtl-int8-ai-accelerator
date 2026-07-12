module v4_systolic_array_2x2(
                            clk,
                            reset,
                            clear,
                            enable,
                            a0,
                            a1,
                            b0,
                            b1,
                            c00,
                            c01,
                            c10,
                            c11
);


input clk;
input reset;
input clear;
input enable;

input signed [7:0] a0;
input signed [7:0] a1;
input signed [7:0] b0;
input signed [7:0] b1;

output signed [31:0] c00;
output signed [31:0] c01;
output signed [31:0] c10;
output signed [31:0] c11;

wire signed [7:0] wire_00_01;
wire signed [7:0] wire_10_11;
wire signed [7:0] wire_00_10;
wire signed [7:0] wire_01_11;


v4_systolic_pe pe00(.clk(clk) , .reset(reset), .clear(clear ), .enable(enable) 
                    , .a_in(a0) , .b_in(b0) 
                    , .a_out(wire_00_01) , .b_out(wire_00_10) , .acc_out(c00) );

v4_systolic_pe pe01(.clk(clk) , .reset(reset), .clear(clear ), .enable(enable) 
                    , .a_in(wire_00_01) , .b_in(b1) 
                    , .a_out() , .b_out(wire_01_11) , .acc_out(c01) );

v4_systolic_pe pe10(.clk(clk) , .reset(reset), .clear(clear ), .enable(enable) 
                    , .a_in(a1) , .b_in(wire_00_10) 
                    , .a_out(wire_10_11) , .b_out() , .acc_out(c10) );

v4_systolic_pe pe11(.clk(clk) , .reset(reset), .clear(clear ), .enable(enable) 
                    , .a_in(wire_10_11) , .b_in(wire_01_11) 
                    , .a_out() , .b_out() , .acc_out(c11) );
endmodule