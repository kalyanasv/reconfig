`ifndef _CPU_IFACE_SVH
 `define _CPU_IFACE_SVH
   
interface  cpu_iface;

     localparam DATA_SIZE = 64;
     localparam CTL_SIZE = 3;
     // Individual signal bit widths.   
     localparam FLAGS = 11;
     localparam ADDR = 20;
     localparam PAYLOAD = 32;  
     localparam ID = 2;
     localparam EOP = 1; 

     // User defined data types. 
   typedef logic [PAYLOAD-1:0] pkt_data_payload_t; // Packet data bus
   typedef logic [FLAGS-1:0]   pkt_data_flags_t; 
   typedef logic [ADDR-1:0]    pkt_data_addr_t;  
     
   typedef logic [EOP-1:0]     pkt_ctl_eop_t; // Packet control bus
   typedef logic [ID-1:0]      pkt_ctl_id_t;
   
   
   pkt_data_payload_t pkt_data;
   pkt_data_flags_t   pkt_flags;  
   pkt_data_addr_t    proc_id;   
   logic      pkt_valid;
   
   // CPU Transmit interface.
   modport pkt_tx (output pkt_data, output pkt_flags, output proc_id, 
		   output pkt_valid); 
    // Co-Proc RX interface.
   modport pkt_rx (input pkt_data, input pkt_flags, input proc_id, 
		   input pkt_valid);
   
endinterface   
   
`endif 