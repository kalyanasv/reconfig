// Example using interfaces.
`include "pkt_iface.svh"
`include "cpu_iface.svh"
module pkt_top  
  #(
     // Expected packet bus specification.
     parameter DATA_SIZE = 64,
     parameter CTL_SIZE = 3,
     // Individual signal bit widths.
     parameter ECC = 1,
     parameter FLAGS = 11,
     parameter ADDR = 20,
     parameter PAYLOAD = 32,  
     parameter ID = 2,
     parameter EOP = 1,     
     parameter CREDITS = 16)
   
   (input clk, rst,
    // CPU interface to trigger packet on bus.
    // input logic                           cpu_pkt_valid,
    // input logic [PAYLOAD-1:0] 		  cpu_pkt_data,
    // input logic [FLAGS-1:0] 		  cpu_pkt_flags,
    // input logic [ADDR-1:0] 		  cput_proc_id,
    cpu_iface.pkt_rx cpu_rx,
    output logic [DATA_SIZE+CTL_SIZE-1:0] sub_sys_bus,
    output 				  err
    
    );   

   // User defined data types. 
   typedef logic [PAYLOAD-1:0] pkt_data_payload_t; // Packet data bus
   typedef logic [FLAGS-1:0]   pkt_data_flags_t; 
   typedef logic [ADDR-1:0]    pkt_data_addr_t;  
   typedef logic [ECC-1:0]     pkt_data_ecc_t;      
   typedef logic [EOP-1:0]     pkt_ctl_eop_t; // Packet control bus
   typedef logic [ID-1:0]      pkt_ctl_id_t;
   
   localparam CREDIT_CNT_W = $clog2(CREDITS+1);
   typedef logic [CREDIT_CNT_W-1:0] credit_cnt_t;
   
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
   
   // Bus.
   typedef struct packed {
      pkt_data_t  data;
      pkt_ctl_t   ctl;
   }pkt_bus_t;
   // Instantiate interface.
   pkt_bus #(.pkt_bus_t(pkt_bus_t),.pkt_data_payload_t(pkt_data_payload_t),
	     .pkt_data_t(pkt_data_t),.pkt_ctl_t(pkt_ctl_t),
	     .credit_cnt_t(credit_cnt_t))  
   pkt_intf(clk);      

   // Block A
   // Can also be replicated similar to the previous examples
   // across multiple instances 
   pkt_proc #(.pkt_bus_t(pkt_bus_t))
   pkt_proc (pkt_intf.rx, sub_sys_bus, clk, rst, err);   
   // Interface Channel.
   // Add interfaces for channel modules, which are parmetrizable blocks.
   // Block B: Packet transmitter.
   pkt_gen #(.pkt_data_t(pkt_data_t),
	     .pkt_ctl_t(pkt_ctl_t),
	     .credit_cnt_t(credit_cnt_t),
	     .PKT_PROC_ID(0))
   pkt_gen (pkt_intf.tx, cpu_rx, clk, rst);
   
endmodule
