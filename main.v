
`timescale 1ns / 1ps


module cpld_mod0 #(parameter DATA_SIZE=194)
(
input CLK,
input RESET,

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
//output reset_P,
output DFRM_O_N

//output [191:0] MAIN_MTS

);

//================================================================================
// ILA INSTANTIATION
//=================================================================================

ila_0 ILA (
.clk(CLK_ILA),


.probe0(DATA_RECEVIED),
.probe1(DATA_RECEVIED_1),

.probe2(SER_DATA_IN),
.probe3(DFRM_IN),
.probe4(CLK_OUT),
.probe5(SER_DATA_O),
.probe6(DFRM_O),
.probe7(CLK_IN),
.probe8(in_reg)
);
//================================================================================
// LVDS
//=================================================================================
 IBUFDS#(
 .DIFF_TERM("FALSE"), //DifferentialTermination
 .IBUF_LOW_PWR("TRUE"), //Lowpower="TRUE",Highestperformance="FALSE"
 .IOSTANDARD("BLVDS") //SpecifytheinputI/Ostandard
 )IBUFDS_inst_CLK_IN(
 .O(CLK_IN), //Bufferoutput
 .I(CLK_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(CLK_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );
 
 IBUFDS#(
 .DIFF_TERM("FALSE"), //DifferentialTermination
 .IBUF_LOW_PWR("TRUE"), //Lowpower="TRUE",Highestperformance="FALSE"
 .IOSTANDARD("BLVDS") //SpecifytheinputI/Ostandard
 )IBUFDS_inst_SER_DATA_IN(
 .O(SER_DATA_IN), //Bufferoutput
 .I(SER_DATA_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(SER_DATA_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );
 
  IBUFDS#(
 .DIFF_TERM("FALSE"), //DifferentialTermination
 .IBUF_LOW_PWR("TRUE"), //Lowpower="TRUE",Highestperformance="FALSE"
 .IOSTANDARD("BLVDS") //SpecifytheinputI/Ostandard
 )IBUFDS_inst_DFRM_IN(
 .O(DFRM_IN), //Bufferoutput
 .I(DFRM_IN_P), //Diff_pbufferinput(connectdirectlytotop-levelport)
 .IB(DFRM_IN_N)//Diff_nbufferinput(connectdirectlytotop-levelport)
 );

 OBUFDS#(
 .IOSTANDARD("BLVDS"),//SpecifytheoutputI/Ostandard
 .SLEW("SLOW") //Specifytheoutputslewrate
 )OBUFDS_inst_CLK_OUT(
 .O(CLK_OUT_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(CLK_OUT_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(CLK_OUT) //Bufferinput
 );
 
  OBUFDS#(
 .IOSTANDARD("BLVDS"),//SpecifytheoutputI/Ostandard
 .SLEW("SLOW") //Specifytheoutputslewrate
 )OBUFDS_inst_SER_DATA_O(
 .O(SER_DATA_O_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(SER_DATA_O_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(SER_DATA_O) //Bufferinput
 );
 
  OBUFDS#(
 .IOSTANDARD("BLVDS"),//SpecifytheoutputI/Ostandard
 .SLEW("SLOW") //Specifytheoutputslewrate
 )OBUFDS_inst_DFRM_O(
 .O(DFRM_O_P), //Diff_poutput(connectdirectlytotop-levelport)
 .OB(DFRM_O_N), //Diff_noutput(connectdirectlytotop-levelport)
 .I(DFRM_O) //Bufferinput
 );
 
//================================================================================
// DECLARATIONS
//=================================================================================
wire CLK_IN;
wire DFRM_IN;
wire SER_DATA_IN;

wire SER_DATA_O;
wire CLK_OUT;
wire DFRM_O;

wire CLK_ILA;
//wire reset;
wire reset_cpld0;
wire  reset_cpld1;
//output DATA_RECEVIED_FINAL,
reg sample_done;

reg INTER;

reg frame_out;
reg [$clog2(DATA_SIZE+1)-1:0] out_cnt;
reg [$clog2(DATA_SIZE+1)-1:0] in_cnt;
reg [DATA_SIZE-1:0] out_reg;
reg [1:0] clk_div;

//shift in
reg  s_frame_in_reg;
reg  [DATA_SIZE:0] in_reg;
wire [DATA_SIZE-1:0] DATA_2_SEND_I = 8'b01011100;
reg  [DATA_SIZE-1:0] DATA_RECVD_O;

reg  [(DATA_SIZE-1):0] DATA_RECEVIED;
reg  [(DATA_SIZE-1):0] DATA_RECEVIED_1;

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
reg  [((DATA_SIZE)/8)-1:0] ch0_data=1'b0;
reg  [((DATA_SIZE)/8)-1:0] ch1_data=1'b0;
reg  [((DATA_SIZE)/8)-1:0] ch2_data=1'b1;
reg  [((DATA_SIZE)/8)-1:0] ch3_data=1'b0;
reg  [((DATA_SIZE)/8)-1:0] ch4_data=1'b0;
reg  [((DATA_SIZE)/8)-1:0] ch5_data=1'b1;
reg  [((DATA_SIZE)/8)-1:0] ch6_data=1'b1;
reg  [((DATA_SIZE)/8)-1:0] ch7_data=1'b0;
reg  [2:0]frame_count; 

wire  all_ch_sampling_done;


//================================================================================
// OUTPUT ASSIGNMENT
//=================================================================================

////assign CLK_OUT = clk_div[1];
assign DFRM_O = frame_out;
assign SER_DATA_O = d_out;//out_reg[0];

//assign DATA_RECEVIED_FINAL = DATA_RECEVIED;

//================================================================================
// DUAL RANK SYNCHRONIZER
//=================================================================================

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

assign posedge_CLK_IN = CLK_IN & ~sync0_CLK_IN;


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

assign posedge_DFRM_IN = DFRM_IN & ~sync0_DFRM_IN;

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
	     sync0_CLK_OUT <= 0;
         sync1_CLK_OUT <= 0;
	end
	else begin
		 sync0_CLK_OUT <= CLK_OUT;
         sync1_CLK_OUT <= sync0_CLK_OUT ;
        end
end

assign posedge_CLK_OUT = CLK_OUT & ~sync0_CLK_OUT;

//================================================================================
// CLOCK GENERATION
//=================================================================================

always @(posedge CLK or negedge RESET)
begin
	if(~RESET) begin
		clk_div <= 1'b0;
	end
	else begin
		clk_div <= clk_div + 1;
        end
end

clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(CLK_ILA),     // output clk_out1
    .clk_out2(CLK_OUT),     // output clk_out2
    // Status and control signals
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(CLK));      // input clk_in1

//================================================================================
// EDGE DETECTION
//=================================================================================

//================================================================================
// MAIN PROGRAM
//=================================================================================
/*
always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		DATA_RECEVIED <= 0;
		DATA_RECEVIED_1 <= 0;
	end
	else begin
	     case (counter) 
	     2'd0: begin
	           DATA_RECEVIED <= (in_cnt == 1'b1) ? in_reg : DATA_RECEVIED;
	           end
	     2'd1: begin
	           DATA_RECEVIED_1 <= (in_cnt == 1'b1) ? in_reg : DATA_RECEVIED_1;
	           end
	     /*default : begin
	               DATA_RECEVIED <= DATA_RECEVIED;
	               DATA_RECEVIED_1 <= DATA_RECEVIED_1;
	               end 
	      endcase          
	               
	end	
end
*/

always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		DATA_RECEVIED <= 0;
		DATA_RECEVIED_1 <= 0;
	end
	else begin
	    /*
	     if ((in_cnt == 1'b1) && (in_reg[193:194] == 2'b01)) 
	         DATA_RECEVIED <= in_reg;
		 else 
	         DATA_RECEVIED <= DATA_RECEVIED;
	         
		if ((in_cnt == 1'b1) && (in_reg[193:194] == 2'b10)) 
	         DATA_RECEVIED_1 <= DATA_RECEVIED;
		else 
	         DATA_RECEVIED_1 <= DATA_RECEVIED;	 
	         */
	      
	      if (in_cnt == 1'b1) begin
	         case (in_reg[193:194])
	         2'd1 : DATA_RECEVIED   <= in_reg;
	         2'd2 : DATA_RECEVIED_1 <= in_reg;
	         default : begin
	                   DATA_RECEVIED   <= DATA_RECEVIED;
	                   DATA_RECEVIED_1 <= DATA_RECEVIED_1;
	                   end
	         endcase
	         end 
	      else
	         begin
	              DATA_RECEVIED   <= DATA_RECEVIED;
	              DATA_RECEVIED_1 <= DATA_RECEVIED_1;
	         end    
	                               
	end	
end


always@(posedge CLK or negedge RESET) begin
    if(~RESET) begin
      INTER <= 0;
      end  
      else if(in_cnt == 2)
              INTER <= 1;
            else
              INTER <= 0; 
end
/*
always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		DATA_RECEVIED <= 0;
		DATA_RECEVIED_1 <= 0;
	end 
	else begin
	     if (in_cnt == 1'b1) begin
	     case (in_reg[25:24])
	     2'b01 : begin
                 DATA_RECEVIED <= in_reg;
                 end
         2'b10 : begin
                 DATA_RECEVIED_1 <=  in_reg;
                 end  
         default :  begin 
                    DATA_RECEVIED <= DATA_RECEVIED;
                    DATA_RECEVIED_1 <= DATA_RECEVIED_1;
                    end       
         endcase 
         end       
    end     
  end       
/*
always @(posedge sync1_DFRM_IN or negedge RESET) begin
	if(~RESET) begin
	    counter <= 0;
	    end
	 else begin if (counter == 2)
	                counter <= 0;
	            else 
	                counter <= counter + 1;
	      end                  
end

*/



always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		out_cnt   <= 0;
		out_reg   <= 8'd0;
		frame_out <= 1'b1;
		d_out     <= 0;
	    end
	else if(posedge_CLK_OUT == 1'b1) begin
		    if(out_cnt == DATA_SIZE) begin
			   out_cnt   <= 0;
			   frame_out <= 1'b0;	
		       end
		    else begin
		         if (frame_out == 1'b0) begin 
		           	out_reg   <= ser_mod_data;
		            //out_reg <= DATA_2_SEND_I;
			        frame_out <= 1'b1;
		            end 
        	     else begin
			          d_out     <= out_reg[out_cnt];
			          out_cnt   <= out_cnt+1'b1;
			          frame_out <= 1'b1;
	                  end
	             end     
	   end	
end

/*

always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		DATA_RECEVIED <= 0;
	end
	else if(in_cnt == 1) begin
	     DATA_RECEVIED <= in_reg;
	end	
end

*/

//assign CPLD_data_2 = DATA_RECEVIED;
//assign CPLD_data_1 = DATA_RECEVIED_1;


always @(posedge CLK or negedge RESET) begin
	if(~RESET) begin
		in_reg       <= 0;
        DATA_RECVD_O <= 0;
		in_cnt       <= 0;
	end
	else if (posedge_CLK_IN ==1'b1) begin 
             if (sync1_DFRM_IN == 1'b1) begin 
		          in_cnt <= in_cnt+1'b1;
		          in_reg <= {sync1_SER_DATA_IN,in_reg[DATA_SIZE:1]};
		      end 
	          else if(sync1_DFRM_IN == 1'b0) begin
		              DATA_RECVD_O <= in_reg[DATA_SIZE:1];
		              in_cnt <= 0;
	                end
	     end
end

assign DATA_2_SEND_I = DATA_RECVD_O;
endmodule

