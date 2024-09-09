module dpsram #(		
	parameter	DEPTH=8,				// Depth of the memory
	parameter	WIDTH=32,				// Data width
	parameter	DEPTH_LOG=$clog2(DEPTH)	// Logarithm of the depth to determine address width
)(
	input					clk,		// Clock signal (shared for both ports)
	input					cs_a, we_a,	// Chip select and write enable for Port A
	input 	[DEPTH_LOG-1:0] ad_a,		// Address for Port A
	input 		[WIDTH-1:0]	wd_a,		// Write data for Port A
	output reg  [WIDTH-1:0]	rd_a,		// Read data for Port A
	
//	input					clk_b		// Separate clock for Port B (commented out)
	input					cs_b, we_b,	// Chip select and write enable for Port B
	input 	[DEPTH_LOG-1:0] ad_b,		// Address for Port B
	input 		[WIDTH-1:0]	wd_b,		// Write data for Port B
	output reg  [WIDTH-1:0]	rd_b		// Read data for Port B
);
	// Memory declaration
	reg [WIDTH-1:0]	mem[DEPTH-1:0];
	
	// Initial block to set all memory values to 0 at the start
	initial begin
		for (int i=0; i < DEPTH; i++)	mem[i] = 0;
	end
	
	// Port A: Write or read operation on the positive edge of the clock
	always @(posedge clk)
		if (cs_a & we_a)	mem[ad_a]	<= wd_a;		// Write to memory if chip select and write enable are high
		else if (cs_a)		rd_a		<= mem[ad_a];	// Read from memory if only chip select is high
	
	// Port B: Write or read operation on the positive edge of the clock
	always @(posedge clk)
		if (cs_b & we_b)	mem[ad_b]	<= wd_b;		// Write to memory if chip select and write enable are high
		else if (cs_b)		rd_b		<= mem[ad_b];	// Read from memory if only chip select is high
		
endmodule
