
module v3_parallel_matmul_2x2_tb;

reg clk;
reg reset;
reg start;

reg signed [7:0] a00;
reg signed [7:0] a01;
reg signed [7:0] a10;
reg signed [7:0] a11;

reg signed [7:0] b00;
reg signed [7:0] b01;
reg signed [7:0] b10;
reg signed [7:0] b11;

wire signed [31:0] c00;
wire signed [31:0] c01;
wire signed [31:0] c10;
wire signed [31:0] c11;

wire busy;
wire done;


// ==================================================
// DUT INSTANTIATION
// ==================================================

v3_parallel_matmul_2x2 v3_test (
    .clk   (clk),
    .reset (reset),
    .start (start),

    .a00 (a00),
    .a01 (a01),
    .a10 (a10),
    .a11 (a11),

    .b00 (b00),
    .b01 (b01),
    .b10 (b10),
    .b11 (b11),

    .c00 (c00),
    .c01 (c01),
    .c10 (c10),
    .c11 (c11),

    .busy (busy),
    .done (done)
);


// ==================================================
// CLOCK GENERATION
// Clock period = 10 time units
// ==================================================

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end


// ==================================================
// MAIN TEST SEQUENCE
// ==================================================

initial
begin

    // ------------------------------------------------
    // INITIAL VALUES
    // ------------------------------------------------

    reset = 1;
    start = 0;

    a00 = 0;
    a01 = 0;
    a10 = 0;
    a11 = 0;

    b00 = 0;
    b01 = 0;
    b10 = 0;
    b11 = 0;


    // ------------------------------------------------
    // RESET
    // ------------------------------------------------

    #12;
    reset = 0;


    // =================================================
    // TEST 1: NORMAL POSITIVE MATRIX
    //
    // A = [1 2]
    //     [3 4]
    //
    // B = [5 6]
    //     [7 8]
    //
    // Expected:
    //
    // C = [19 22]
    //     [43 50]
    // =================================================

    $display("");
    $display("========================================");
    $display("TEST 1: POSITIVE MATRIX");
    $display("========================================");

    a00 = 1;
    a01 = 2;
    a10 = 3;
    a11 = 4;

    b00 = 5;
    b01 = 6;
    b10 = 7;
    b11 = 8;

    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #1;

    if(c00 == 19 &&
       c01 == 22 &&
       c10 == 43 &&
       c11 == 50)
    begin
        $display(
            "PASS POSITIVE: Expected C=[19 22; 43 50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL POSITIVE: Expected C=[19 22; 43 50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end


    // Wait until old DONE pulse clears
    wait(done == 1'b0);

    #1;


    // =================================================
    // TEST 2: ZERO MATRIX
    //
    // A = [1 2]
    //     [3 4]
    //
    // B = [0 0]
    //     [0 0]
    //
    // Expected:
    //
    // C = [0 0]
    //     [0 0]
    // =================================================

    $display("");
    $display("========================================");
    $display("TEST 2: ZERO MATRIX");
    $display("========================================");

    a00 = 1;
    a01 = 2;
    a10 = 3;
    a11 = 4;

    b00 = 0;
    b01 = 0;
    b10 = 0;
    b11 = 0;

    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #1;

    if(c00 == 0 &&
       c01 == 0 &&
       c10 == 0 &&
       c11 == 0)
    begin
        $display(
            "PASS ZERO: Expected C=[0 0; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL ZERO: Expected C=[0 0; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end


    // Wait until old DONE pulse clears
    wait(done == 1'b0);

    #1;


    // =================================================
    // TEST 3: IDENTITY MATRIX
    //
    // A = [1 2]
    //     [3 4]
    //
    // B = [1 0]
    //     [0 1]
    //
    // Expected:
    //
    // C = [1 2]
    //     [3 4]
    // =================================================

    $display("");
    $display("========================================");
    $display("TEST 3: IDENTITY MATRIX");
    $display("========================================");

    a00 = 1;
    a01 = 2;
    a10 = 3;
    a11 = 4;

    b00 = 1;
    b01 = 0;
    b10 = 0;
    b11 = 1;

    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #1;

    if(c00 == 1 &&
       c01 == 2 &&
       c10 == 3 &&
       c11 == 4)
    begin
        $display(
            "PASS IDENTITY: Expected C=[1 2; 3 4], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL IDENTITY: Expected C=[1 2; 3 4], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end


    // Wait until old DONE pulse clears
    wait(done == 1'b0);

    #1;


    // =================================================
    // TEST 4: MIXED SIGNED VALUES
    //
    // A = [-1   2]
    //     [ 3  -4]
    //
    // B = [ 5  -6]
    //     [-7   8]
    //
    // Expected:
    //
    // C00 = (-1*5)  + (2*-7)  = -19
    // C01 = (-1*-6) + (2*8)   =  22
    // C10 = (3*5)   + (-4*-7) =  43
    // C11 = (3*-6)  + (-4*8)  = -50
    //
    // C = [-19  22]
    //     [ 43 -50]
    // =================================================

    $display("");
    $display("========================================");
    $display("TEST 4: MIXED SIGNED MATRIX");
    $display("========================================");

    a00 = -1;
    a01 =  2;
    a10 =  3;
    a11 = -4;

    b00 =  5;
    b01 = -6;
    b10 = -7;
    b11 =  8;

    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #1;

    if(c00 == -19 &&
       c01 ==  22 &&
       c10 ==  43 &&
       c11 == -50)
    begin
        $display(
            "PASS SIGNED: Expected C=[-19 22; 43 -50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL SIGNED: Expected C=[-19 22; 43 -50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end


    // Wait until old DONE pulse clears
    wait(done == 1'b0);

    #1;


    // =================================================
    // TEST 5: BOUNDARY-LIKE INT8 VALUES
    //
    // A = [ 127  127]
    //     [-127  127]
    //
    // B = [127 127]
    //     [127 127]
    //
    // Expected:
    //
    // C00 = 127*127 + 127*127
    //     = 16129 + 16129
    //     = 32258
    //
    // C01 = 32258
    //
    // C10 = -127*127 + 127*127
    //     = -16129 + 16129
    //     = 0
    //
    // C11 = 0
    //
    // C = [32258 32258]
    //     [    0     0]
    // =================================================

    $display("");
    $display("========================================");
    $display("TEST 5: BOUNDARY VALUES");
    $display("========================================");

    a00 =  127;
    a01 =  127;
    a10 = -127;
    a11 =  127;

    b00 = 127;
    b01 = 127;
    b10 = 127;
    b11 = 127;

    start = 1;

    #10;
    start = 0;

    wait(done == 1'b1);

    #1;

    if(c00 == 32258 &&
       c01 == 32258 &&
       c10 == 0 &&
       c11 == 0)
    begin
        $display(
            "PASS BOUNDARY: Expected C=[32258 32258; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL BOUNDARY: Expected C=[32258 32258; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end


    // =================================================
    // END SIMULATION
    // =================================================

    #10;

    $display("");
    $display("========================================");
    $display("V0.3 PARALLEL MATMUL TESTBENCH FINISHED");
    $display("========================================");

    $finish;
end


// ==================================================
// TIMEOUT WATCHDOG
// Prevent infinite simulation
// ==================================================

initial
begin
    #1000;

    $display("");
    $display("========================================");
    $display("TIMEOUT ERROR");
    $display("Simulation did not finish");
    $display("state = %0d", v3_test.state);
    $display("term  = %b",  v3_test.term);
    $display("busy  = %b",  busy);
    $display("done  = %b",  done);
    $display("========================================");

    $finish;
end


// ==================================================
// VCD WAVEFORM
// ==================================================

initial
begin
    $dumpfile("v3_test.vcd");
    $dumpvars(0, v3_parallel_matmul_2x2_tb);
end


// ==================================================
// INTERNAL ARCHITECTURE MONITOR
// ==================================================

initial
begin
    $monitor(
        "T=%0t | state=%0d term=%b | clear=%b enable=%b | acc=[%0d %0d; %0d %0d] | C=[%0d %0d; %0d %0d] | busy=%b done=%b",
        $time,

        v3_test.state,
        v3_test.term,

        v3_test.mac_clear,
        v3_test.mac_enable,

        v3_test.acc00,
        v3_test.acc01,
        v3_test.acc10,
        v3_test.acc11,

        c00,
        c01,
        c10,
        c11,

        busy,
        done
    );
end

endmodule