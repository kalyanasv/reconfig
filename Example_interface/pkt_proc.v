
`include "pkt_iface.svh" 

module pkt_proc
 #(parameter type pkt_bus_t = logic) 
(   
   pkt_bus.rx pkt_rx,
   output pkt_bus_t sub_sys_bus,
   input logic clk,rst,
   output logic err 
);
 /* Interface credit return I/O flops can be added externally or 
 preferably bundled with the interface definition with hierarchical 
  interfaces.*/  
 always_ff @(posedge clk) begin
    if (rst)
      pkt_rx.credit <= 0;
   else 
      pkt_rx.credit <= pkt_rx.bus_rx_valid;
 end
      
 // Report bus errors.
 always_comb err = pkt_rx.even_parity(pkt_rx.bus_rx.data.payload);

 /* Added for netlist generation.
    Ideally, packet link, transport layer processing can be hierarchically
    instantiated here */  
 always_ff @(posedge clk) sub_sys_bus <= pkt_rx.bus_rx;
   
endmodule
