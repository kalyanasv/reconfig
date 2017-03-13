module pkt_payload_parse
  # (PARITY = 1, FLAGS = 12, ADDR = 20, PAYLOAD = 32)
   (
    input 			 clk,rst,
    input logic [PARITY+FLAGS+ADDR-1:0] pkt_ctl_data,
    input logic [PAYLOAD-1:0] 	 pkt_payload_in,
    output logic [PAYLOAD-1:0] 	 pkt_payload_out);

 always_ff @(posedge clk) begin
   if (rst)
     pkt_payload_out <= '0;
   else begin
     if (|pkt_ctl_data) 
       pkt_payload_out <= pkt_payload_in;
     else
       pkt_payload_out <= '0;
   end    
  end   
   
endmodule