module v4_systolic_pe(clk , reset , clear , enable , a_in , b_in 
, a_out , b_out , acc_out );

input clk , reset , clear , enable ;
input signed [7:0] a_in , b_in ;
output reg signed [7:0] a_out , b_out;
output signed [31:0] acc_out;

always @(posedge clk)
begin
    if(reset)
        begin
            a_out <= 0;
            b_out <= 0;
        end
end

v1_signed_mac_pe pe (.clk(clk) ,
                    .reset(reset) , .clear_acc(clear) , .enable(enable) 
                    , .a(a_in) , .b(b_in) , .acc_out(acc_out));

always @(posedge clk)
begin
    if(enable)
        begin
            a_out <= a_in;
            b_out <= b_in;
        end   
end
endmodule