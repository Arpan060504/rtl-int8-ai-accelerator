module v4_systolic_pe_tb;

reg clk , reset , clear , enable ;
reg signed [7:0] a_in , b_in ;
wire signed [7:0] a_out , b_out;
wire signed [31:0] acc_out;

v4_systolic_pe pe_test(clk , reset , clear , enable , a_in , b_in 
, a_out , b_out , acc_out );

initial
    begin
    clk = 0;
    forever
        begin
            #5; clk = ~clk;
        end
    end

initial
    begin
        $dumpfile("pe_test.vcd");
        $dumpvars(0,v4_systolic_pe_tb);
        $monitor("T = %0t , clk =%b, reset =%b , clear =%b , enable =%b , A = %h | B = %h , a_out = %h , b_out = %h , acc_out = %h" 
                ,$time , clk , reset , clear , enable , a_in , b_in , a_out , b_out , acc_out);
    end

initial
begin
reset = 1 ; clear = 0 ; enable = 0 ; a_in = 0 ; b_in =0 ; 
#12 ;  reset = 0 ; clear = 0 ; enable = 0 ; 
#10 ; enable = 1 ; a_in = 80; b_in = 10;
#10;  enable =0 ;
if(a_out == 80 && b_out == 10 && acc_out == 800)
    begin
        $display(
            "PASS: Expected [A , B , out]=[80, 10, 800], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
    else
    begin
        $display(
            "FAIL: Expected [A , B , out]=[80, 10, 800], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
// forwarding operation as well as accumulation operation
#10 ; enable = 1 ; a_in = 9; b_in = 5;
#10; enable = 0 ;
 if(a_out == 9 && b_out == 5 && acc_out == 845)
    begin
        $display(
            "PASS: Expected [A , B , out]=[9, 5, 845], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
    else
    begin
        $display(
            "FAIL: Expected [A , B , out]=[9, 5, 845], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
// 0 testing 
clear = 1; enable = 0;
#10;
clear = 0; 
#10 ; enable = 1; a_in = 0; b_in = 0;

#10; enable  = 0;
  if(a_out == 0 && b_out == 0 && acc_out == 0)
    begin
        $display(
            "PASS: Expected [A , B , out]=[0, 0, 0], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
    else
    begin
        $display(
            "FAIL: Expected [A , B , out]=[0, 0, 0], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end

// negative testing
clear = 1; enable = 0;
#10;
clear = 0; 
#10 ;enable = 1; a_in = -30; b_in = 50;

#10;   enable =  0; 
if(a_out == -30 && b_out == 50 && acc_out == -1500)
    begin
        $display(
            "PASS: Expected [A , B , out]=[-30, 50, -1500], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end
    else
    begin
        $display(
            "FAIL: Expected [A , B , out]=[-30, 500, -1500], GOT [A , B , out] =[%0d %0d %0d]",a_out , b_out , acc_out );
    end


// finish test bench
#10  $finish();
end

initial
begin
    #500;
    $display("TIMEOUT");
    $finish;
end
endmodule
