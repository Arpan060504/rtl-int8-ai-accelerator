module v1_signed_mac_pe(clk ,reset , clear_acc , enable , a , b , acc_out);
input clk , reset , clear_acc , enable;
input signed [7:0] a , b ;
output reg signed [31:0] acc_out;

always @(posedge clk ) 
begin
    if(reset)
        acc_out <= 0;
    else if(clear_acc)
        acc_out <= 0;
    else if(enable)
        acc_out <= acc_out + a*b;    
end
endmodule