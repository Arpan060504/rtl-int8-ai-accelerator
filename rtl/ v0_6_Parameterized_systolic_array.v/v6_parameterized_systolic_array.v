module v6_parameterized_systolic_array #(
    parameter DATA_WIDTH = 8,
    parameter N = 8,
    parameter ACC_WIDTH = 32
)(
    input wire clk,
    input wire reset,
    input wire clear,
    input wire enable,
    
    input wire signed [DATA_WIDTH-1:0] a_in [0:N-1],
    input wire signed [DATA_WIDTH-1:0] b_in [0:N-1],
    
    // FIX: Two-dimensional array output defined cleanly here
    output wire signed [ACC_WIDTH-1:0] c_out [0:N-1][0:N-1]
);

    // Interconnect internal buses
    wire signed [DATA_WIDTH-1:0] a_bus [0:N-1][0:N];
    wire signed [DATA_WIDTH-1:0] b_bus [0:N][0:N-1];

    genvar i, j;
    generate
        for(i = 0; i < N; i = i + 1) begin : row
            for(j = 0; j < N; j = j + 1) begin : col
                v4_systolic_pe pe (
                    .clk(clk),
                    .reset(reset),
                    .clear(clear),
                    .enable(enable),
                    .a_in(a_bus[i][j]),
                    .b_in(b_bus[i][j]),
                    .a_out(a_bus[i][j+1]),
                    .b_out(b_bus[i+1][j]),
                    .acc_out(c_out[i][j])
                );
            end
        end
    endgenerate

    generate
        for(i = 0; i < N; i = i + 1) begin : a_connect
            assign a_bus[i][0] = a_in[i];
        end
    endgenerate

    generate
        for(j = 0; j < N; j = j + 1) begin : b_connect
            assign b_bus[0][j] = b_in[j];
        end
    endgenerate

endmodule