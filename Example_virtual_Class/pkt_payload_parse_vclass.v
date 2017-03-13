module pkt_payload_parse_vclass
  // Parametrized user defined data types.  
  # (parameter type pkt_data_t = logic,
     parameter type pkt_ctl_t = logic,
     parameter type pkt_data_payload_t = logic
     )
   (
    input logic	clk,rst,
    input logic pkt_valid,
    input 	pkt_ctl_t pkt_ctl_data,
    input 	pkt_data_t pkt_data,
    output logic pkt_payload_valid,
    output 	 pkt_data_payload_t pkt_payload_out);

 // Usage of pre-defined data types.  
 always_ff @(posedge clk) begin
   if (rst) begin
     pkt_payload_out <= '0;
     pkt_payload_valid <= 0;
   end
   /* The struct members are defined 
    at higher level of hierarchy */        
   else if (pkt_valid && pkt_ctl_data.eop 
	 && (|pkt_data.flags)) begin
       pkt_payload_out <= pkt_data.payload;
       pkt_payload_valid <= 1;
   end    
  end      
endmodule