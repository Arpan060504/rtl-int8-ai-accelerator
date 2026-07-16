module v6_parameterized_systolic_array_tb;

integer i,j,k; 
parameter N          = 2;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;
// DUT Signals
reg clk , reset , clear , enable;

reg signed [DATA_WIDTH-1:0] a_in [0:N-1];
reg signed [DATA_WIDTH-1:0] b_in [0:N-1];

wire signed [ACC_WIDTH-1:0] c_out [0:N-1][0:N-1];
// Testbench Memories
// Input matrices
reg signed [DATA_WIDTH-1:0] matrix_a [0:N-1][0:N-1];
reg signed [DATA_WIDTH-1:0] matrix_b [0:N-1][0:N-1];
// Golden (Expected) Result
reg signed [ACC_WIDTH-1:0] golden [0:N-1][0:N-1];

// DUT
v6_parameterized_systolic_array
#(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
)
dut
(
    .clk(clk),
    .reset(reset),
    .clear(clear),
    .enable(enable),

    .a_in(a_in),
    .b_in(b_in),

    .c_out(c_out)
);

initial // clock
begin
    clk = 0;
    forever #5 clk = ~clk;
end

task apply_reset; // reset operation 
integer i,j;
begin

    reset  = 1;
    clear  = 0;
    enable = 0;

    // Clear DUT inputs
    for(i=0;i<N;i=i+1)
    begin
        a_in[i] = 0;
        b_in[i] = 0;
    end

    // Clear matrix memories
    for(i=0;i<N;i=i+1)
    begin
        for(j=0;j<N;j=j+1)
        begin
            matrix_a[i][j] = 0;
            matrix_b[i][j] = 0;
            golden[i][j]   = 0;
        end
    end

    #20;

    reset = 0;

end

endtask

//////////////////////////////////////////////////////
// Initial Block
//////////////////////////////////////////////////////

initial
begin

    apply_reset();
    load_matrix();
    compute_golden();
    stream_matrix();
    check_results();

$display("Golden Matrix");

for(i=0;i<N;i=i+1)
begin
    for(j=0;j<N;j=j+1)
        $write("%6d ",golden[i][j]);
    $display("");
end

$display("RTL Output");

for(i=0;i<N;i=i+1)
begin
    for(j=0;j<N;j=j+1)
        $write("%6d ",c_out[i][j]);
    $display("");
end
    #10 ; $finish();
end

task stream_matrix;
    integer t, idx;
    begin
        enable = 1; // Activate processing elements
        
        // Total cycles needed to stream data through an N x N skewed grid is (3*N - 2)
        for (t = 0; t < (3*N - 2); t = t + 1) begin
            for (idx = 0; idx < N; idx = idx + 1) begin
                
                // --- Stream Matrix A (Rows are delayed by 'idx' cycles) ---
                if ((t >= idx) && (t - idx < N)) 
                    a_in[idx] = matrix_a[idx][t - idx];
                else 
                    a_in[idx] = 0; // Drive 0 if data hasn't arrived or has finished
                
                // --- Stream Matrix B (Columns are delayed by 'idx' cycles) ---
                if ((t >= idx) && (t - idx < N)) 
                    b_in[idx] = matrix_b[t - idx][idx];
                else 
                    b_in[idx] = 0; // Drive 0 if data hasn't arrived or has finished
            end
            
            #10; // Wait for one clock cycle before driving the next wave of data
        end
        
        // --- Pipeline Flush Phase ---
        // Turn off enable and clear inputs while trailing data drains out
        enable = 0;
        for (idx = 0; idx < N; idx = idx + 1) begin
            a_in[idx] = 0;
            b_in[idx] = 0;
        end
        
        // Wait for the final values to completely propagate through the PE grid
        repeat (2*N) #10; 
    end
endtask

    //LOADING MATRIX
task load_matrix; 
begin

    matrix_a[0][0]=1;
    matrix_a[0][1]=2;
    matrix_a[1][0]=3;
    matrix_a[1][1]=4;

    matrix_b[0][0]=5;
    matrix_b[0][1]=6;
    matrix_b[1][0]=7;
    matrix_b[1][1]=8;

end
endtask

task compute_golden();
 integer i,j,k;
    begin
        for(i=0;i<N;i=i+1)
            begin
                for(j=0;j<N;j=j+1)
                begin
                    golden[i][j] = 0;

                    for(k=0;k<N;k=k+1)
                    begin
                        golden[i][j] =
                            golden[i][j] +
                            matrix_a[i][k] *
                            matrix_b[k][j];
                    end
                end
            end
    end
endtask

initial
begin
    $dumpfile("v6_test.vcd");
    $dumpvars(0,v6_parameterized_systolic_array_tb);
end

initial  // timeout
begin
    #1000;
    $display("TIMEOUT");
    $finish;
end

//////////////////////////////////////////////////////
// Check Results
//////////////////////////////////////////////////////

task check_results;

integer i,j;
integer errors;

begin

    errors = 0;

    $display("--------------------------------------");
    $display("Checking Results");
    $display("--------------------------------------");

    for(i=0;i<N;i=i+1)
    begin
        for(j=0;j<N;j=j+1)
        begin

            if(c_out[i][j] !== golden[i][j])
            begin
                errors = errors + 1;

                $display(
                "Mismatch at C[%0d][%0d] : Expected = %0d  Got = %0d",
                i,
                j,
                golden[i][j],
                c_out[i][j]
                );

            end

        end
    end

    if(errors==0)
    begin
        $display("--------------------------------------");
        $display("PASS");
        $display("--------------------------------------");
    end
    else
    begin
        $display("--------------------------------------");
        $display("FAIL : %0d mismatches found",errors);
        $display("--------------------------------------");
    end

end

endtask
endmodule