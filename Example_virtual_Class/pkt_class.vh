virtual class pkt_ecc_algo 
			#(parameter type data_t = logic [127:0], 
	                  parameter type ecc_t = logic);
   /* 2 byte aligned checksum. Added to indicate supported complexity within the class
   Not as a reference for the checksum algorithm. */
   static function ecc_t checksum ( ecc_t initial_value, data_t data);
      // Local params and defined data types are local to the function.
      localparam NUM_CKSUM_DATA_WORDS = $bits(ecc_t)/ $bits(data_t);
      localparam NUM_CARRY_BITS = $clog2(NUM_CKSUM_DATA_WORDS);
      typedef ecc_t [NUM_CKSUM_DATA_WORDS-1:0] cksum_data_t;
      
      logic [NUM_CARRY_BITS-1:0] carry;
      ecc_t cksum;
      
      cksum_data_t cksum_data;
      cksum_data = cksum_data_t'(data);
      
      {carry,cksum} = cksum_data[0] + initial_value; // Initialize.
      
      for (int i=1; i < NUM_CKSUM_DATA_WORDS; i++) begin
	 {carry,cksum} = (|carry) ? cksum + carry : {1'b0,cksum}; 
	 {carry,cksum} = cksum + cksum_data[i] + carry;        
      end      
      cksum = cksum + carry;       // Final carry.
      return cksum;      
   endfunction
   
   static function ecc_t even_parity (data_t data);      
    return (^data);      
   endfunction
   
   static function ecc_t odd_parity (data_t data);    
    return (!(^data));     
   endfunction   
endclass