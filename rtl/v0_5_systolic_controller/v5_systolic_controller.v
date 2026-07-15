module v5_systolic_controller(
    input clk, start, reset,
    input signed [7:0] a00, a01, a10, a11,
    input signed [7:0] b00, b01, b10, b11,
    output signed [31:0] c00, c01, c10, c11,
    output reg busy, done
);

reg [2:0] state, next_state;
reg [1:0] wait_counter;

reg clear, enable;
reg signed [7:0] a0;
reg signed [7:0] a1;
reg signed [7:0] b0;
reg signed [7:0] b1;

// FSM State Parameters
localparam IDLE    = 3'd0;
localparam CLEAR   = 3'd1;
localparam STREAM0 = 3'd2; // Cycle 0
localparam STREAM1 = 3'd3; // Cycle 1
localparam STREAM2 = 3'd4; // Cycle 2
localparam STREAM3 = 3'd5; // Cycle 3 (Zero stream to flush pipeline)
localparam WAIT    = 3'd6; // Allow outputs to settle
localparam DONE    = 3'd7;

// Instantiate your unchanged 2x2 Systolic Array
v4_systolic_array_2x2 dut(
    .clk(clk),
    .reset(reset),
    .clear(clear),
    .enable(enable),
    .a0(a0),
    .a1(a1),
    .b0(b0),
    .b1(b1),
    .c00(c00),
    .c01(c01),
    .c10(c10),
    .c11(c11)
);

// Combinational Block for Output Control & Inputs
always @(*) begin
    // Safe default values to avoid latch generation
    busy   = 1'b1;
    done   = 1'b0;
    clear  = 1'b0;
    enable = 1'b1;
    a0     = 8'sd0;
    a1     = 8'sd0;
    b0     = 8'sd0;
    b1     = 8'sd0;

    case(state)
        IDLE: begin
            busy   = 1'b0;
            enable = 1'b0;
        end
        CLEAR: begin
            clear  = 1'b1;
            enable = 1'b0;
        end
        STREAM0: begin // Cycle 0: (a00, 0, b00, 0)
            a0 = a00;
            a1 = 8'sd0;
            b0 = b00;
            b1 = 8'sd0;
        end    
        STREAM1: begin // Cycle 1: (a01, a10, b10, b01)
            a0 = a01;
            a1 = a10;
            b0 = b10;
            b1 = b01;
        end  
        STREAM2: begin // Cycle 2: (0, a11, 0, b11)
            a0 = 8'sd0;
            a1 = a11;
            b0 = 8'sd0;
            b1 = b11;
        end
        STREAM3: begin // Cycle 3: (0, 0, 0, 0)
            a0 = 8'sd0;
            a1 = 8'sd0;
            b0 = 8'sd0;
            b1 = 8'sd0;
        end
        WAIT: begin
            // Hold inputs at 0 and keep enable high to let PE logic finish
            a0 = 8'sd0;
            a1 = 8'sd0;
            b0 = 8'sd0;
            b1 = 8'sd0;
        end   
        DONE: begin
            busy   = 1'b0;
            done   = 1'b1;
            enable = 1'b0;
        end
        default: ;
    endcase
end

// FSM State Transition Logic
always @(*) begin
    next_state = state;
    case(state)
        IDLE: begin
            if (start) 
                next_state = CLEAR;
        end
        CLEAR:   next_state = STREAM0;
        STREAM0: next_state = STREAM1;       
        STREAM1: next_state = STREAM2;
        STREAM2: next_state = STREAM3;
        STREAM3: next_state = WAIT;        
        WAIT: begin
            if (wait_counter == 2'd2) 
                next_state = DONE;     
        end
        DONE:    next_state = IDLE;    
        default: next_state = IDLE;      
    endcase          
end

// Sequential State Register
always @(posedge clk) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// Sequential Wait Counter Register (tracks cycles inside the WAIT state)
always @(posedge clk) begin
    if (reset) begin
        wait_counter <= 2'd0;
    end else if (state == WAIT) begin
        wait_counter <= wait_counter + 2'd1;
    end else begin
        wait_counter <= 2'd0;
    end
end

endmodule