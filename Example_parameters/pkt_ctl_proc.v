module pkt_ctl_proc
  #(PARITY = 1, FLAGS = 12, ADDR = 20)
   (
    input 			  clk, rst,
    input logic [ADDR-1:0] 	  pkt_addr,
    input logic [FLAGS-1:0] 	  pkt_flags,
    input logic                   pkt_parity,
    output logic [PARITY+FLAGS+ADDR-1:0] pkt_ctl_data);

   always_ff @(posedge clk) begin
      if (rst)
	pkt_ctl_data <= 0;
      else 
	pkt_ctl_data <= {pkt_parity,pkt_flags, pkt_addr};
   end
   
endmodule