
`include "pkt_iface.svh" 
`include "cpu_iface.svh"

module pkt_gen  
#(
  parameter type pkt_data_t = logic,
  parameter type pkt_ctl_t = logic,
  parameter type credit_cnt_t = logic,
  parameter PKT_PROC_ID = 0
  ) 
(   
   pkt_bus.tx pkt_tx,  
   cpu_iface.pkt_rx cpu_rx,
   input logic clk,rst
);
 
 // Adding interface functionality to packet data.  
 always_ff @(posedge clk)begin    
   pkt_tx.bus_tx_valid <= cpu_rx.pkt_valid;
   // Data 
   pkt_tx.bus_tx.data.flags <= cpu_rx.pkt_flags;
   pkt_tx.bus_tx.data.addr <= cpu_rx.proc_id;
   pkt_tx.bus_tx.data.payload <= cpu_rx.pkt_data; 
   pkt_tx.bus_tx.data.ecc <= pkt_tx.even_parity(cpu_rx.pkt_data);
   // CTL 
   pkt_tx.bus_tx.ctl.id <= PKT_PROC_ID;  
   pkt_tx.bus_tx.ctl.eop <=  cpu_rx.pkt_valid;    
 end   
 
 /* Enforce credit based communication between TX and RX.
 modularizes the packet processor such that it decouples it 
  from the packet bus requirements */
 credit_cnt_t ff_cnt, comb_cnt;
  
 always_comb comb_cnt 
   = pkt_tx.credit_cnt (pkt_tx.credit, cpu_rx.pkt_valid, ff_cnt);  
 
 always_ff @(posedge clk) begin
   if (rst)
     ff_cnt <= '0;
   else
     ff_cnt <= comb_cnt;
 end
   
endmodule
