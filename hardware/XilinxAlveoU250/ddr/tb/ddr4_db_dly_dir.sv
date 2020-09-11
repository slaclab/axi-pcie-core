//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module ddr_dly_dir_detect #(
  CA_MIRROR         = "OFF" ,
  CS_NUM            =2,
  RDIMM_SLOTS       =1,
  MC_ABITS          =1
)
(
  input                ddr_ck,
  input [MC_ABITS-1:0] ddr_a,
  input [CS_NUM-1:0]ddr_cs_n,
  input [1:0]          ddr_bg,   
  input [1:0]          ddr_ba,
  input                initDone,
  output reg              db_dly_dir 
) ;

  
   
reg [2:0]   ddr_MRS_NUM_local;
reg [17:0]  ddr_a_local;


//vpradee:DDR4 Checker Updates for RDIMM(DT 829026)


 bit rank_Odd_Check;

 always@(ddr_ck)
  begin
   if((CS_NUM > 2)  )
     rank_Odd_Check= ((!ddr_cs_n[1]) || (!ddr_cs_n[3]));
   else if((RDIMM_SLOTS == 1) && (CS_NUM==2))
      rank_Odd_Check= !ddr_cs_n[1] ;
   else  
      rank_Odd_Check= 0 ;
  end


  always@(ddr_a[16:14]) begin

    if((CA_MIRROR=="ON")  && (rank_Odd_Check))  
    begin //{1
	  if(ddr_bg[0] == 1'b0)
          //*******Side A ********************
          begin //{2
           ddr_MRS_NUM_local[0]= ddr_ba[1];
           ddr_MRS_NUM_local[1]= ddr_ba[0];
           ddr_MRS_NUM_local[2]= ddr_bg[1];
	         ddr_a_local[0]  = ddr_a[0];
	         ddr_a_local[1]  = ddr_a[1];
	         ddr_a_local[2]  = ddr_a[2];
	         ddr_a_local[3]  = ddr_a[4];
	         ddr_a_local[4]  = ddr_a[3];
	         ddr_a_local[5]  = ddr_a[6];
	         ddr_a_local[6]  = ddr_a[5];
	         ddr_a_local[7]  = ddr_a[8];
	         ddr_a_local[8]  = ddr_a[7];
	         ddr_a_local[9]  = ddr_a[9];
	         ddr_a_local[10] = ddr_a[10];
	         ddr_a_local[11] = ddr_a[13];
	         ddr_a_local[12] = ddr_a[12];
	         ddr_a_local[13] = ddr_a[11];
	         ddr_a_local[14] = ddr_a[14];
	         ddr_a_local[15] = ddr_a[15];
	         ddr_a_local[16] = ddr_a[16];
	         ddr_a_local[17] = ddr_a[17];
	      end //} 2
      else   
          //*****Side B*************************
         begin //{3
             ddr_MRS_NUM_local[0] = ~ddr_ba[1];
             ddr_MRS_NUM_local[1] = ~ddr_ba[0];
             ddr_MRS_NUM_local[2] = ~ddr_bg[1];
	           ddr_a_local[0]  = ddr_a[0];
	           ddr_a_local[1]  = ddr_a[1];
	           ddr_a_local[2]  = ddr_a[2];
	           ddr_a_local[3]  = ~ddr_a[4];
	           ddr_a_local[4]  = ~ddr_a[3];
	           ddr_a_local[5]  = ~ddr_a[6];
	           ddr_a_local[6]  = ~ddr_a[5];
	           ddr_a_local[7]  = ~ddr_a[8];
	           ddr_a_local[8]  = ~ddr_a[7];
	           ddr_a_local[9]  = ~ddr_a[9];
	           ddr_a_local[10] = ddr_a[10];
	           ddr_a_local[11] = ~ddr_a[13];
	           ddr_a_local[12] = ddr_a[12];
	           ddr_a_local[13] = ~ddr_a[11];
	           ddr_a_local[14] = ddr_a[14];
	           ddr_a_local[15] = ddr_a[15];
	           ddr_a_local[16] = ddr_a[16];
	           ddr_a_local[17] = ~ddr_a[17];
	  end //}3
	  end // }1 CA_MIRROR
     else
     begin //{4
        //################## Mirror Address OFF  #######################
        if(ddr_bg[1] == 1'b0)
          begin //{5
           //*******Side A ********************
            ddr_a_local   = ddr_a ;
            ddr_MRS_NUM_local  = {ddr_bg[0],ddr_ba} ;
	    end //}5
	    else   
          begin //{6
             //*****Side B*************************
              ddr_MRS_NUM_local[0] = ~ddr_ba[0];
              ddr_MRS_NUM_local[1] = ~ddr_ba[1];
              ddr_MRS_NUM_local[2] = ~ddr_bg[0];
	            ddr_a_local[0]  = ddr_a[0];
	            ddr_a_local[1]  = ddr_a[1];
	            ddr_a_local[2]  = ddr_a[2];
	            ddr_a_local[3]  = ~ddr_a[3];
	            ddr_a_local[4]  = ~ddr_a[4];
	            ddr_a_local[5]  = ~ddr_a[5];
	            ddr_a_local[6]  = ~ddr_a[6];
	            ddr_a_local[7]  = ~ddr_a[7];
	            ddr_a_local[8]  = ~ddr_a[8];
	            ddr_a_local[9]  = ~ddr_a[9];
	            ddr_a_local[10] = ddr_a[10];
	            ddr_a_local[11] = ~ddr_a[11];
	            ddr_a_local[12] = ddr_a[12];
	            ddr_a_local[13] = ~ddr_a[13];
	            ddr_a_local[14] = ddr_a[14];
	            ddr_a_local[15] = ddr_a[15];
	            ddr_a_local[16] = ddr_a[16];
	            ddr_a_local[17] = ~ddr_a[17];
	     end //}6
      end   //}1
  end 


// Below thread always strats when there is change in command
  always@(ddr_ck) begin
    // Check if Command is for MRS2
    if((initDone ==1) && (ddr_a[16:14] == 3'b000) && (ddr_MRS_NUM_local == 3'b001)) begin
      // Drive the write leveling enable signal to dir_en
      //`uvm_info("always_block",$psprintf("Received MRS1 command for Write Leveling."), UVM_LOW);
    //  dir_en = ddr_a_local[7];
      db_dly_dir      = ddr_a_local[7];
   end
  end
 endmodule  
