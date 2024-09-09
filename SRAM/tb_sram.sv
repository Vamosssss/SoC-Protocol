module tb_sram;

	parameter	DEPTH = 8, WIDTH = 32;                  // Memory depth and data width
	parameter	DEPTH_LOG = $clog2(DEPTH);              // Address width calculation based on depth
	
	reg 				clk;                            // Clock signal
	reg 				cs, we;                         // Chip select and write enable signals
	reg  [DEPTH_LOG-1:0] ad;                            // Address input
	reg  [WIDTH-1:0] 	din;                            // Data input for writing
	wire [WIDTH-1:0]	dout;                           // Data output for reading
	
	// Clock generation: 10ns period (100MHz clock)
	initial begin
		clk = 0;                                       // Initialize clock to 0
		forever #5 clk = ~clk;                         // Toggle clock every 5ns (50% duty cycle)
	end
	
	// Stimulus block: write and read operations
	initial begin
		cs <= 0; we <= 0;                             // Initialize chip select and write enable to 0
		@(posedge clk);                               // Wait for the next clock edge
		
		// Writing data to memory
		for (int i = 0; i < 8; i++) begin
			cs 	<= 1; we <= 1;                        // Enable chip select and write enable
			ad 	<= i;                                 // Set address
			din <= 'h10 + i;                          // Set data (write values 0x10, 0x11, ..., 0x17)
			@(posedge clk);                           // Wait for the next clock edge
		end		
		
		cs <= 0; we <= 0;                             // Disable chip select and write enable
		@(posedge clk);                               // Wait for the next clock edge
		
		// Reading data from memory
		for (int i = 0; i < 8; i++) begin
			cs <= 1; we <= 0;                         // Enable chip select, disable write enable (read mode)
			ad <= i;                                  // Set address
			@(posedge clk);                           // Wait for the next clock edge
		end
		
		repeat (3) @(posedge clk);                    // Wait for 3 additional clock cycles
		$finish;                                      // End simulation
	end

	// Instantiate the SRAM model (8x32)
	sram_model #(DEPTH, WIDTH) u_sram_8x32 (clk, cs, we, ad, din, dout);

endmodule
