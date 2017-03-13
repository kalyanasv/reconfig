// Example with virtual class usage.

`include "pkt_class.vh"
module pkt_proc_vclass
  // Parameters for total packet size = 64 bits.
  // PACKET_DATA [DATA_SIZE] = PACKET[PARITY + FLAGS + ADDRESS + PAYLOAD]
  // PACKET_CTL  [CTL_SIZE] = PACKET[ID + EOP]
  // Note: The usage of keyword parameter is not required since SV 2009 
  // and Synopsys HDL Compiler.
  #(DATA_SIZE = 64, ECC = 1, FLAGS = 11, ADDR = 20, PAYLOAD = 32, 
   CTL_SIZE = 3, ID = 2, EOP = 1, PKT_PARSE_INSTANCES = 3)
  (  
    input logic 		clk,rst,           // Global inputs
    input logic                 pkt_valid,   
    input logic [DATA_SIZE-1:0] pkt_data_in,       // Packet input data
    input logic [CTL_SIZE-1:0] 	pkt_ctl_in,        // Packet input control
    output logic [PKT_PARSE_INSTANCES-1:0]              pkt_payload_valid,
    output logic [PKT_PARSE_INSTANCES-1:0][PAYLOAD-1:0] pkt_payload_out
   );  // Packet payload data output
  
   // Define user defined data types for pkt data and pkt ctl.   
   typedef logic [PAYLOAD-1:0] pkt_data_payload_t; // Packet data bus
   typedef logic [FLAGS-1:0]   pkt_data_flags_t;   
   typedef logic [ECC-1:0]     pkt_data_ecc_t;   
   typedef logic [ADDR-1:0]    pkt_data_addr_t;
   typedef logic [EOP-1:0]     pkt_ctl_eop_t; // Packet control bus
   typedef logic [ID-1:0]      pkt_ctl_id_t;
   
   // User defined structs for control and data path of packets.
   typedef struct packed {
      pkt_data_payload_t payload;
      pkt_data_flags_t   flags;
      pkt_data_ecc_t     ecc;
      pkt_data_addr_t    addr;
   }pkt_data_t;

   typedef struct packed {      
      pkt_ctl_id_t      id;
      pkt_ctl_eop_t     eop;      
   }pkt_ctl_t;     
   
   pkt_ctl_t                            pkt_ctl;
   pkt_ctl_t  [PKT_PARSE_INSTANCES-1:0] pkt_ctl_data;
   pkt_data_t                           pkt_data;      
   
   // Remap to PKT processor structs.
   always_ff @(posedge clk) 
      pkt_ctl  <= pkt_ctl_in;      
   always_ff @(posedge clk)  
      pkt_data <= pkt_data_in;
   
   genvar 	  gi;
   
   // Packet payload parser uses only related parameters such as PAYLOAD.
   logic [PKT_PARSE_INSTANCES-1:0] pkt_ecc_check; // Set = 1 indicates ECC failure.     
   
   for (gi = 0; gi < PKT_PARSE_INSTANCES; gi++) begin: gen_pkt_inst      
      if (gi == 0) 
	always_comb pkt_ecc_check[gi] = pkt_ecc_algo #(pkt_data_t, pkt_data_ecc_t)::odd_parity(pkt_data);	  
      else
        always_comb pkt_ecc_check[gi] = pkt_ecc_algo #(pkt_data_t, pkt_data_ecc_t)::even_parity(pkt_data);      
	  
      pkt_payload_parse_vclass
        #(.pkt_data_t(pkt_data_t),.pkt_ctl_t(pkt_ctl_t),
	  .pkt_data_payload_t(pkt_data_payload_t))
      // Auto assignment as names across modules match with I/O.
        payload_parse (.*, .pkt_valid (pkt_valid && (gi == pkt_ctl.id) && !pkt_ecc_check[gi]), 
		       .pkt_ctl_data(pkt_ctl_data[gi]),
                       .pkt_payload_valid (pkt_payload_valid[gi]),
		       .pkt_payload_out (pkt_payload_out[gi]));
      
      // Packet control parser 
      pkt_ctl_proc_vclass
      // Auto assignment as names across modules match with I/O.
	#(.pkt_ctl_t(pkt_ctl_t))
        parse_ctl (.*, .pkt_ctl_data(pkt_ctl_data[gi]),
		   .pkt_valid(pkt_valid && (gi == pkt_ctl.id)));
      
   end: gen_pkt_inst
endmodule

  
// Local Variables:
// verilog-typedef-regexp: "_t$"
// verilog-auto-template-warn-unused: t
// verilog-library-flags:("-f project/dvconf/vc/input_autos.vc")
// End:

// vim: tw=78 sw=3 ts=8 sts=4 expandtab smarttab
