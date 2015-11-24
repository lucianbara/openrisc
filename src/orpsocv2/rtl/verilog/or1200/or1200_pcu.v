//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Performance counter unit                           ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//////////////////////////////////////////////////////////////////////


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_pcu(
        clk, rst,
        lsu_load_event_i,
        lsu_store_event_i,
        if_event_i,

        dcache_miss_i,
        icache_miss_i,

        if_stall_i,
        lsu_stall_i,
        lsu_unstall_i,

        branch_stall_event_i,
        itlbmiss_i,
        dtlbmiss_i,

        spr_write,
        spr_adr_i,
        spr_dat_i,
        spr_dat_o,

        pcu_cnt

    );

/*Inputs*/
input clk;
input rst;


input lsu_load_event_i;
input lsu_store_event_i;
input if_event_i;

input dcache_miss_i;
input icache_miss_i;

input if_stall_i;
input lsu_stall_i;
input lsu_unstall_i;

input branch_stall_event_i;
input itlbmiss_i;
input dtlbmiss_i;


/*Outputs*/
output [31:0] pcu_cnt;

/*SPR IN out*/
input           spr_write;  // SPR Read/Write
input   [31:0]  spr_adr_i;   // SPR Address
input   [31:0]  spr_dat_i;  // SPR Write Data
output  [31:0]  spr_dat_o;  // SPR Read Data







/*Internal counter regs*/
reg[31:0] pccr[7:0];




reg[31:0] pcu_cnt;

/*Internal mode regs*/
reg[8*32-1:0] pcmr;


/*Internal condition wires*/
wire[7:0] pccr_cdn;

reg[31:0] spr_dat_o;


reg lsu_stall_old;
reg lsu_stall_old_old;
reg branch_stall_event_old;
reg if_stall_old;
reg if_event_old;
reg itlbmiss_old;
reg dtlbmiss_old;


reg lsu_load_event_old;
reg lsu_store_event_old;

/*Variables*/
genvar          i;

/*Condition asigns*/

wire if_event_cdn;
assign if_event_cdn = if_event_i & !if_event_old;


wire lsu_stall_cdn;
assign lsu_stall_cdn  = lsu_unstall_i & lsu_stall_old & lsu_stall_old_old;


wire branch_stall_event_cdn;
assign branch_stall_event_cdn  = !branch_stall_event_i & branch_stall_event_old;


wire itlbmiss_cdn;
assign itlbmiss_cdn  = itlbmiss_i & itlbmiss_old;

wire dtlbmiss_cdn;
assign dtlbmiss_cdn  = dtlbmiss_i & dtlbmiss_old;

wire if_stall_cdn;
assign if_stall_cdn = if_stall_i & !if_stall_old;

wire lsu_store_event_cdn;
assign lsu_store_event_cdn = lsu_store_event_i & !lsu_store_event_old;

wire lsu_load_event_cdn;
assign lsu_load_event_cdn = lsu_load_event_i & !lsu_load_event_old;


//Store old values
always @(posedge clk or `OR1200_RST_EVENT rst) begin
    if (rst == `OR1200_RST_VALUE)
        begin
            lsu_stall_old          <= 1'b0;
            lsu_stall_old_old      <= 1'b0;
            branch_stall_event_old <= 1'b0;
            if_stall_old           <= 1'b0;
            if_event_old           <= 1'b0;
            itlbmiss_old           <= 1'b0;
            dtlbmiss_old           <= 1'b0;             
            lsu_store_event_old    <= 1'b0;   
            lsu_load_event_old     <= 1'b0;   
        end
    else
        begin
            lsu_stall_old_old      <= lsu_stall_old;
            lsu_stall_old          <= lsu_stall_i;
            branch_stall_event_old <= branch_stall_event_i;
            if_stall_old           <= if_stall_i;
            if_event_old           <= if_event_i;
            itlbmiss_old           <= itlbmiss_i;
            dtlbmiss_old           <= dtlbmiss_i;  
            lsu_store_event_old    <= lsu_store_event_i;
            lsu_load_event_old     <= lsu_load_event_i; 
        end
end


//Counter conditions
   generate
      for (i=0; i<8; i = i+1) begin: pccr_cdn_gen 
        assign pccr_cdn[i] = (pcmr[i*32+4]  ? lsu_load_event_cdn:0)    |
                             (pcmr[i*32+5]  ? lsu_store_event_cdn:0)   |
                             (pcmr[i*32+6]  ? if_event_cdn:0)          |
                             (pcmr[i*32+7]  ? dcache_miss_i:0)         |
                             (pcmr[i*32+8]  ? icache_miss_i:0)         |
                             (pcmr[i*32+9]  ? if_stall_cdn:0)          |
                             (pcmr[i*32+10] ? lsu_stall_cdn:0)         |
                             (pcmr[i*32+11] ? branch_stall_event_cdn:0)|
                             (pcmr[i*32+12] ? dtlbmiss_cdn:0)          |
                             (pcmr[i*32+13] ? itlbmiss_cdn:0);
        end
    endgenerate



//Counter logic
  generate
   for(i=0; i<8; i = i + 1) begin : pccr_gen
      always @(posedge clk or `OR1200_RST_EVENT rst) begin
          if (rst == `OR1200_RST_VALUE)
              pccr[i]     = 32'b0;
          else
              begin
                  if(pcmr[i*32]&(pcmr[i*32+2] | pcmr[i*32+3]))
                    begin
                            if(pccr_cdn[i])
                                pccr[i] = pccr[i] + 32'b1;
                    end
                  else
                      if(!pcmr[i*32])
                          pccr[i]     = 32'b0;
              end
          end
     end
  endgenerate




  /*Time count logic*/
  always @(posedge clk or `OR1200_RST_EVENT rst) begin
    if (rst == `OR1200_RST_VALUE)
        pcu_cnt     = 32'b0;
    else
        pcu_cnt = pcu_cnt + 32'b1;
    end


/*Read write logic*/

integer idx;


 always @(posedge clk or `OR1200_RST_EVENT rst) begin
    if (rst == `OR1200_RST_VALUE)
      begin
        for(idx = 0; idx < 8; idx  = idx + 1)
        begin
            pcmr[idx*32+:32] = 32'b1;
        end
      end
    else
      if(spr_adr_i[`OR1200_SPR_GROUP_BITS] == `OR1200_SPR_GROUP_PCU)
      begin
        if(spr_write)
          begin
            case(spr_adr_i[`OR1200_SPR_OFS_BITS])
            `OR1200_PCMR0: pcmr[31:0]  = spr_dat_i;
            `OR1200_PCMR1: pcmr[63:32] = spr_dat_i;
            `OR1200_PCMR2: pcmr[95:64] = spr_dat_i;
            `OR1200_PCMR3: pcmr[127:96] = spr_dat_i;
            `OR1200_PCMR4: pcmr[159:128] = spr_dat_i;
            `OR1200_PCMR5: pcmr[191:160] = spr_dat_i;
            `OR1200_PCMR6: pcmr[223:192] = spr_dat_i;
            `OR1200_PCMR7: pcmr[255:224] = spr_dat_i;
           endcase
          end
       else
        begin
          case(spr_adr_i[`OR1200_SPR_OFS_BITS])
            `OR1200_PCMR0: spr_dat_o = pcmr[31:0];
            `OR1200_PCMR1: spr_dat_o = pcmr[63:32];
            `OR1200_PCMR2: spr_dat_o = pcmr[95:64];
            `OR1200_PCMR3: spr_dat_o = pcmr[127:96];
            `OR1200_PCMR4: spr_dat_o = pcmr[159:128];
            `OR1200_PCMR5: spr_dat_o = pcmr[191:160];
            `OR1200_PCMR6: spr_dat_o = pcmr[223:192];
            `OR1200_PCMR7: spr_dat_o = pcmr[255:224];
            `OR1200_PCCR0: spr_dat_o = pccr[0];
            `OR1200_PCCR1: spr_dat_o = pccr[1];
            `OR1200_PCCR2: spr_dat_o = pccr[2];
            `OR1200_PCCR3: spr_dat_o = pccr[3];
            `OR1200_PCCR4: spr_dat_o = pccr[4];
            `OR1200_PCCR5: spr_dat_o = pccr[5];
            `OR1200_PCCR6: spr_dat_o = pccr[6];
            `OR1200_PCCR7: spr_dat_o = pccr[7];
            default:      spr_dat_o = 0;
          endcase
        end
      end
      else
        spr_dat_o = 0;
  end         



endmodule