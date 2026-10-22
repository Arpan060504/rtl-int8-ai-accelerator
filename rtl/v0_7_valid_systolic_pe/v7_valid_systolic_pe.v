
module v7_valid_systolic_pe (
    input  wire clk,
    input  wire reset,
    input  wire clear,
    input  wire enable,

    input  wire signed [7:0] a_in,
    input  wire signed [7:0] b_in,
    input  wire              a_valid_in,
    input  wire              b_valid_in,

    output reg signed [7:0] a_out,
    output reg signed [7:0] b_out,
    output reg              a_valid_out,
    output reg              b_valid_out,

    output wire signed [31:0] acc_out
);

    // Accumulate only when BOTH operands are valid.
    wire mac_enable;

    assign mac_enable = enable &&
                        a_valid_in &&
                        b_valid_in;

    // Existing arithmetic unit: preserve the original MAC.
    v1_signed_mac_pe mac (
        .clk       (clk),
        .reset     (reset),
        .clear_acc (clear),
        .enable    (mac_enable),
        .a         (a_in),
        .b         (b_in),
        .acc_out   (acc_out)
    );

    // Registered operand forwarding and validity propagation.
    always @(posedge clk) begin
        if (reset) begin
            a_out       <= 8'sd0;
            b_out       <= 8'sd0;
            a_valid_out <= 1'b0;
            b_valid_out <= 1'b0;
        end
        else if (enable && !clear) begin
            a_out       <= a_in;
            b_out       <= b_in;
            a_valid_out <= a_valid_in;
            b_valid_out <= b_valid_in;
        end
        // Otherwise hold forwarding and validity state.
    end

endmodule
