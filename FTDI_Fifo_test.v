`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2024 17:34:57
// Design Name: 
// Module Name: FTDI_Fifo_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FTDI_Fifo_test(
    inout [7:0] DATA,        // Input and output data to/from FT2232H   // Bidirectional data port
    output READ_N,          // Output to FT2232H RD#
    output WRITE_N,          // Output to FT2232H WR#
    output OUT_EN,           // Output to FT2232H OE#
    output SEND_IM,          // Output to FT2232H SI/WUA#
    input GUI_RD_SP_WR_EF,               // Enable writing, driven by GUI_RD_SP_WR_EF# from FT2232H
    input GUI_WR_SP_RD_FF,               // Enable reading, driven by GUI_WR_SP_RD_FF# from FT2232H
    input CLK_FTDI,          // Clock input from FT2232H
    input RST_N,
    input CLK
);

parameter DATA_SIZE=10;
reg [7:0] count;      // Counter for writing
reg [63:0] rx_data;   // Buffer for read data
wire clk_120mhz;
wire clk_60mhz; 
wire [7:0] data_wr_buf;
wire [7:0] rx_data_buf;      
reg send_im_i;
// Clocking wizard instantiation
clk_wiz_0 dut(.clk_out1(clk_120mhz), .clk_in1(CLK));
//clk_wiz_0 CLK_WIZ (.clk_out2(clk_60mhz), .clk_in1(CLK));
reg [2:0]sync;
reg [1:0]sync_wr;

///////////////////fifo_generator Instance/////////////////////


always @(posedge CLK_FTDI or negedge RST_N )begin
       if(!RST_N) begin
           sync_wr[0] <= 1'b1;
           sync_wr[1] <= 1'b1;
       end
       else if(GUI_RD_SP_WR_EF == 1'b0) begin
               sync_wr[0] <= GUI_RD_SP_WR_EF;
               sync_wr[1] <= sync_wr[0];     
       end
       else if(GUI_RD_SP_WR_EF == 1'b1) begin
               sync_wr[1] <= 1'b1;
              
       end
 end  
always @(posedge CLK_FTDI or negedge RST_N )begin
       if(!RST_N) begin
          sync <= 3'b111;
       end
       else if(GUI_WR_SP_RD_FF == 1'b0) begin
               sync[0] <= GUI_WR_SP_RD_FF;
               sync[1] <= sync[0];
               sync[2] <= sync[1];
       end
       else if(GUI_WR_SP_RD_FF == 1'b1) begin
               sync[1] <= 1'b1;
               sync[2] <= 1'b1;
       end
 end   
// Write and Read Logic
reg start_tx;

reg [7:0] count_intr;
reg intr = 1'b0;


always @(posedge CLK_FTDI or negedge RST_N) begin
    if (!RST_N) begin 
       intr <= 1'b0;
        count_intr <= 8'd0;
    end 
    else if (count_intr == 8'd198) begin
        intr <= 1'b1;
        count_intr <= 8'd0;
    end
    else begin
             count_intr <= count_intr + 1'b1;
             intr <= 1'b0;
    end
end
reg [4:0] count_byte;
reg frame_flag; 
always @(posedge CLK_FTDI or negedge RST_N) begin
    if (!RST_N) begin
        send_im_i <= 1'b1;
//        rx_data <= 0;
        count <= 8'b0;
       
    end
    else begin
        // Write Logic
           if (!GUI_RD_SP_WR_EF && !sync_wr[1] && start_tx ==1'b1 && frame_flag == 1'b1) begin
               count <= count + 1'b1;
               count_byte <= count_byte + 1'b1;
//            count <= rx_data[7:0];
        
           end
           else if (!GUI_RD_SP_WR_EF && !sync_wr[1] && start_tx ==1'b1 && frame_flag == 1'b0) begin
//               count <= count;
                    count <= 0;
                    count_byte <= 5'd0;
      
           end
           else begin
                    count <= 0; 
           end
        // Read Logic
     end
 end     
 
 always @(posedge CLK_FTDI or negedge RST_N) begin
        if (~RST_N) begin
            frame_flag <= 1'b0;
        end
        else if (intr == 1'b1) begin
            frame_flag <= 1'b1;
        end 
        else if (count_byte == 5'd27) begin
                 frame_flag <= 1'b0;
        end
 
 
 end
 
  
 always @(posedge CLK_FTDI or negedge RST_N) begin
    if (!RST_N) begin
        start_tx <= 0;
        rx_data <= 0;
    end
      else begin
               if (!GUI_WR_SP_RD_FF) begin
                   rx_data <= {rx_data_buf,rx_data[63:8]};
                   start_tx <= 1'b0;
               end
               else begin
//        else if( rx_data == 24'haeadac) begin
                       start_tx <= 1'b1;
//                       rx_data <= 0;
                       rx_data <= rx_data;
//                    rx_data <= {rx_data[7:0],rx_data[79:8]} ;
               end
       end 
  end


assign data_wr_buf = count;
assign OUT_EN = sync[1];
assign READ_N = sync[2]; 
assign WRITE_N = sync_wr[1];
assign SEND_IM = send_im_i;

IOBUF DATA_PORT0 (.O(rx_data_buf[0]),.I(data_wr_buf[0]),.T(WRITE_N),.IO(DATA[0]));
IOBUF DATA_PORT1 (.O(rx_data_buf[1]),.I(data_wr_buf[1]),.T(WRITE_N),.IO(DATA[1]));
IOBUF DATA_PORT2 (.O(rx_data_buf[2]),.I(data_wr_buf[2]),.T(WRITE_N),.IO(DATA[2]));
IOBUF DATA_PORT3 (.O(rx_data_buf[3]),.I(data_wr_buf[3]),.T(WRITE_N),.IO(DATA[3]));
IOBUF DATA_PORT4 (.O(rx_data_buf[4]),.I(data_wr_buf[4]),.T(WRITE_N),.IO(DATA[4]));
IOBUF DATA_PORT5 (.O(rx_data_buf[5]),.I(data_wr_buf[5]),.T(WRITE_N),.IO(DATA[5]));
IOBUF DATA_PORT6 (.O(rx_data_buf[6]),.I(data_wr_buf[6]),.T(WRITE_N),.IO(DATA[6]));
IOBUF DATA_PORT7 (.O(rx_data_buf[7]),.I(data_wr_buf[7]),.T(WRITE_N),.IO(DATA[7]));


//assign rx_data_buf = DATA;


ila_0 ILA_FTDI (
.clk(clk_120mhz),
.probe0(READ_N),
.probe1(OUT_EN),
.probe2(start_tx),
.probe3(GUI_WR_SP_RD_FF),
.probe4(count_byte),
.probe5(frame_flag),
.probe6(intr),
.probe7(GUI_RD_SP_WR_EF),
.probe8(sync_wr[1])
);

endmodule

