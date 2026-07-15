module v5_systolic_controller_tb;

reg clk;
reg reset;
reg start;

reg signed [7:0] a00,a01,a10,a11;
reg signed [7:0] b00,b01,b10,b11;

wire signed [31:0] c00,c01,c10,c11;
wire busy;
wire done;

v5_systolic_controller dut(
    .clk(clk),
    .reset(reset),
    .start(start),

    .a00(a00),
    .a01(a01),
    .a10(a10),
    .a11(a11),

    .b00(b00),
    .b01(b01),
    .b10(b10),
    .b11(b11),

    .c00(c00),
    .c01(c01),
    .c10(c10),
    .c11(c11),

    .busy(busy),
    .done(done)
);
initial // clock
begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial
begin
    $dumpfile("v5_controller.vcd");
    $dumpvars(0,v5_systolic_controller_tb);
end

initial
begin
    $monitor(
    "T=%0t state=%0d cnt=%0d busy=%b done=%b | C=[%0d %0d;%0d %0d]",
    $time,
    dut.state,
    dut.wait_counter,
    busy,
    done,
    c00,c01,c10,c11
);
end

task apply_reset; // reset operation
begin
    reset = 1;
    start = 0;

    a00=0; a01=0;
    a10=0; a11=0;

    b00=0; b01=0;
    b10=0; b11=0;

    #20;
    reset = 0;
end
endtask

task run_matrix;  //mul operation

input signed [7:0] ia00,ia01,ia10,ia11;
input signed [7:0] ib00,ib01,ib10,ib11;

input signed [31:0] ec00,ec01,ec10,ec11;

begin
    a00=ia00;
    a01=ia01;
    a10=ia10;
    a11=ia11;

    b00=ib00;
    b01=ib01;
    b10=ib10;
    b11=ib11;

    start=1;

    #10;
    start=0;

    wait(done);

    #1;

    if(c00==ec00 &&
       c01==ec01 &&
       c10==ec10 &&
       c11==ec11)
    begin
        $display("--------------------------------------");
        $display("PASS");
        $display("Expected [%0d %0d;%0d %0d]",
                  ec00,ec01,ec10,ec11);
        $display("Got      [%0d %0d;%0d %0d]",
                  c00,c01,c10,c11);
    end
    else
    begin
        $display("--------------------------------------");
        $display("FAIL");
        $display("Expected [%0d %0d;%0d %0d]",
                  ec00,ec01,ec10,ec11);
        $display("Got      [%0d %0d;%0d %0d]",
                  c00,c01,c10,c11);
    end

    #20;

end

endtask

/////////////////////////////////////////////////////////
// MAIN TEST
/////////////////////////////////////////////////////////

initial
begin

    apply_reset();

    // Positive Test
    run_matrix(
        1,2,3,4,
        5,6,7,8,
        19,22,43,50
    );

    // Zero Matrix
    run_matrix(
        1,2,3,4,
        0,0,0,0,
        0,0,0,0
    );

    // Identity
    run_matrix(
        1,2,3,4,
        1,0,0,1,
        1,2,3,4
    );

    // Signed
    run_matrix(
        -1,2,3,-4,
        5,-6,7,8,
        9,22,-13,-50
    );

    // Boundary
    run_matrix(
        127,127,
        -127,127,

        127,127,
        127,127,

        32258,
        32258,
        0,
        0
    );

    $display("--------------------------------------");
    $display("ALL TESTS COMPLETED");
    $display("--------------------------------------");

    #20;
    $finish;

end

initial //timeout
begin
    #1000;
    $display("TIMEOUT");
    $finish;
end

endmodule