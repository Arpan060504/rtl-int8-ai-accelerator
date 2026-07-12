module v2_sequential_matmul_2x2 (clk, reset , start
, a00 , a01 , a10 , a11
, b00 , b01 , b10 , b11 
, c00 , c01 , c10 , c11 
, busy , done
);
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

output reg busy;
output reg done;

reg [1:0]output_index ;
reg term;
reg [2:0] state;
reg [2:0] next_state;

reg signed [7:0] mac_a;
reg signed [7:0] mac_b;

reg mac_clear;
reg mac_enable;

wire signed [31:0] mac_acc;

localparam IDLE    = 0;
localparam CLEAR   = 1;
localparam COMPUTE = 2;
localparam STORE   = 3;
localparam DONE    = 4;

v1_signed_mac_pe mul (
    .clk       (clk),
    .reset     (reset),
    .clear_acc (mac_clear),
    .enable    (mac_enable),
    .a         (mac_a),
    .b         (mac_b),
    .acc_out   (mac_acc)
);

always @(posedge clk)
begin
    if(reset)
            state<= IDLE;
    else
        state <= next_state;    
end

always @(*)
begin
     next_state = state;
    case(state)
    IDLE :  
            if(start)
                next_state = CLEAR;
    CLEAR :
     next_state = COMPUTE;
    COMPUTE :
        if(term == 1)
            next_state = STORE;
    STORE :
    begin
        if(output_index == 2'd3)
            next_state = DONE;
        else
            next_state = CLEAR;
    end
    DONE :
        next_state = IDLE;
    default :
        next_state = IDLE;
    endcase
end

always @(posedge clk)
begin
    if(reset)
    begin
        c00         <= 0;
        c01         <= 0;
        c10         <= 0;
        c11         <= 0;
        output_index <= 0;
        term         <= 0;
        busy         <= 0;
        done         <= 0;
    end
    else
    case(state)
    IDLE :  
    begin
        output_index <= 0;
        term <= 0;
        busy <= 0;
        done  <= 0;
    end
    CLEAR :
    begin
         busy <= 1;
    end
    COMPUTE :
    begin
        if(term == 0)
            term <= 1;
    end     
    STORE :
    begin
        case(output_index)
            2'b00: c00 <= mac_acc;
            2'b01: c01 <= mac_acc;
            2'b10: c10 <= mac_acc;
            2'b11: c11 <= mac_acc;
        endcase

        if(output_index != 2'd3)
        begin
            output_index <= output_index + 1;
            term <= 0;
        end
    end    
    DONE :
    begin
        busy <= 0;
        done <= 1;
    end
    default:
    begin
        output_index <= 0;
        term         <= 0;
        busy         <= 0;
        done         <= 0;
    end
    endcase
end

always @(*)
begin
    case(output_index)
    2'b00: 
    begin
        if(term == 0)
        begin
            mac_a = a00;
            mac_b = b00;
        end
        else
        begin
            mac_a = a01;
            mac_b = b10;
        end
    end 
    2'b01: 
    begin
        if(term == 0)
        begin
            mac_a = a00;
            mac_b = b01;
        end
        else
        begin
            mac_a = a01;
            mac_b = b11;
        end
    end 
    2'b10: 
    begin
        if(term == 0)
        begin
            mac_a = a10;
            mac_b = b00;
        end
        else
        begin
            mac_a = a11;
            mac_b = b10;
        end
    end 
    2'b11: 
    begin
        if(term == 0)
        begin
            mac_a = a10;
            mac_b = b01;
        end
        else
        begin
            mac_a = a11;
            mac_b = b11;
        end
    end 
    default:
        begin
            mac_a = 0;
            mac_b = 0;
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
        default:
        begin
            mac_clear  = 0;
            mac_enable = 0;
        end

    endcase
end
endmodule