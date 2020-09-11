//import uvm_pkg::*;
`timescale 1ps/1ps

module ddr4_db_delay_model #(
			    parameter MC_DQ_WIDTH = 16, // Memory DQ bus width
			    parameter MC_DQS_BITS = 4, // Number of DQS bits
			    parameter NUM_PHYSICAL_PARTS = 4, // Number of SDRAMs in a Single Rank
		        parameter MEM_PART_WIDTH = "x4" ,// Single Device width
			    parameter tCK = 1
			    )
  (
   input 		     ddr4_reset_n,
   inout [MC_DQ_WIDTH-1:0]   ddr4_db_dq,
   inout [MC_DQS_BITS-1:0]   ddr4_db_dqs_t,
   inout [MC_DQS_BITS-1:0]   ddr4_db_dqs_c,
   inout [MC_DQ_WIDTH-1:0]   ddr4_dimm_dq,
   inout [MC_DQS_BITS-1:0]   ddr4_dimm_dqs_t,
   inout [MC_DQS_BITS-1:0]   ddr4_dimm_dqs_c
   );


  wire     [NUM_PHYSICAL_PARTS-1:0] DB_rd_drive ; // used for control signal of bi_delay_ddr4
  wire     [NUM_PHYSICAL_PARTS-1:0]  DB_wr_drive ; // used for control signal of bi_delay_ddr4

  wire     [NUM_PHYSICAL_PARTS-1:0] wrlvl_rd_drive ; // used for comp_dq_rd_drive
  wire     [NUM_PHYSICAL_PARTS-1:0] DB_dq_rd_drive ; // used for control signal of dq bi_delay_ddr4
  wire     [NUM_PHYSICAL_PARTS-1:0] DB_dq_wr_drive ; // used for control signal of dq bi_delay_ddr4





  genvar 		     mem_part; // used in for-loop (shows which is the current mem part)
  genvar 		     dqs_y; // used in for-loop (shows which is the current dqs bit)
  localparam DQ_PER_DQS = 4 ;//only when MEM_PART_WIDTH=="x4"
  int DB2SDRAMdelays_int[NUM_PHYSICAL_PARTS]; // each word store the delay for a single device



  
  //VP-------------------- To generate DB to SDRAM Delays ----------------------------------------------------- 
 


 // Mem part  instances and adding of DB delays
  generate

	    // add DB to SDRAM delays on dq and dqs 
	    for(dqs_y=0; dqs_y<MC_DQS_BITS; dqs_y=dqs_y+1)
	      begin: add_delay_to_dq_dqs_dm

		// Add DB to SDRAM delays delays to DQ (each bit dqs is used to drive DQ_PER_DQS bits of dq)
		for(genvar dq_per_dqs_k=0; dq_per_dqs_k<DQ_PER_DQS; dq_per_dqs_k=dq_per_dqs_k+1)
		  begin: add_DB2SDRAM_delay_for_each_dq_bit

                  //------------------- DB BFM MIG ----------------------------------------------------

		    // bi_delays_ddr4 module add delay only to a single bit.
		    bi_delay_ddr4  #(.DELAY_WIDTH (32))
		    bit_delay_dq_DB2SDRAM (
     					    //.uni_a       (), 
     					    .uni_a       (ddr4_db_dq[dqs_y*DQ_PER_DQS+dq_per_dqs_k]), 
     	     				    .uni_b       (ddr4_dimm_dq[dqs_y*DQ_PER_DQS+dq_per_dqs_k]),
  					    .reset       (~ddr4_reset_n),
					    .write_drive (DB_dq_wr_drive[dqs_y]),
					    .read_drive  (DB_dq_rd_drive[dqs_y]),
					    .delay       (tCK)
					    );



                   // add DB delays to dqs_t
	   	bi_delay_ddr4  #(.DELAY_WIDTH (32))
		bit_delay_dqs_t_DB2SDRAM (
     					   .uni_a       (ddr4_db_dqs_t[dqs_y]),
     	     				   .uni_b       (ddr4_dimm_dqs_t[dqs_y]),
  					   .reset       (~ddr4_reset_n),
					   .write_drive (DB_wr_drive[dqs_y]),
					   .read_drive  (DB_rd_drive[dqs_y]),
					   .delay       (tCK)
					   );
		
		// add DB delays to dqs_c
		bi_delay_ddr4  #(.DELAY_WIDTH (32))
		bit_delay_dqs_c_DB2SDRAM (
     					   .uni_a       (ddr4_db_dqs_c[dqs_y]),
     	     				   .uni_b       (ddr4_dimm_dqs_c[dqs_y]),
  					   .reset       (~ddr4_reset_n),
					   .write_drive (DB_wr_drive[dqs_y]),
					   .read_drive  (DB_rd_drive[dqs_y]),
					   .delay       (tCK)
					   );

    
        end // add_delay_to_dq_dqs_dm
      end// add_db_to_sdram_delays

endgenerate


// direction detect module (read,write drive signals are used for control signals to bi_delay_ddr4
  // The number of dir_detect instances are NUM_PHYSICAL_PARTS*MC_DQS_BITS.
  generate
	
	for(mem_part=0; mem_part<NUM_PHYSICAL_PARTS; mem_part=mem_part+1)
	  begin: rd_wr_drive_signals_for_each_mem_part
		dir_detect U_dir_detect (
					    .MC_DQS_t  (ddr4_db_dqs_t[mem_part]),
        				.MC_DQS_c  (ddr4_db_dqs_c[mem_part]),
	         			.Mem_DQS_t (ddr4_dimm_dqs_t[mem_part]),
		         		.Mem_DQS_c (ddr4_dimm_dqs_c[mem_part]),
			        	.rd_drive  (DB_rd_drive[mem_part]),
				        .wr_drive  (DB_wr_drive[mem_part])
					    );
		
	        assign DB_dq_rd_drive[mem_part] =  DB_rd_drive[mem_part];
	        assign DB_dq_wr_drive[mem_part] =  DB_wr_drive[mem_part];
	     end
  endgenerate

endmodule // ddr4_db_delay_model
