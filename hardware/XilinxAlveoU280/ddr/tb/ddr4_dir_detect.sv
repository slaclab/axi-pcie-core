`timescale 1ps/1ps

module dir_detect(
 input MC_DQS_t,
 input MC_DQS_c,

 input Mem_DQS_t,
 input Mem_DQS_c,
 
 output wr_drive,
 output rd_drive );

 logic is_wr;
 logic is_rd;
 logic idle_state;

 always @(*) 
 begin
	if((MC_DQS_t === MC_DQS_c)  && (Mem_DQS_t === Mem_DQS_c))
	begin
		// idle state No one driving the DQ bus
		is_wr = 1'b0;
		is_rd = 1'b0;
		idle_state = 1'b1;
	end
	else if ((idle_state == 1'b1) && (MC_DQS_t !== MC_DQS_c) && (Mem_DQS_t === Mem_DQS_c))
	begin
		// DQS is driven from MC side => write_path.
		is_wr = 1'b1;
		is_rd = 1'b0;
		idle_state = 1'b0;
	end
	else if ((idle_state == 1'b1) && (MC_DQS_t === MC_DQS_c) && (Mem_DQS_t !== Mem_DQS_c))
	begin
		// DQS is driven from Mem side => read_path.
		is_wr = 1'b0;
		is_rd = 1'b1;
		idle_state = 1'b0;
	end
 end

 assign wr_drive = is_wr;
 assign rd_drive = is_rd;
endmodule
