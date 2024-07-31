`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module counter_8bit(

output [7:0] DATA_OUT ,         // Output of the counter
output reg   READ_N = 1'b1 ,      // output to FT2232H RD#
output reg   WRITE_N ,            // output to FT2232H WR#
output reg   OUT_EN = 1'b1,             // output to FT2232H OE#
output reg   SEND_IM = 1'b1,            // output to FT2232H SI/WUA#

input TX_FULL ,    // Enable counting, driven by TXE# from FT2232H
input RX_EMPTY,     // Enable counting, driven by RXF# from FT2232H
input CLK_FTDI ,   // clock input from FT2232H
input RST_N,
input CLK
);


reg [8:0] count = 0;
wire clk_120mhz;
reg clk_60mhz = 0;
//---------clocking wiz--------------------------------

 ila_0 ILA (
.clk(CLK),


.probe0(OUT_EN),
.probe1(READ_N),
.probe2(WRITE_N),
.probe3(RST_N),
.probe4(CLK_FTDI),
.probe5(RX_EMPTY),
.probe6(TX_FULL),
.probe7(DATA_OUT)
);

//-------------Counting 16 byte-----------------------------
always@(posedge CLK_FTDI or negedge RST_N) begin
    if(!RST_N) begin
        count <= 0;
        WRITE_N <= 1'b1;
    end
    else if(!TX_FULL) begin
        /*if(count > 15)begin
            count <= count;
            WRITE_N <= 1'b1;
        end
        else begin*/
        count <= count + 1'b1;
        WRITE_N <= 1'b0;
        //end
    end
    else begin
        count <= count;
        WRITE_N <= 1'b1;
    end
 end
 //------------ assign signal data
 assign DATA_OUT = count;
 
endmodule
