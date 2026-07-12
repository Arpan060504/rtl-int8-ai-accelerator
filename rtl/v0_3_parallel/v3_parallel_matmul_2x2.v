module v3_parallel_matmul_2x2(
clk , reset , start 
,a00 , a01 , a10 , a11 
, b00 , b01 , b10 , b11 
, c00 , c01 , c10 , c11 
, busy , done);
input clk;
input reset;
input start;

input signed [7:0] a00;
input signed [7:0] a01;
input signed [7:0] a10;
input signed [7:0] a11;

input signed [7:0] b00;
input signed [7:0] b01;
input signed [7:0] b10;
input signed [7:0] b11;

output reg signed [31:0] c00;
output reg signed [31:0] c01;
output reg signed [31:0] c10;
output reg signed [31:0] c11;

reg term;

reg mac_clear;
reg mac_enable;

wire signed [31:0] acc00;
wire signed [31:0] acc01;
wire signed [31:0] acc10;
wire signed [31:0] acc11;

reg signed [7:0] mac0_a;
reg signed [7:0] mac0_b;

reg signed [7:0] mac1_a;
reg signed [7:0] mac1_b;

reg signed [7:0] mac2_a;
reg signed [7:0] mac2_b;

reg signed [7:0] mac3_a;
reg signed [7:0] mac3_b;

output reg busy;
output reg done;

reg [2:0] state , next_state ;
parameter IDLE = 0 , CLEAR =1  , COMPUTE =2 , STORE = 3  , DONE =4;

always @(posedge clk ) 
begin
    if(reset)
        state <= IDLE;
    else
        state <= next_state;   
end

always @(*) 
begin
    next_state = state;
    case(state)
    IDLE:
        if(start)
        next_state = CLEAR;
    CLEAR :
        next_state = COMPUTE;
    COMPUTE:
        if(term)
            next_state = STORE;
    STORE:
        next_state = DONE;
    DONE:
        next_state = IDLE;
    default : next_state = IDLE;
    endcase    
end

always @(posedge clk) 
begin
    if(reset)
    begin
            busy <= 0;
            done <= 0;
            term <= 0;
            
            c00 <= 0;
            c01 <= 0;
            c10 <= 0;
            c11 <= 0;
    end
    else
    case(state)
    IDLE:
        begin
            busy <= 0;
            done <= 0;
            term <= 0;
        end
    CLEAR :
        begin
            busy <= 1;
        end
    COMPUTE:
    begin
        if(term == 0)
            term <= 1;
    end
    STORE:
        begin
            c00 <= acc00;
            c01 <= acc01;
            c10 <= acc10;
            c11 <= acc11;
        end
    DONE:
    begin
        done <= 1;
        busy <= 0;
    end
    default :
        begin
            busy <= 0;
            done <= 0;
            term <= 0;
        end
    endcase    
end
always @(*)
begin
    mac_clear  = 0;
    mac_enable = 0;

    case(state)

        CLEAR:
        begin
            mac_clear = 1;
        end

        COMPUTE:
        begin
            mac_enable = 1;
        end

    endcase
end
always @(*)
begin
    if(term == 0)
    begin
        mac0_a= a00 ;
        mac0_b= b00;

        mac1_a= a00;
        mac1_b= b01;

        mac2_a= a10;
        mac2_b= b00;

        mac3_a= a10 ;
        mac3_b= b01; 
    end
    else
    begin
        mac0_a = a01 ;
        mac0_b = b10;

        mac1_a= a01 ;
        mac1_b= b11;

        mac2_a= a11;
        mac2_b= b10;

        mac3_a= a11 ;
        mac3_b= b11; 
    end
end

v1_signed_mac_pe m1 (
    .clk       (clk),
    .reset     (reset),
    .clear_acc (mac_clear),
    .enable    (mac_enable),
    .a         (mac0_a),
    .b         (mac0_b),
    .acc_out   (acc00)
);

v1_signed_mac_pe m2 (
    .clk       (clk),
    .reset     (reset),
    .clear_acc (mac_clear),
    .enable    (mac_enable),
    .a         (mac1_a),
    .b         (mac1_b),
    .acc_out   (acc01)
);

v1_signed_mac_pe m3 (
    .clk       (clk),
    .reset     (reset),
    .clear_acc (mac_clear),
    .enable    (mac_enable),
    .a         (mac2_a),
    .b         (mac2_b),
    .acc_out   (acc10)
);

v1_signed_mac_pe m4 (
    .clk       (clk),
    .reset     (reset),
    .clear_acc (mac_clear),
    .enable    (mac_enable),
    .a         (mac3_a),
    .b         (mac3_b),
    .acc_out   (acc11)
);

endmodule