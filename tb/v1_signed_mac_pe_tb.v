module v1_signed_mac_pe_tb;

reg clk;
reg reset;
reg clear_acc;
reg enable;

reg signed [7:0] a;
reg signed [7:0] b;

wire signed [31:0] acc_out;


// DUT
v1_signed_mac_pe v1_test (
    clk,
    reset,
    clear_acc,
    enable,
    a,
    b,
    acc_out
);

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end


// Main stimulus
initial
begin
    reset     = 1;
    clear_acc = 0;
    enable    = 0;
    a         = 0;
    b         = 0;


    // -----------------------------------------
    // TEST 1: RESET
    // -----------------------------------------
    @(posedge clk);
    #1;

    if(acc_out == 0)
        $display("PASS RESET: Expected 0, Got %0d", acc_out);
    else
        $display("FAIL RESET: Expected 0, Got %0d", acc_out);


    // Release reset immediately after check
    reset = 0;


    // -----------------------------------------
    // TEST 2: POSITIVE MULTIPLICATION
    // 3 * 4 = 12
    // -----------------------------------------
    a      = 3;
    b      = 4;
    enable = 1;

    @(posedge clk);
    #1;

    if(acc_out == 12)
        $display("PASS 3x4: Expected 12, Got %0d", acc_out);
    else
        $display("FAIL 3x4: Expected 12, Got %0d", acc_out);


    // -----------------------------------------
    // TEST 3: ACCUMULATION
    // Previous ACC = 12
    // 2 * 5 = 10
    // Expected = 22
    // -----------------------------------------
    a = 2;
    b = 5;

    @(posedge clk);
    #1;

    if(acc_out == 22)
        $display("PASS ACCUMULATION: Expected 22, Got %0d", acc_out);
    else
        $display("FAIL ACCUMULATION: Expected 22, Got %0d", acc_out);


    // -----------------------------------------
    // TEST 4: ENABLE HOLD
    // 100 * 100 must NOT accumulate
    // Expected ACC remains 22
    // -----------------------------------------
    a      = 100;
    b      = 100;
    enable = 0;

    @(posedge clk);
    #1;

    if(acc_out == 22)
        $display("PASS HOLD: Expected 22, Got %0d", acc_out);
    else
        $display("FAIL HOLD: Expected 22, Got %0d", acc_out);


    // -----------------------------------------
    // TEST 5: NEGATIVE x POSITIVE
    // Previous ACC = 22
    // -3 * 4 = -12
    // Expected = 10
    // -----------------------------------------
    a      = -3;
    b      = 4;
    enable = 1;

    @(posedge clk);
    #1;

    if(acc_out == 10)
        $display("PASS NEGATIVE: Expected 10, Got %0d", acc_out);
    else
        $display("FAIL NEGATIVE: Expected 10, Got %0d", acc_out);


    // -----------------------------------------
    // TEST 6: CLEAR PRIORITY OVER ENABLE
    //
    // clear_acc = 1
    // enable    = 1
    //
    // Even though 100*100 = 10000,
    // accumulator must become 0
    // -----------------------------------------
    clear_acc = 1;
    enable    = 1;
    a         = 100;
    b         = 100;

    @(posedge clk);
    #1;

    if(acc_out == 0)
        $display("PASS CLEAR PRIORITY: Expected 0, Got %0d", acc_out);
    else
        $display("FAIL CLEAR PRIORITY: Expected 0, Got %0d", acc_out);


    // Release clear
    clear_acc = 0;


    // -----------------------------------------
    // TEST 7: NEGATIVE x NEGATIVE
    // -3 * -4 = +12
    // -----------------------------------------
    a      = -3;
    b      = -4;
    enable = 1;

    @(posedge clk);
    #1;

    if(acc_out == 12)
        $display("PASS NEGxNEG: Expected 12, Got %0d", acc_out);
    else
        $display("FAIL NEGxNEG: Expected 12, Got %0d", acc_out);


    // -----------------------------------------
    // CLEAR BEFORE BOUNDARY TEST
    // -----------------------------------------
    clear_acc = 1;
    enable    = 0;

    @(posedge clk);
    #1;

    if(acc_out == 0)
        $display("PASS CLEAR: Expected 0, Got %0d", acc_out);
    else
        $display("FAIL CLEAR: Expected 0, Got %0d", acc_out);

    clear_acc = 0;


    // -----------------------------------------
    // TEST 8: MAX POSITIVE INT8 VALUES
    // 127 * 127 = 16129
    // -----------------------------------------
    a      = 127;
    b      = 127;
    enable = 1;

    @(posedge clk);
    #1;

    if(acc_out == 16129)
        $display("PASS 127x127: Expected 16129, Got %0d", acc_out);
    else
        $display("FAIL 127x127: Expected 16129, Got %0d", acc_out);


    // -----------------------------------------
    // CLEAR BEFORE NEXT BOUNDARY TEST
    // -----------------------------------------
    clear_acc = 1;
    enable    = 0;

    @(posedge clk);
    #1;

    clear_acc = 0;


    // -----------------------------------------
    // TEST 9: MIN NEGATIVE x MAX POSITIVE
    // -128 * 127 = -16256
    // -----------------------------------------
    a      = -128;
    b      = 127;
    enable = 1;

    @(posedge clk);
    #1;

    if(acc_out == -16256)
        $display("PASS -128x127: Expected -16256, Got %0d", acc_out);
    else
        $display("FAIL -128x127: Expected -16256, Got %0d", acc_out);


    // -----------------------------------------
    // CLEAR BEFORE REPEATED ACCUMULATION
    // -----------------------------------------
    clear_acc = 1;
    enable    = 0;

    @(posedge clk);
    #1;

    clear_acc = 0;


    // -----------------------------------------
    // TEST 10: REPEATED ACCUMULATION
    //
    // 5 * 6 = 30
    // Repeat 3 times
    //
    // 30 + 30 + 30 = 90
    // -----------------------------------------
    a      = 5;
    b      = 6;
    enable = 1;

    // First accumulation
    @(posedge clk);
    #1;

    if(acc_out == 30)
        $display("PASS REPEAT-1: Expected 30, Got %0d", acc_out);
    else
        $display("FAIL REPEAT-1: Expected 30, Got %0d", acc_out);


    // Second accumulation
    @(posedge clk);
    #1;

    if(acc_out == 60)
        $display("PASS REPEAT-2: Expected 60, Got %0d", acc_out);
    else
        $display("FAIL REPEAT-2: Expected 60, Got %0d", acc_out);


    // Third accumulation
    @(posedge clk);
    #1;

    if(acc_out == 90)
        $display("PASS REPEAT-3: Expected 90, Got %0d", acc_out);
    else
        $display("FAIL REPEAT-3: Expected 90, Got %0d", acc_out);


    // Stop further accumulation
    enable = 0;
    $display("");
    $display("----------------------------------------");
    $display("SIGNED MAC PE TESTBENCH FINISHED");
    $display("----------------------------------------");

    #10;
    $finish;

end


// Waveform + Monitor
initial
begin
    $dumpfile("v1_signed_mac_pe_test.vcd");
    $dumpvars(0, v1_signed_mac_pe_tb);

    $monitor(
        "T=%0t | reset=%b clear=%b enable=%b | a=%0d b=%0d | acc_out=%0d",
        $time,
        reset,
        clear_acc,
        enable,
        a,
        b,
        acc_out
    );
end

endmodule