module tb_spsram_swap;		
	
	parameter	DEPTH = 8, WIDTH = 32;
	parameter	DEPTH_LOG = $clog2(DEPTH);  // Calculate log base 2 of DEPTH to determine address width
	
	reg 					clk;
	reg						cs_a, we_a, cs_b, we_b;  // Control signals for Port A and Port B (Chip Select and Write Enable)
	reg  [DEPTH_LOG-1:0] 	ad_a, ad_b;  // Address inputs for Port A and Port B
	reg  [WIDTH-1:0]		wd_a, wd_b;  // Write data inputs for Port A and Port B
	wire [WIDTH-1:0]		rd_a, rd_b;  // Read data outputs for Port A and Port B
	
	reg						swap;  // Control signal for swapping data between Port A and Port B
	
	// Clock generation: toggles every 5 time units
	initial begin
		clk	= 0;
		forever #5 clk = ~clk;
	end
		
	// Testbench sequence
	initial begin
		swap <= 0;  // Initialize swap to 0 (no swapping)
		{cs_a, we_a, cs_b, we_b} <= 0;  // Initialize control signals to 0 (no read/write operations)
		@(posedge clk);
		
		// Initial write to both Port A and Port B
		// Writes 'h10 + i to Port A and 'h20 + i to Port B for all DEPTH addresses
		for (int i = 0; i < DEPTH; i++) begin
			{cs_a, we_a, cs_b, we_b} <= '1;  // Enable both ports for writing
			ad_a <= i;  // Address for Port A
			ad_b <= i;  // Address for Port B
			wd_a <= 'h10 + i;  // Write data for Port A
			wd_b <= 'h20 + i;  // Write data for Port B
			@(posedge clk);  // Wait for the next clock cycle
		end					
		{cs_a, we_a, cs_b, we_b} <= 0;  // Disable both ports after writing
		@(posedge clk);
		
		// Swap operation
		swap <= 1;  // Enable swapping
		@(posedge clk);
		for (int i = 0; i < DEPTH; i++) begin
			// Read data from both Port A and Port B
			cs_a <= 1; we_a <= 0;  // Enable Port A for reading
			cs_b <= 1; we_b <= 0;  // Enable Port B for reading
			ad_a <= i;  // Address for Port A
			ad_b <= i;  // Address for Port B
			@(posedge clk);
			
			// Swap the data: Write data from Port B to Port A and vice versa
			cs_a <= 1; we_a <= 1;  // Enable Port A for writing
			cs_b <= 1; we_b <= 1;  // Enable Port B for writing
			ad_a <= i;  // Address for Port A
			ad_b <= i;  // Address for Port B
			@(posedge clk);  // Wait for the next clock cycle
		end
		swap <= 0;  // Disable swapping
		{cs_a, we_a, cs_b, we_b} <= 0;  // Disable both ports after the swap
		@(posedge clk);
		
		// Check operation: Verify if the swap was successful by reading from both ports
		for (int i = 0; i < DEPTH; i++) begin
			cs_a <= 1; we_a <= 0;  // Enable Port A for reading
			cs_b <= 1; we_b <= 0;  // Enable Port B for reading
			ad_a <= i;  // Address for Port A
			ad_b <= i;  // Address for Port B
			@(posedge clk);  // Wait for the next clock cycle
		end					
		{cs_a, we_a, cs_b, we_b} <= 0;  // Disable both ports after reading
		
		// End the simulation after two more clock cycles
		repeat(2) @(posedge clk);
		$finish;
	end	
	
	// Generate a VCD file for waveform analysis
	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(1, tb);
	end
	
	// Swap logic: If swap is enabled, write data from Port B to Port A and vice versa
	wire [WIDTH-1:0]	wd_aa = swap ? rd_b : wd_a;  // Write data for Port A, select data from Port B if swap is enabled
	wire [WIDTH-1:0]	wd_bb = swap ? rd_a : wd_b;  // Write data for Port B, select data from Port A if swap is enabled
	
	// Instantiate two single-port SRAMs for Port A and Port B
	spsram #(DEPTH, WIDTH) u_spsram_8x32_a (clk, cs_a, we_a, ad_a, wd_aa, rd_a);  // SRAM instance for Port A
	spsram #(DEPTH, WIDTH) u_spsram_8x32_b (clk, cs_b, we_b, ad_b, wd_bb, rd_b);  // SRAM instance for Port B
		    
endmodule
