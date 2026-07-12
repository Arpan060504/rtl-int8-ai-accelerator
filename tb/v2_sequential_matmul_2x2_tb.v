module v2_sequential_matmul_2x2_tb;

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

v2_sequential_matmul_2x2 v2_test (clk, reset , start
, a00 , a01 , a10 , a11
, b00 , b01 , b10 , b11 
, c00 , c01 , c10 , c11 
, busy , done);

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial
begin
 reset = 1;  start = 0 ; a00  =0 ; a01  =0 ; a10  =0 ; a11  =0 ; b00  =0 ; b01  =0 ; b10  =0 ; b11  =0 ; 
 #12 ; start = 1 ; reset = 0; 
 // load matrix and assert start
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

if(c00 == 19 && c01 == 22 && c10 == 43 && c11 == 50)
begin
    $display(
        "PASS: Expected C=[19 22; 43 50], Got C=[%0d %0d; %0d %0d]",
        c00, c01, c10, c11
    );
end
else
begin
    $display(
        "FAIL: Expected C=[19 22; 43 50], Got C=[%0d %0d; %0d %0d]",
        c00, c01, c10, c11
    );
end

    //negative testing
    #12 ; start = 1 ; reset = 0; 
    a00 = -1;
    a01 = 2;
    a10 = 3;
    a11 = -4;

    b00 = 5;
    b01 = -6;
    b10 = -7;
    b11 = 8;

    #10;
    start = 0;
    wait(done == 1'b1);
    #1;

if(c00 == -19 && c01 == 22 && c10 == 43 && c11 == -50)
    begin
        $display(
            "PASS: Expected C=[-19 22; 43 -50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL: Expected C=[-19 22; 43 -50], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end

    //zero testing
    #12 ; start = 1 ; reset = 0; 
    a00 = -1;
    a01 = 8;
    a10 = -3;
    a11 = 2;

    b00 =0;
    b01 = 0;
    b10 = 0;
    b11 =0;

    #10;
    start = 0;
    wait(done == 1'b1);
    #1;

if(c00 == 0 && c01 ==0 && c10 ==0 && c11 == 0)
    begin
        $display(
            "PASS: Expected C=[0 0; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL: Expected C=[0 0; 0 0], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end

    //identity matrix testing
    #12 ; start = 1 ; reset = 0; 
    a00 = -1;
    a01 = 8;
    a10 = -3;
    a11 = 2;

    b00 =1;
    b01 = 0;
    b10 = 0;
    b11 =1;

    #10;
    start = 0;
    wait(done == 1'b1);
    #1;

if(c00 == -1 && c01 == 8 && c10 == -3 && c11 == 2)
    begin
        $display(
            "PASS: Expected C=[-1 8; -3 2], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end
    else
    begin
        $display(
            "FAIL: Expected C=[-1 8; -3 2], Got C=[%0d %0d; %0d %0d]",
            c00, c01, c10, c11
        );
    end

     //boundaRY CONDITION testing
    #12 ; start = 1 ; reset = 0; 
    a00 = -127;
    a01 = 127;
    a10 = -127;
    a11 = 127;

    b00 =127;
    b01 = 127;
    b10 = 127;
    b11 = -127;

    #10;
    start = 0;
    wait(done == 1'b1);
    #1;

if(c00 == 0 && c01 == -32258 && c10 == 0 && c11 == -32258)
begin
    $display(
        "PASS BOUNDARY: Expected C=[0 -32258; 0 -32258], Got C=[%0d %0d; %0d %0d]",
        c00, c01, c10, c11
    );
end
else
begin
    $display(
        "FAIL BOUNDARY: Expected C=[0 -32258; 0 -32258], Got C=[%0d %0d; %0d %0d]",
        c00, c01, c10, c11
    );
end
#10;
$finish;
end

initial
begin
    $dumpfile("v2_test.vcd");
    $dumpvars(0, v2_sequential_matmul_2x2_tb);
    $monitor(
        "T=%0t | clk=%b reset=%b start=%b busy=%b done=%b | A=[%0d %0d; %0d %0d] | B=[%0d %0d; %0d %0d] | C=[%0d %0d; %0d %0d]",
        $time,
        clk, reset, start, busy, done,
        a00, a01, a10, a11,
        b00, b01, b10, b11,
        c00, c01, c10, c11
    );
end
endmodule