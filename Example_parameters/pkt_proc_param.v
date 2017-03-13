// Exmple on parameter usage.
module pkt_proc_param
  // Parameters for total packet size = 64 bits.
  // PACKET[SIZE] = PACKET[PARITY + FLAGS + ADDR + PAYLOAD]
  // Note: The usage of keyword parameter is not required since SV 2009 
  // and Synopsys HDL Compiler.
  #(SIZE = 64, PARITY = 1, FLAGS = 11, ADDR = 20, PAYLOAD = 32)
  (  
    input logic 	       clk,rst,        // Global inputs
    input logic  [SIZE-1:0]    pkt_data_in,    // Packet input data 
    output logic [PAYLOAD-1:0] pkt_payload_out);  // Packet payload data output
  
   // Define parametrized module level signals. 
   logic [PAYLOAD-1:0] pkt_payload_in;
   logic [FLAGS-1:0]   pkt_flags;   
   logic [PARITY-1:0]  pkt_parity;   
   logic [ADDR-1:0]    pkt_addr;   
   logic [PARITY+FLAGS+ADDR-1:0] pkt_ctl_data;
   
   // Bit-offsets are pre-determined but parameterized.
   always_ff @(posedge clk)  pkt_payload_in <= pkt_data_in[PAYLOAD-1:0];
   always_ff @(posedge clk)  pkt_addr <= pkt_data_in[PAYLOAD+ADDR-1:PAYLOAD];
   always_ff @(posedge clk)  pkt_flags <= pkt_data_in[PAYLOAD+ADDR+FLAGS-1:PAYLOAD+ADDR];
   always_ff @(posedge clk)  pkt_parity <= pkt_data_in[PAYLOAD+ADDR+FLAGS+PARITY-1:PAYLOAD+ADDR+FLAGS];
   
   // Packet payload parser uses only related parameters such as PAYLOAD.
   pkt_payload_parse   
    #(.PARITY(PARITY),.FLAGS(FLAGS),.ADDR(ADDR),.PAYLOAD(PAYLOAD))
   // Auto assignment as names across modules match with I/O.
   parse_payload (.*);
   
   // Packet control parser uses related parameters such as FLAGS and ADDR.
   pkt_ctl_proc
     // Auto assignment as names across modules match with I/O.
     #(.PARITY(PARITY),.FLAGS(FLAGS),.ADDR(ADDR))
   parse_ctl (.*);  
   
endmodule

  
// Local Variables:
// verilog-typedef-regexp: "_t$"
// verilog-auto-template-warn-unused: t
// verilog-library-flags:("-f project/dvconf/vc/input_autos.vc")
// End:

// vim: tw=78 sw=3 ts=8 sts=4 expandtab smarttab
