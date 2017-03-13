module pkt_ctl_proc_vclass
  #(parameter type pkt_ctl_t = logic)
   (
    input logic	      clk, rst,
    input logic       pkt_valid,
    pkt_ctl_t         pkt_ctl, 
    output pkt_ctl_t  pkt_ctl_data);

   always_ff @(posedge clk) begin
      if (rst)
	pkt_ctl_data <= 0;
      else
	if (pkt_valid)
	  pkt_ctl_data <= pkt_ctl;
   end
   
endmodule