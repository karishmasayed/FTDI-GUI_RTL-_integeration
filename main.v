
`timescale 1ns / 1ps


module cpld_mod0 #(parameter DATA_SIZE = 208)
(
input CLK,
input RESET,

 inout [7:0] DATA,        // Input and output data to/from FT2232H   // Bidirectional data port
 output READ_N,          // Output to FT2232H RD#
 output WRITE_N,          // Output to FT2232H WR#
 output OUT_EN,           // Output to FT2232H OE#
 output SEND_IM,          // Output to FT2232H SI/WUA#
 
 input GUI_RD_SP_WR_EF,               // Enable writing, driven by GUI_RD_SP_WR_EF# from FT2232H  TXE
 input GUI_WR_SP_RD_FF,               // Enable reading, driven by GUI_WR_SP_RD_FF# from FT2232H   RXE
 input CLK_FTDI,          // Clock input from FT2232H


input CLK_IN_P, 
input CLK_IN_N,
input DFRM_IN_P,
input DFRM_IN_N,
input SER_DATA_IN_P,
input SER_DATA_IN_N,

output SER_DATA_O_P,
output SER_DATA_O_N,
output CLK_OUT_P,
output CLK_OUT_N,
output DFRM_O_P,
output DFRM_O_N

);

//================================================================================================================================================================================================================================================
// ILA INSTANTIATION
//=================================================================================================================================================================================================================================================


ila_0 ILA_FTDI (
.clk(clk_120mhz),
.probe0(frame_count),
.probe1(CLK_FTDI),
.probe2(mts_count),
.probe3(waiting_done),
.probe4(data_wr_buf),
.probe5(start_tx),
.probe6(WRITE_N_i),
.probe7(GUI_RD_SP_WR_EF),
.probe8(clk_5k),
.probe9(posedge_clk_5k),
.probe10(SER_DATA_IN),
.probe11(DFRM_IN),
.probe12(clk_5Mhz),
.probe13(SER_DATA_O),
.probe14(DFRM_O),
.probe15(CLK_IN),
.probe16(DATA_RECEVIED),
.probe17(CPLD_data_1),
.probe18(out_cnt),
.probe19(in_cnt) 
);

//================================================================================================================================================================
// LVDS
//=================================================================================================================================================================
 IBUFDS IBUFDS_inst_CLK_IN(
 .O(CLK_IN), //Bufferoutput
 .I(CLK_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(CLK_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );
 
 IBUFDS IBUFDS_inst_SER_DATA_IN(
 .O(SER_DATA_IN), //Bufferoutput
 .I(SER_DATA_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(SER_DATA_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );
 
  IBUFDS IBUFDS_inst_DFRM_IN(
 .O(DFRM_IN), //Bufferoutput
 .I(DFRM_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(DFRM_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );

 OBUFDS OBUFDS_inst_CLK_OUT(
 .O(CLK_OUT_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(CLK_OUT_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(clk_5Mhz) //Bufferinput
 );
 
  OBUFDS OBUFDS_inst_SER_DATA_O(
 .O(SER_DATA_O_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(SER_DATA_O_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(SER_DATA_O) //Bufferinput
 );
 
  OBUFDS OBUFDS_inst_DFRM_O(
 .O(DFRM_O_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(DFRM_O_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(DFRM_O) //Bufferinput
 );
 
 
 
IOBUF DATA_PORT0 (.O(rx_data_buf[0]),.I(data_wr_buf[0]),.T(WRITE_N),.IO(DATA[0]));
IOBUF DATA_PORT1 (.O(rx_data_buf[1]),.I(data_wr_buf[1]),.T(WRITE_N),.IO(DATA[1]));
IOBUF DATA_PORT2 (.O(rx_data_buf[2]),.I(data_wr_buf[2]),.T(WRITE_N),.IO(DATA[2]));
IOBUF DATA_PORT3 (.O(rx_data_buf[3]),.I(data_wr_buf[3]),.T(WRITE_N),.IO(DATA[3]));
IOBUF DATA_PORT4 (.O(rx_data_buf[4]),.I(data_wr_buf[4]),.T(WRITE_N),.IO(DATA[4]));
IOBUF DATA_PORT5 (.O(rx_data_buf[5]),.I(data_wr_buf[5]),.T(WRITE_N),.IO(DATA[5]));
IOBUF DATA_PORT6 (.O(rx_data_buf[6]),.I(data_wr_buf[6]),.T(WRITE_N),.IO(DATA[6]));
IOBUF DATA_PORT7 (.O(rx_data_buf[7]),.I(data_wr_buf[7]),.T(WRITE_N),.IO(DATA[7]));


 
//================================================================================================================================================================
// DECLARATIONS
//=================================================================================================================================================================

reg [8:0] count;
wire clk_120mhz;
wire clk_60mhz;

reg [6:0] frame_count;
reg [5:0] mts_count;


wire CLK_ILA;

wire [7:0] data_in;
wire [7:0] data_out;
//wire out_en;

reg out_en_i;
reg  [7:0] data_out_i;

wire reset_cpld0;
wire  reset_cpld1;
reg sample_done;
reg INTER;

reg frame_out;
reg [$clog2(DATA_SIZE+1)-1:0] out_cnt;
reg [$clog2(DATA_SIZE+1)-1:0] in_cnt;
reg [DATA_SIZE-1:0] out_reg;
reg [1:0] clk_div;

//shift in
reg  s_frame_in_reg;
reg [DATA_SIZE:0] in_reg;
wire [DATA_SIZE-1:0] DATA_2_SEND_I = 8'b01011100;
reg [DATA_SIZE-1:0] DATA_RECVD_O;

reg [191:0] DATA_RECEVIED;
reg [(DATA_SIZE-1):0] DATA_RECEVIED_1;

reg d_out;

reg sync0_CLK_IN;
reg sync1_CLK_IN;

reg sync0_DFRM_IN;
reg sync1_DFRM_IN;

reg sync0_SER_DATA_IN;
reg sync1_SER_DATA_IN;

reg sync0_CLK_OUT;
reg sync1_CLK_OUT;


wire posedge_CLK_IN;
wire posedge_DFRM_IN;
wire posedge_CLK_OUT;

reg [1:0] counter;
 

wire [DATA_SIZE-1:0]ser_mod_data;
reg  [DATA_SIZE-1:0] mod_adc_data;
reg  send_mod_data;
reg [((DATA_SIZE)/8)-1:0] ch0_data=1'b0;
reg [((DATA_SIZE)/8)-1:0] ch1_data=1'b0;
reg [((DATA_SIZE)/8)-1:0] ch2_data=1'b1;
reg [((DATA_SIZE)/8)-1:0] ch3_data=1'b0;
reg [((DATA_SIZE)/8)-1:0] ch4_data=1'b0;
reg [((DATA_SIZE)/8)-1:0] ch5_data=1'b1;
reg [((DATA_SIZE)/8)-1:0] ch6_data=1'b1;
reg [((DATA_SIZE)/8)-1:0] ch7_data=1'b0;

wire  all_ch_sampling_done;

//================================================================================================================================================================
// OUTPUT ASSIGNMENT
//=================================================================================================================================================================

assign DFRM_O = frame_out;
assign SER_DATA_O = d_out;//out_reg[0];
assign reset_cpld0 = RESET;
assign reset_cpld1 = RESET;



assign data_out [7:0] = data_out_i [7:0];
assign out_en = out_en_i;

//================================================================================================================================================================
// FIFO MODULE
//=================================================================================================================================================================


reg [7:0] count;      // Counter for writing
reg [63:0] rx_data;   // Buffer for read data
wire clk_120mhz;
wire clk_60mhz;
wire clk_200mhz; 
wire [7:0] data_wr_buf;
wire [7:0] rx_data_buf;      
reg send_im_i;

//clk_wiz_0 CLK_WIZ (.clk_out2(clk_60mhz), .clk_in1(CLK));
reg [2:0]sync;
reg [2:0]sync_wr;



reg [5:0] frame_count;
reg [5:0] mts_count;

reg WRITE_N_i;

wire CLK_ILA;

wire [7:0] data_in;
wire [7:0] data_out;
//wire out_en;

reg out_en_i;
reg  [7:0] data_out_i;

wire reset_cpld0;
wire  reset_cpld1;
reg sample_done;
reg INTER;

reg [191:0] CPLD_data_1;
reg [191:0] CPLD_data_2;
reg [191:0] CPLD_data_3;
reg [191:0] CPLD_data_4;

reg [191:0] CPLD_data_5;
reg [191:0] CPLD_data_6;

reg [191:0] CPLD_data_7;
reg [191:0] CPLD_data_8;

reg [191:0] CPLD_data_9;
reg [191:0] CPLD_data_10;

reg [191:0] CPLD_data_11;
reg [191:0] CPLD_data_12;

reg [191:0] CPLD_data_14;
reg [191:0] CPLD_data_15;

reg [191:0] CPLD_data_16;
reg [191:0] CPLD_data_13;


wire [191:0] CPLD_1;
wire [191:0] CPLD_2;
wire [191:0] CPLD_3;
wire [191:0] CPLD_4;

wire [191:0] CPLD_5;
wire [191:0] CPLD_6;

wire [191:0] CPLD_7;
wire [191:0] CPLD_8;

wire [191:0] CPLD_9;
wire [191:0] CPLD_10;

wire [191:0] CPLD_11;
wire [191:0] CPLD_12;

wire [191:0] CPLD_14;
wire [191:0] CPLD_15;

wire [191:0] CPLD_16;
wire [191:0] CPLD_13;


reg start_tx;
///////////////////fifo_generator Instance/////////////////////
reg [3:0] sync_counter;
  reg sync_txx;
reg [25:0] clk_counter;

reg clk_5k;
reg sync0_clk_5k;
reg sync1_clk_5k;
wire posedge_clk_5k;



reg sync0_sync_wr;
reg sync1_sync_wr;
wire posedge_sync_wr;

reg waiting_done;
reg [4:0] ftdi_counter;

//reg start_tx;

reg [7:0] count_intr;
reg intr = 1'b0;

reg [4:0] count_byte;
reg frame_flag; 

reg [24:0] write_counter;


reg [5:0] counter_5Mhz;
reg clk_5Mhz;

always @(posedge CLK or negedge RESET) begin
    if(!RESET) begin
       counter_5Mhz <= 'd0;
       clk_5Mhz <= 0;
       end 
    else begin
         if(counter_5Mhz == 4) begin  ///24999999
            counter_5Mhz <= 'd0;
            clk_5Mhz <= ~clk_5Mhz;
            end
         else begin
              counter_5Mhz <= counter_5Mhz + 1;
              end                                          
         end
end

always @(posedge clk_60mhz or negedge RESET) begin
    if(!RESET) begin
       clk_counter <= 26'd0;
       clk_5k <= 0;
       end 
    else begin
         if(clk_counter == 26'd29999999) begin  ///24999999
            clk_counter <= 26'd0;
            clk_5k <= ~clk_5k;
            end
         else begin
              clk_counter <= clk_counter + 1;
              end                                          
         end
end

reg clk;
reg [23:0] counter;
reg [23:0] counter_r;

always @(posedge clk_60mhz or negedge RESET) begin
    if(!RESET) begin
       counter_r <= 24'd0;
       clk     <= 0;
       end 
    else begin
         if(counter_r == 24'd999999) begin  ///24999999
            counter_r <= 24'd0;
            clk <= ~clk;
            end
         else begin
              counter_r <= counter_r + 1;
              end                                          
         end
end

always @(posedge clk or negedge RESET) begin
    if(!RESET) begin
       counter <= 24'd0;
       end 
    else begin
              counter <= counter + 1;                                         
         end
end



assign CPLD_1 = DATA_RECEVIED;
assign CPLD_2 = DATA_RECEVIED;
assign CPLD_3 = DATA_RECEVIED;
assign CPLD_4 = DATA_RECEVIED;
assign CPLD_5 = DATA_RECEVIED;
assign CPLD_6 = DATA_RECEVIED;
assign CPLD_7 = DATA_RECEVIED;
assign CPLD_8 = DATA_RECEVIED;
assign CPLD_9 = DATA_RECEVIED;
assign CPLD_10 = DATA_RECEVIED;
assign CPLD_16 = DATA_RECEVIED;

assign CPLD_11 = DATA_RECEVIED;

assign CPLD_12 = DATA_RECEVIED;

assign CPLD_13 = DATA_RECEVIED;

assign CPLD_14 = DATA_RECEVIED;
assign CPLD_15 = DATA_RECEVIED;




///////////////////////////////////////////////

wire posedge_clk_ftdi;


always @(posedge clk_120mhz or negedge RESET)
begin
	if(~RESET) begin
	     sync0_clk_5k <= 0;
         sync1_clk_5k <= 0;
	end
	else begin
		 sync0_clk_5k <= clk_5k;
         sync1_clk_5k <= sync0_clk_5k ;
        end
end

assign posedge_clk_5k = sync0_clk_5k & ~sync1_clk_5k;

always @(posedge sync_wr[1] or negedge RESET)
begin
	if(~RESET) begin
	     sync0_sync_wr <= 0;
         sync1_sync_wr <= 0;
	end
	else begin
		 sync0_sync_wr <= sync_wr[1];
         sync1_sync_wr <= sync0_sync_wr ;
        end
end

assign posedge_sync_wr = sync0_sync_wr & ~sync1_sync_wr;
///////////////////////
reg sync0_clk_ftdi;
reg sync1_clk_ftdi;
wire posedge_clk_ftdi;

always @(posedge clk_120mhz or negedge RESET)
begin
	if(~RESET) begin
	     sync0_clk_ftdi <= 0;
         sync1_clk_ftdi <= 0;
	end
	else begin
		 sync0_clk_ftdi <= CLK_FTDI;
         sync1_clk_ftdi <= sync0_clk_ftdi ;
        end
end

assign posedge_clk_ftdi = CLK_FTDI & ~sync0_clk_ftdi;
///////////////////////



always @(posedge clk_120mhz or negedge RESET)
begin
	if(~RESET) begin
	   waiting_done <= 0;
	   end
    else begin if (posedge_clk_5k) 
                   waiting_done <= 1; 
               if (mts_count == 15 && frame_count == 55) begin////////////////////////////
                   waiting_done <= 0;
                   end
         end         
end

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
       start_tx <= 0;
	   end
       else begin
         if(GUI_RD_SP_WR_EF == 1'b0) 
            start_tx <= 1;   
      
           if(WRITE_N_i == 1)
            start_tx <= 0;   
        end      
  end                      


always @(posedge clk_120mhz or negedge RESET)
begin
	if(~RESET) begin
       WRITE_N_i <= 1;
	   end
    else begin
               if(GUI_RD_SP_WR_EF == 1'b0) begin////////////////
                  WRITE_N_i <= 0;
                  end 
               if(waiting_done == 0)   
                  WRITE_N_i <= 1;
         end         
end

//////////////////////////////////
always @(posedge CLK_FTDI or negedge RESET )begin
       if(!RESET) begin
           sync_wr[0] <= 1'b1;
           sync_wr[1] <= 1'b1;
           sync_wr[2] <= 1'b1;
       end
       else if(GUI_RD_SP_WR_EF == 1'b0) begin
               sync_wr[0] <= GUI_RD_SP_WR_EF;
               sync_wr[1] <= sync_wr[0];  
               sync_wr[2] <=  sync_wr[1]; 
       end
       else if(GUI_RD_SP_WR_EF == 1'b1) begin
               sync_wr[1] <= 1'b1;
              
       end
 end  

always @(posedge CLK_FTDI or negedge RESET )begin
       if(!RESET) begin
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





 
 always @(posedge clk_60mhz or negedge RESET) begin
        if (~RESET) begin
            write_counter <= 'b0;
        end
        else if (WRITE_N_i == 1'b1) begin
                 write_counter = write_counter + 1;
                 end 
             else write_counter <= 'b0;
 end
 
   


always@(posedge CLK_FTDI or posedge WRITE_N_i) begin
    if(WRITE_N_i) begin
        data_out_i  <= 'd0;
        frame_count <= 0;
        mts_count   <= 0;
        out_en_i    <= 1;
        CPLD_data_1 <= CPLD_1;
        CPLD_data_2 <= CPLD_2;
        
        CPLD_data_3 <= CPLD_3;
        CPLD_data_4 <= CPLD_4;
        
        CPLD_data_5 <= CPLD_5;
        CPLD_data_6 <= CPLD_6;
        
        CPLD_data_7 <= CPLD_7;
        CPLD_data_8 <= CPLD_8;
        
        CPLD_data_9  <= CPLD_9;
        CPLD_data_10 <= CPLD_10;
        
        CPLD_data_11 <= CPLD_11;
        CPLD_data_12 <= CPLD_12;
        
        CPLD_data_13 <= CPLD_13;
        CPLD_data_14 <= CPLD_14;
        
        CPLD_data_15 <= CPLD_15;
        CPLD_data_16 <= CPLD_16;                        
        
        ftdi_counter <= 'd0;
        //WRITE_N_i <= 0;
      //  CPLD_data_1 <= 'd0;
       // CPLD_data_2 <= 'd0;
      end
    else begin 
      if(waiting_done && start_tx) begin
      /// if(~GUI_RD_SP_WR_EF) begin
            if(mts_count == 0) begin
                 if(frame_count ==  30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                        //  WRITE_N_i <= 0;
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h01;
                          8'd4  : data_out_i <= CPLD_data_1 [191:184];
                          8'd5  : data_out_i <= CPLD_data_1 [183:176];
                          8'd6  : data_out_i <= CPLD_data_1 [175:168];
                          8'd7  : data_out_i <= CPLD_data_1 [167:160];
                          8'd8  : data_out_i <= CPLD_data_1 [159:152];
                          8'd9  : data_out_i <= CPLD_data_1 [151:144];
                          8'd10 : data_out_i <= CPLD_data_1 [143:136];
                          8'd11 : data_out_i <= CPLD_data_1 [135:128];
                          8'd12 : data_out_i <= CPLD_data_1 [127:120];
                          8'd13 : data_out_i <= CPLD_data_1 [119:112];
                          8'd14 : data_out_i <= CPLD_data_1 [111:104];
                          8'd15 : data_out_i <= CPLD_data_1 [103:96];
                          8'd16 : data_out_i <= CPLD_data_1 [95:88];
                          8'd17 : data_out_i <= CPLD_data_1 [87:80];
                          8'd18 : data_out_i <= CPLD_data_1 [79:72];
                          8'd19 : data_out_i <= CPLD_data_1 [71:64];
                          8'd20 : data_out_i <= CPLD_data_1 [63:56];
                          8'd21 : data_out_i <= CPLD_data_1 [55:48];
                          8'd22 : data_out_i <= CPLD_data_1 [47:40];
                          8'd23 : data_out_i <= CPLD_data_1 [39:32];
                          8'd24 : data_out_i <= CPLD_data_1 [31:24];
                          8'd25 : data_out_i <= CPLD_data_1 [23:16];
                          8'd25 : data_out_i <= CPLD_data_1 [15:8];
                          8'd27 : data_out_i <= CPLD_data_1 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                        end
               end
           if(mts_count == 1) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;    
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h02;
                          8'd4  : data_out_i <= CPLD_data_2 [191:184];
                          8'd5  : data_out_i <= CPLD_data_2 [183:176];
                          8'd6  : data_out_i <= CPLD_data_2 [175:168];
                          8'd7  : data_out_i <= CPLD_data_2 [167:160];
                          8'd8  : data_out_i <= CPLD_data_2 [159:152];
                          8'd9  : data_out_i <= CPLD_data_2 [151:144];
                          8'd10 : data_out_i <= CPLD_data_2 [143:136];
                          8'd11 : data_out_i <= CPLD_data_2 [135:128];
                          8'd12 : data_out_i <= CPLD_data_2 [127:120];
                          8'd13 : data_out_i <= CPLD_data_2 [119:112];
                          8'd14 : data_out_i <= CPLD_data_2 [111:104];
                          8'd15 : data_out_i <= CPLD_data_2 [103:96];
                          8'd16 : data_out_i <= CPLD_data_2 [95:88];
                          8'd17 : data_out_i <= CPLD_data_2 [87:80];
                          8'd18 : data_out_i <= CPLD_data_2 [79:72];
                          8'd19 : data_out_i <= CPLD_data_2 [71:64];
                          8'd20 : data_out_i <= CPLD_data_2 [63:56];
                          8'd21 : data_out_i <= CPLD_data_2 [55:48];
                          8'd22 : data_out_i <= CPLD_data_2 [47:40];
                          8'd23 : data_out_i <= CPLD_data_2 [39:32];
                          8'd24 : data_out_i <= CPLD_data_2 [31:24];
                          8'd25 : data_out_i <= CPLD_data_2 [23:16];
                          8'd25 : data_out_i <= CPLD_data_2 [15:8];
                          8'd27 : data_out_i <= CPLD_data_2 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 2) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h03;
                          8'd4  : data_out_i <= CPLD_data_3 [191:184];
                          8'd5  : data_out_i <= CPLD_data_3 [183:176];
                          8'd6  : data_out_i <= CPLD_data_3 [175:168];
                          8'd7  : data_out_i <= CPLD_data_3 [167:160];
                          8'd8  : data_out_i <= CPLD_data_3 [159:152];
                          8'd9  : data_out_i <= CPLD_data_3 [151:144];
                          8'd10  : data_out_i <= CPLD_data_3 [143:136];
                          8'd11 : data_out_i <= CPLD_data_3 [135:128];
                          8'd12 : data_out_i <= CPLD_data_3 [127:120];
                          8'd13 : data_out_i <= CPLD_data_3 [119:112];
                          8'd14 : data_out_i <= CPLD_data_3 [111:104];
                          8'd15 : data_out_i <= CPLD_data_3 [103:96];
                          8'd16 : data_out_i <= CPLD_data_3 [95:88];
                          8'd17 : data_out_i <= CPLD_data_3 [87:80];
                          8'd18 : data_out_i <= CPLD_data_3 [79:72];
                          8'd19 : data_out_i <= CPLD_data_3 [71:64];
                          8'd20 : data_out_i <= CPLD_data_3 [63:56];
                          8'd21 : data_out_i <= CPLD_data_3 [55:48];
                          8'd22 : data_out_i <= CPLD_data_3 [47:40];
                          8'd23 : data_out_i <= CPLD_data_3 [39:32];
                          8'd24 : data_out_i <= CPLD_data_3 [31:24];
                          8'd25 : data_out_i <= CPLD_data_3 [23:16];
                          8'd25 : data_out_i <= CPLD_data_3 [15:8];
                          8'd27 : data_out_i <= CPLD_data_3 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 3) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                         8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h04;
                          8'd4  : data_out_i <= CPLD_data_4 [191:184];
                          8'd5  : data_out_i <= CPLD_data_4 [183:176];
                          8'd6  : data_out_i <= CPLD_data_4 [175:168];
                          8'd7  : data_out_i <= CPLD_data_4 [167:160];
                          8'd8  : data_out_i <= CPLD_data_4 [159:152];
                          8'd9  : data_out_i <= CPLD_data_4 [151:144];
                          8'd10  : data_out_i <= CPLD_data_4 [143:136];
                          8'd11 : data_out_i <= CPLD_data_4 [135:128];
                          8'd12 : data_out_i <= CPLD_data_4 [127:120];
                          8'd13 : data_out_i <= CPLD_data_4 [119:112];
                          8'd14 : data_out_i <= CPLD_data_4 [111:104];
                          8'd15 : data_out_i <= CPLD_data_4 [103:96];
                          8'd16 : data_out_i <= CPLD_data_4 [95:88];
                          8'd17 : data_out_i <= CPLD_data_4 [87:80];
                          8'd18 : data_out_i <= CPLD_data_4 [79:72];
                          8'd19 : data_out_i <= CPLD_data_4 [71:64];
                          8'd20 : data_out_i <= CPLD_data_4 [63:56];
                          8'd21 : data_out_i <= CPLD_data_4 [55:48];
                          8'd22 : data_out_i <= CPLD_data_4 [47:40];
                          8'd23 : data_out_i <= CPLD_data_4 [39:32];
                          8'd24 : data_out_i <= CPLD_data_4 [31:24];
                          8'd25 : data_out_i <= CPLD_data_4 [23:16];
                          8'd25 : data_out_i <= CPLD_data_4 [15:8];
                          8'd27 : data_out_i <= CPLD_data_4 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 4) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h05;
                          8'd4  : data_out_i <= CPLD_data_5 [191:184];
                          8'd5  : data_out_i <= CPLD_data_5 [183:176];
                          8'd6  : data_out_i <= CPLD_data_5 [175:168];
                          8'd7  : data_out_i <= CPLD_data_5 [167:160];
                          8'd8  : data_out_i <= CPLD_data_5 [159:152];
                          8'd9  : data_out_i <= CPLD_data_5 [151:144];
                          8'd10  : data_out_i <= CPLD_data_5 [143:136];
                          8'd11 : data_out_i <= CPLD_data_5 [135:128];
                          8'd12 : data_out_i <= CPLD_data_5 [127:120];
                          8'd13 : data_out_i <= CPLD_data_5 [119:112];
                          8'd14 : data_out_i <= CPLD_data_5 [111:104];
                          8'd15 : data_out_i <= CPLD_data_5 [103:96];
                          8'd16 : data_out_i <= CPLD_data_5 [95:88];
                          8'd17 : data_out_i <= CPLD_data_5 [87:80];
                          8'd18 : data_out_i <= CPLD_data_5 [79:72];
                          8'd19 : data_out_i <= CPLD_data_5 [71:64];
                          8'd20 : data_out_i <= CPLD_data_5 [63:56];
                          8'd21 : data_out_i <= CPLD_data_5 [55:48];
                          8'd22 : data_out_i <= CPLD_data_5 [47:40];
                          8'd23 : data_out_i <= CPLD_data_5 [39:32];
                          8'd24 : data_out_i <= CPLD_data_5 [31:24];
                          8'd25 : data_out_i <= CPLD_data_5 [23:16];
                          8'd25 : data_out_i <= CPLD_data_5 [15:8];
                          8'd27 : data_out_i <= CPLD_data_5 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 5) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h06;
                          8'd4  : data_out_i <= CPLD_data_6 [191:184];
                          8'd5  : data_out_i <= CPLD_data_6 [183:176];
                          8'd6  : data_out_i <= CPLD_data_6 [175:168];
                          8'd7  : data_out_i <= CPLD_data_6 [167:160];
                          8'd8  : data_out_i <= CPLD_data_6 [159:152];
                          8'd9  : data_out_i <= CPLD_data_6 [151:144];
                          8'd10  : data_out_i <= CPLD_data_6 [143:136];
                          8'd11 : data_out_i <= CPLD_data_6 [135:128];
                          8'd12 : data_out_i <= CPLD_data_6 [127:120];
                          8'd13 : data_out_i <= CPLD_data_6 [119:112];
                          8'd14 : data_out_i <= CPLD_data_6 [111:104];
                          8'd15 : data_out_i <= CPLD_data_6 [103:96];
                          8'd16 : data_out_i <= CPLD_data_6 [95:88];
                          8'd17 : data_out_i <= CPLD_data_6 [87:80];
                          8'd18 : data_out_i <= CPLD_data_6 [79:72];
                          8'd19 : data_out_i <= CPLD_data_6 [71:64];
                          8'd20 : data_out_i <= CPLD_data_6 [63:56];
                          8'd21 : data_out_i <= CPLD_data_6 [55:48];
                          8'd22 : data_out_i <= CPLD_data_6 [47:40];
                          8'd23 : data_out_i <= CPLD_data_6 [39:32];
                          8'd24 : data_out_i <= CPLD_data_6 [31:24];
                          8'd25 : data_out_i <= CPLD_data_6 [23:16];
                          8'd25 : data_out_i <= CPLD_data_6 [15:8];
                          8'd27 : data_out_i <= CPLD_data_6 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 6) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h07;
                          8'd4  : data_out_i <= CPLD_data_7 [191:184];
                          8'd5  : data_out_i <= CPLD_data_7 [183:176];
                          8'd6  : data_out_i <= CPLD_data_7 [175:168];
                          8'd7  : data_out_i <= CPLD_data_7 [167:160];
                          8'd8  : data_out_i <= CPLD_data_7 [159:152];
                          8'd9  : data_out_i <= CPLD_data_7 [151:144];
                          8'd10  : data_out_i <= CPLD_data_7 [143:136];
                          8'd11 : data_out_i <= CPLD_data_7 [135:128];
                          8'd12 : data_out_i <= CPLD_data_7 [127:120];
                          8'd13 : data_out_i <= CPLD_data_7 [119:112];
                          8'd14 : data_out_i <= CPLD_data_7 [111:104];
                          8'd15 : data_out_i <= CPLD_data_7 [103:96];
                          8'd16 : data_out_i <= CPLD_data_7 [95:88];
                          8'd17 : data_out_i <= CPLD_data_7 [87:80];
                          8'd18 : data_out_i <= CPLD_data_7 [79:72];
                          8'd19 : data_out_i <= CPLD_data_7 [71:64];
                          8'd20 : data_out_i <= CPLD_data_7 [63:56];
                          8'd21 : data_out_i <= CPLD_data_7 [55:48];
                          8'd22 : data_out_i <= CPLD_data_7 [47:40];
                          8'd23 : data_out_i <= CPLD_data_7 [39:32];
                          8'd24 : data_out_i <= CPLD_data_7 [31:24];
                          8'd25 : data_out_i <= CPLD_data_7 [23:16];
                          8'd25 : data_out_i <= CPLD_data_7 [15:8];
                          8'd27 : data_out_i <= CPLD_data_7 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 7) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h08;
                          8'd4  : data_out_i <= CPLD_data_8 [191:184];
                          8'd5  : data_out_i <= CPLD_data_8 [183:176];
                          8'd6  : data_out_i <= CPLD_data_8 [175:168];
                          8'd7  : data_out_i <= CPLD_data_8 [167:160];
                          8'd8  : data_out_i <= CPLD_data_8 [159:152];
                          8'd9  : data_out_i <= CPLD_data_8 [151:144];
                          8'd10  : data_out_i <= CPLD_data_8 [143:136];
                          8'd11 : data_out_i <= CPLD_data_8 [135:128];
                          8'd12 : data_out_i <= CPLD_data_8 [127:120];
                          8'd13 : data_out_i <= CPLD_data_8 [119:112];
                          8'd14 : data_out_i <= CPLD_data_8 [111:104];
                          8'd15 : data_out_i <= CPLD_data_8 [103:96];
                          8'd16 : data_out_i <= CPLD_data_8 [95:88];
                          8'd17 : data_out_i <= CPLD_data_8 [87:80];
                          8'd18 : data_out_i <= CPLD_data_8 [79:72];
                          8'd19 : data_out_i <= CPLD_data_8 [71:64];
                          8'd20 : data_out_i <= CPLD_data_8 [63:56];
                          8'd21 : data_out_i <= CPLD_data_8 [55:48];
                          8'd22 : data_out_i <= CPLD_data_8 [47:40];
                          8'd23 : data_out_i <= CPLD_data_8 [39:32];
                          8'd24 : data_out_i <= CPLD_data_8 [31:24];
                          8'd25 : data_out_i <= CPLD_data_8 [23:16];
                          8'd25 : data_out_i <= CPLD_data_8 [15:8];
                          8'd27 : data_out_i <= CPLD_data_8 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 8) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h09;
                          8'd4  : data_out_i <= CPLD_data_9 [191:184];
                          8'd5  : data_out_i <= CPLD_data_9 [183:176];
                          8'd6  : data_out_i <= CPLD_data_9 [175:168];
                          8'd7  : data_out_i <= CPLD_data_9 [167:160];
                          8'd8  : data_out_i <= CPLD_data_9 [159:152];
                          8'd9  : data_out_i <= CPLD_data_9 [151:144];
                          8'd10  : data_out_i <= CPLD_data_9 [143:136];
                          8'd11 : data_out_i <= CPLD_data_9 [135:128];
                          8'd12 : data_out_i <= CPLD_data_9 [127:120];
                          8'd13 : data_out_i <= CPLD_data_9 [119:112];
                          8'd14 : data_out_i <= CPLD_data_9 [111:104];
                          8'd15 : data_out_i <= CPLD_data_9 [103:96];
                          8'd16 : data_out_i <= CPLD_data_9 [95:88];
                          8'd17 : data_out_i <= CPLD_data_9 [87:80];
                          8'd18 : data_out_i <= CPLD_data_9 [79:72];
                          8'd19 : data_out_i <= CPLD_data_9 [71:64];
                          8'd20 : data_out_i <= CPLD_data_9 [63:56];
                          8'd21 : data_out_i <= CPLD_data_9 [55:48];
                          8'd22 : data_out_i <= CPLD_data_9 [47:40];
                          8'd23 : data_out_i <= CPLD_data_9 [39:32];
                          8'd24 : data_out_i <= CPLD_data_9 [31:24];
                          8'd25 : data_out_i <= CPLD_data_9 [23:16];
                          8'd25 : data_out_i <= CPLD_data_9 [15:8];
                          8'd27 : data_out_i <= CPLD_data_9 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 9) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                    mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0A;
                          8'd4  : data_out_i <= CPLD_data_10 [191:184];
                          8'd5  : data_out_i <= CPLD_data_10 [183:176];
                          8'd6  : data_out_i <= CPLD_data_10 [175:168];
                          8'd7  : data_out_i <= CPLD_data_10 [167:160];
                          8'd8  : data_out_i <= CPLD_data_10 [159:152];
                          8'd9  : data_out_i <= CPLD_data_10 [151:144];
                          8'd10  : data_out_i <= CPLD_data_10 [143:136];
                          8'd11 : data_out_i <= CPLD_data_10 [135:128];
                          8'd12 : data_out_i <= CPLD_data_10 [127:120];
                          8'd13 : data_out_i <= CPLD_data_10 [119:112];
                          8'd14 : data_out_i <= CPLD_data_10 [111:104];
                          8'd15 : data_out_i <= CPLD_data_10 [103:96];
                          8'd16 : data_out_i <= CPLD_data_10 [95:88];
                          8'd17 : data_out_i <= CPLD_data_10 [87:80];
                          8'd18 : data_out_i <= CPLD_data_10 [79:72];
                          8'd19 : data_out_i <= CPLD_data_10 [71:64];
                          8'd20 : data_out_i <= CPLD_data_10 [63:56];
                          8'd21 : data_out_i <= CPLD_data_10 [55:48];
                          8'd22 : data_out_i <= CPLD_data_10 [47:40];
                          8'd23 : data_out_i <= CPLD_data_10 [39:32];
                          8'd24 : data_out_i <= CPLD_data_10 [31:24];
                          8'd25 : data_out_i <= CPLD_data_10 [23:16];
                          8'd25 : data_out_i <= CPLD_data_10 [15:8];
                          8'd27 : data_out_i <= CPLD_data_10 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 10) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0B;
                          8'd4  : data_out_i <= CPLD_data_11 [191:184];
                          8'd5  : data_out_i <= CPLD_data_11 [183:176];
                          8'd6  : data_out_i <= CPLD_data_11 [175:168];
                          8'd7  : data_out_i <= CPLD_data_11 [167:160];
                          8'd8  : data_out_i <= CPLD_data_11 [159:152];
                          8'd9  : data_out_i <= CPLD_data_11 [151:144];
                          8'd10  : data_out_i <= CPLD_data_11 [143:136];
                          8'd11 : data_out_i <= CPLD_data_11 [135:128];
                          8'd12 : data_out_i <= CPLD_data_11 [127:120];
                          8'd13 : data_out_i <= CPLD_data_11 [119:112];
                          8'd14 : data_out_i <= CPLD_data_11 [111:104];
                          8'd15 : data_out_i <= CPLD_data_11 [103:96];
                          8'd16 : data_out_i <= CPLD_data_11 [95:88];
                          8'd17 : data_out_i <= CPLD_data_11 [87:80];
                          8'd18 : data_out_i <= CPLD_data_11 [79:72];
                          8'd19 : data_out_i <= CPLD_data_11 [71:64];
                          8'd20 : data_out_i <= CPLD_data_11 [63:56];
                          8'd21 : data_out_i <= CPLD_data_11 [55:48];
                          8'd22 : data_out_i <= CPLD_data_11 [47:40];
                          8'd23 : data_out_i <= CPLD_data_11 [39:32];
                          8'd24 : data_out_i <= CPLD_data_11 [31:24];
                          8'd25 : data_out_i <= CPLD_data_11 [23:16];
                          8'd25 : data_out_i <= CPLD_data_11 [15:8];
                          8'd27 : data_out_i <= CPLD_data_11 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 11) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0C;
                          8'd4  : data_out_i <= CPLD_data_12 [191:184];
                          8'd5  : data_out_i <= CPLD_data_12 [183:176];
                          8'd6  : data_out_i <= CPLD_data_12 [175:168];
                          8'd7  : data_out_i <= CPLD_data_12 [167:160];
                          8'd8  : data_out_i <= CPLD_data_12 [159:152];
                          8'd9  : data_out_i <= CPLD_data_12 [151:144];
                          8'd10  : data_out_i <= CPLD_data_12 [143:136];
                          8'd11 : data_out_i <= CPLD_data_12 [135:128];
                          8'd12 : data_out_i <= CPLD_data_12 [127:120];
                          8'd13 : data_out_i <= CPLD_data_12 [119:112];
                          8'd14 : data_out_i <= CPLD_data_12 [111:104];
                          8'd15 : data_out_i <= CPLD_data_12 [103:96];
                          8'd16 : data_out_i <= CPLD_data_12 [95:88];
                          8'd17 : data_out_i <= CPLD_data_12 [87:80];
                          8'd18 : data_out_i <= CPLD_data_12 [79:72];
                          8'd19 : data_out_i <= CPLD_data_12 [71:64];
                          8'd20 : data_out_i <= CPLD_data_12 [63:56];
                          8'd21 : data_out_i <= CPLD_data_12 [55:48];
                          8'd22 : data_out_i <= CPLD_data_12 [47:40];
                          8'd23 : data_out_i <= CPLD_data_12 [39:32];
                          8'd24 : data_out_i <= CPLD_data_12 [31:24];
                          8'd25 : data_out_i <= CPLD_data_12 [23:16];
                          8'd25 : data_out_i <= CPLD_data_12 [15:8];
                          8'd27 : data_out_i <= CPLD_data_12 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 12) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0D;
                          8'd4  : data_out_i <= CPLD_data_13 [191:184];
                          8'd5  : data_out_i <= CPLD_data_13 [183:176];
                          8'd6  : data_out_i <= CPLD_data_13 [175:168];
                          8'd7  : data_out_i <= CPLD_data_13 [167:160];
                          8'd8  : data_out_i <= CPLD_data_13 [159:152];
                          8'd9  : data_out_i <= CPLD_data_13 [151:144];
                          8'd10  : data_out_i <= CPLD_data_13 [143:136];
                          8'd11 : data_out_i <= CPLD_data_13 [135:128];
                          8'd12 : data_out_i <= CPLD_data_13 [127:120];
                          8'd13 : data_out_i <= CPLD_data_13 [119:112];
                          8'd14 : data_out_i <= CPLD_data_13 [111:104];
                          8'd15 : data_out_i <= CPLD_data_13 [103:96];
                          8'd16 : data_out_i <= CPLD_data_13 [95:88];
                          8'd17 : data_out_i <= CPLD_data_13 [87:80];
                          8'd18 : data_out_i <= CPLD_data_13 [79:72];
                          8'd19 : data_out_i <= CPLD_data_13 [71:64];
                          8'd20 : data_out_i <= CPLD_data_13 [63:56];
                          8'd21 : data_out_i <= CPLD_data_13 [55:48];
                          8'd22 : data_out_i <= CPLD_data_13 [47:40];
                          8'd23 : data_out_i <= CPLD_data_13 [39:32];
                          8'd24 : data_out_i <= CPLD_data_13 [31:24];
                          8'd25 : data_out_i <= CPLD_data_13 [23:16];
                          8'd25 : data_out_i <= CPLD_data_13 [15:8];
                          8'd27 : data_out_i <= CPLD_data_13 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 13) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                  mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0E;
                          8'd4  : data_out_i <= CPLD_data_14 [191:184];
                          8'd5  : data_out_i <= CPLD_data_14 [183:176];
                          8'd6  : data_out_i <= CPLD_data_14 [175:168];
                          8'd7  : data_out_i <= CPLD_data_14 [167:160];
                          8'd8  : data_out_i <= CPLD_data_14 [159:152];
                          8'd9  : data_out_i <= CPLD_data_14 [151:144];
                          8'd10  : data_out_i <= CPLD_data_14 [143:136];
                          8'd11 : data_out_i <= CPLD_data_14 [135:128];
                          8'd12 : data_out_i <= CPLD_data_14 [127:120];
                          8'd13 : data_out_i <= CPLD_data_14 [119:112];
                          8'd14 : data_out_i <= CPLD_data_14 [111:104];
                          8'd15 : data_out_i <= CPLD_data_14 [103:96];
                          8'd16 : data_out_i <= CPLD_data_14 [95:88];
                          8'd17 : data_out_i <= CPLD_data_14 [87:80];
                          8'd18 : data_out_i <= CPLD_data_14 [79:72];
                          8'd19 : data_out_i <= CPLD_data_14 [71:64];
                          8'd20 : data_out_i <= CPLD_data_14 [63:56];
                          8'd21 : data_out_i <= CPLD_data_14 [55:48];
                          8'd22 : data_out_i <= CPLD_data_14 [47:40];
                          8'd23 : data_out_i <= CPLD_data_14 [39:32];
                          8'd24 : data_out_i <= CPLD_data_14 [31:24];
                          8'd25 : data_out_i <= CPLD_data_14 [23:16];
                          8'd25 : data_out_i <= CPLD_data_14 [15:8];
                          8'd27 : data_out_i <= CPLD_data_14 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                  if(mts_count == 14) begin
                 if(frame_count == 30) begin
                    frame_count <= 'd0;
                   mts_count <= mts_count + 1;
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h0F;
                          8'd4  : data_out_i <= CPLD_data_15 [191:184];
                          8'd5  : data_out_i <= CPLD_data_15 [183:176];
                          8'd6  : data_out_i <= CPLD_data_15 [175:168];
                          8'd7  : data_out_i <= CPLD_data_15 [167:160];
                          8'd8  : data_out_i <= CPLD_data_15 [159:152];
                          8'd9  : data_out_i <= CPLD_data_15 [151:144];
                          8'd10  : data_out_i <= CPLD_data_15 [143:136];
                          8'd11 : data_out_i <= CPLD_data_15 [135:128];
                          8'd12 : data_out_i <= CPLD_data_15 [127:120];
                          8'd13 : data_out_i <= CPLD_data_15 [119:112];
                          8'd14 : data_out_i <= CPLD_data_15 [111:104];
                          8'd15 : data_out_i <= CPLD_data_15 [103:96];
                          8'd16 : data_out_i <= CPLD_data_15 [95:88];
                          8'd17 : data_out_i <= CPLD_data_15 [87:80];
                          8'd18 : data_out_i <= CPLD_data_15 [79:72];
                          8'd19 : data_out_i <= CPLD_data_15 [71:64];
                          8'd20 : data_out_i <= CPLD_data_15 [63:56];
                          8'd21 : data_out_i <= CPLD_data_15 [55:48];
                          8'd22 : data_out_i <= CPLD_data_15 [47:40];
                          8'd23 : data_out_i <= CPLD_data_15 [39:32];
                          8'd24 : data_out_i <= CPLD_data_15 [31:24];
                          8'd25 : data_out_i <= CPLD_data_15 [23:16];
                          8'd25 : data_out_i <= CPLD_data_15 [15:8];
                          8'd27 : data_out_i <= CPLD_data_15 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          endcase
                         end
                  end 
                  
                 if(mts_count == 15) begin
                 if(frame_count == 55) begin
                    frame_count <= 'd0;
                    if(mts_count == 15) begin
                    mts_count <= 0;
                    end
                    end
                    else begin
                          frame_count <= frame_count + 1;
                          case (frame_count) 
                          8'd0  : data_out_i <= 8'h5A;
                          8'd1  : data_out_i <= 8'h5A;
                          8'd2  : data_out_i <= 8'h5A;
                          8'd3  : data_out_i <= 8'h10;
                          8'd4  : data_out_i <= CPLD_data_16 [191:184];
                          8'd5  : data_out_i <= CPLD_data_16 [183:176];
                          8'd6  : data_out_i <= CPLD_data_16 [175:168];
                          8'd7  : data_out_i <= CPLD_data_16 [167:160];
                          8'd8  : data_out_i <= CPLD_data_16 [159:152];
                          8'd9  : data_out_i <= CPLD_data_16 [151:144];
                          8'd10 : data_out_i <= CPLD_data_16 [143:136];
                          8'd11 : data_out_i <= CPLD_data_16 [135:128];
                          8'd12 : data_out_i <= CPLD_data_16 [127:120];
                          8'd13 : data_out_i <= CPLD_data_16 [119:112];
                          8'd14 : data_out_i <= CPLD_data_16 [111:104];
                          8'd15 : data_out_i <= CPLD_data_16 [103:96];
                          8'd16 : data_out_i <= CPLD_data_16 [95:88];
                          8'd17 : data_out_i <= CPLD_data_16 [87:80];
                          8'd18 : data_out_i <= CPLD_data_16 [79:72];
                          8'd19 : data_out_i <= CPLD_data_16 [71:64];
                          8'd20 : data_out_i <= CPLD_data_16 [63:56];
                          8'd21 : data_out_i <= CPLD_data_16 [55:48];
                          8'd22 : data_out_i <= CPLD_data_16 [47:40];
                          8'd23 : data_out_i <= CPLD_data_16 [39:32];
                          8'd24 : data_out_i <= CPLD_data_16 [31:24];
                          8'd25 : data_out_i <= CPLD_data_16 [23:16];
                          8'd25 : data_out_i <= CPLD_data_16 [15:8];
                          8'd27 : data_out_i <= CPLD_data_16 [7:0];
                          8'd28 : data_out_i <= 8'hA5;
                          8'd29 : data_out_i <= 8'hA5;
                          8'd30 : data_out_i <= 8'hA5;
                          8'd31 : data_out_i <= 8'hFF;
                          8'd32 : data_out_i <= 8'hFF;
                          8'd33 : data_out_i <= 8'hFF;
                          8'd34 : data_out_i <= 8'hFF;
                          8'd35 : data_out_i <= 8'hFF;
                          8'd36 : data_out_i <= 8'hFF;
                          8'd37 : data_out_i <= 8'hFF;
                          8'd38 : data_out_i <= 8'hFF;
                          8'd39 : data_out_i <= 8'hFF;
                          8'd40 : data_out_i <= 8'hFF;
                          8'd41 : data_out_i <= 8'hFF;
                          8'd42 : data_out_i <= 8'hFF;
                          8'd43 : data_out_i <= 8'hFF;
                          8'd44 : data_out_i <= 8'hFF;
                          8'd45 : data_out_i <= 8'hFF;
                          8'd46 : data_out_i <= 8'hFF;
                          8'd47 : data_out_i <= 8'hFF;
                          8'd48 : data_out_i <= 8'hFF;
                          8'd49 : data_out_i <= 8'hFF;
                          8'd50 : data_out_i <= 8'hFF;
                          8'd51 : data_out_i <= 8'hFF;
                          8'd52 : data_out_i <= 8'hFF;
                          8'd53 : data_out_i <= 8'hFF;
                          8'd54 : data_out_i <= 8'hFF;
                          endcase
                         end
                  end 
          
            end 
     end
 end




assign data_wr_buf = data_out_i;
assign OUT_EN = sync[1];
assign READ_N = sync[2]; 
assign WRITE_N = WRITE_N_i;
assign SEND_IM = send_im_i;

//================================================================================================================================================================
// DUAL RANK SYNCHRONIZER
//=================================================================================================================================================================

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
	     sync0_CLK_IN <= 0;
         sync1_CLK_IN <= 0;
	end
	else begin
		 sync0_CLK_IN <= CLK_IN;
         sync1_CLK_IN <= sync0_CLK_IN ;
        end
end

assign posedge_CLK_IN = sync0_CLK_IN & ~sync1_CLK_IN;


always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
	     sync0_SER_DATA_IN <= 0;
         sync1_SER_DATA_IN <= 0;
	end
	else begin
		 sync0_SER_DATA_IN <= SER_DATA_IN;
         sync1_SER_DATA_IN <= sync0_SER_DATA_IN ;
        end
end

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
	     sync0_DFRM_IN <= 0;
         sync1_DFRM_IN <= 0;
	end
	else begin
		 sync0_DFRM_IN <= DFRM_IN;
         sync1_DFRM_IN <= sync0_DFRM_IN ;
        end
end

assign posedge_DFRM_IN = sync0_DFRM_IN & ~sync1_DFRM_IN;

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
	     sync0_CLK_OUT <= 0;
         sync1_CLK_OUT <= 0;
	end
	else begin
		 sync0_CLK_OUT <= clk_5Mhz;
         sync1_CLK_OUT <= sync0_CLK_OUT ;
        end
end

assign posedge_CLK_OUT = sync0_CLK_OUT & ~sync1_CLK_OUT;

//================================================================================================================================================================
// CLOCK GENERATION
//=================================================================================================================================================================

 clk_wiz_0 DUT
  (
  // Clock out ports  
  .clk_out1(clk_120mhz),
  .clk_out2(CLK_OUT),
  .clk_out3(clk_200mhz),
  .clk_out4(clk_60mhz),
 // Clock in ports
  .clk_in1(CLK)
  );
  
//================================================================================================================================================================
// MAIN PROGRAM
//=================================================================================================================================================================

always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		 DATA_RECEVIED   <= 0;
		 DATA_RECEVIED_1 <= 0;
	end
	else begin
//         if (in_cnt == 'd2)  begin
//	          CPLD_data_1 <= DATA_RECEVIED;
//              CPLD_data_2 <= DATA_RECEVIED;
//	     end
         if ((in_cnt == 'd1) && (in_reg[207:192] == 16'h5A5A)) begin
              DATA_RECEVIED [191:0] <=   in_reg [191:0];
	          end
		 else 
	          DATA_RECEVIED <= DATA_RECEVIED;	           
	end	
end


always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		out_cnt   <= 0;
		out_reg   <= 'h0;
		frame_out <= 1'b1;
		d_out     <= 0;
	end
	else begin 
	         if (posedge_CLK_OUT == 1'b1) begin
		         if (out_cnt == 208) begin
			         out_cnt   <= 0;
		   	         frame_out <= 1'b0;	
		   	         out_reg <= 208'h01aabcdcbb0a01aabcdcbb0a01aabcdcbb0a01aabcdcbb0abb;
		             end
		         else begin
		                  d_out     <= out_reg[10'd207 - out_cnt];
			              out_cnt   <= out_cnt+1'b1;
			              frame_out <= 1'b1;
	                  end 
	          end	
	     end  
end

always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		in_reg       <= 0;
        DATA_RECVD_O <= 0;
		in_cnt       <= 0;
	end
	else begin
	         if (posedge_CLK_IN ==1'b1) begin 
                 if (sync1_DFRM_IN == 1'b1) begin 
		             in_cnt <= in_cnt + 1'b1;
		             in_reg [10'd207 - in_cnt] <= sync1_SER_DATA_IN;
		             end 
	             else begin
	                      if (sync1_DFRM_IN == 1'b0) begin
		                      DATA_RECVD_O <= in_reg;
		                      in_cnt       <= 0;
	                          end
	                  end
	           end
	     end   
end

assign DATA_2_SEND_I = DATA_RECVD_O;
assign ser_mod_data = (in_cnt == 'd1) ? in_reg[DATA_SIZE:1]:ser_mod_data;

endmodule


