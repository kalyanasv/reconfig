`ifndef _PKT_IFACE_SVH
 `define _PKT_IFACE_SVH
   
interface  pkt_bus (input pkt_clk);  
   parameter type pkt_bus_t = logic;  
   parameter type pkt_data_payload_t = logic;     
   parameter type pkt_data_t = logic;
   parameter type pkt_ctl_t = logic;   
   parameter type credit_cnt_t =logic;
   
   // Packet bus related functionality     
   // Parity checker on data.
   function automatic logic even_parity (pkt_data_payload_t data);
      return(^data);
   endfunction

   function automatic logic odd_parity (pkt_data_payload_t data);
      return(!(^data));
   endfunction
   
   // Packet bus credit counter.
   function automatic credit_cnt_t credit_cnt (logic credit, debit,
			                       credit_cnt_t curr_cnt);
      credit_cnt_t nxt_cnt;  
      nxt_cnt = curr_cnt;
      case ({credit, debit})
	2'b01: nxt_cnt--;
	2'b10: nxt_cnt++;
      endcase
      return nxt_cnt;      
      // Assertions can be added here or externally based on clk edge.
   endfunction   	

   // Data types used by interface ports.   
   pkt_bus_t  bus_tx, bus_rx;   
   pkt_data_t pkt_data;   
   pkt_ctl_t  pkt_ctl;
   logic      bus_tx_valid, bus_rx_valid;   
   logic      credit;

   // Added to generate a valid netlist.
   pkt_bus_t sub_sys_bus;
   
   // Packet TX -> RX flops.   
   always_ff @(posedge pkt_clk) begin
     bus_rx <= bus_tx;
     bus_rx_valid <= bus_tx_valid;
   end  
		     
   // Transmit interface.
   modport tx (output bus_tx, output bus_tx_valid, input credit, 
	       import even_parity, import credit_cnt);
   
   // Receive interface.
   modport rx (output credit, input bus_rx, input bus_rx_valid,
	       output sub_sys_bus, import even_parity );  
   
endinterface   
   
`endif 