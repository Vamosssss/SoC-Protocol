module tpsram #(		
	parameter	DEPTH=8,				// Depth of the SRAM
	parameter	WIDTH=32,				// Data width
	parameter	DEPTH_LOG=$clog2(DEPTH)	// Logarithm of the depth to determine address width
)(
	input					clk,	// Write and read clock
	input					we, 	// Write enable signal
	input 	[DEPTH_LOG-1:0] wa,		// Write address
	input 		[WIDTH-1:0]	wd,		// Write data
	//input					rclk	// Read clock - commented out
	input					re, 	// Read enable signal
	input 	[DEPTH_LOG-1:0] ra,		// Read address
	output reg	[WIDTH-1:0]	rd		// Read data
);
	// Memory declaration
	reg [WIDTH-1:0]	mem[DEPTH-1:0];
	
	// Initial block to set all memory values to 0 at the start
	initial begin
		for (int i = 0; i < DEPTH; i++)	mem[i] = 0;
	end
	
	// Write operation on the positive edge of the clock
	always @(posedge clk)
		if (we)		mem[wa]	<= wd;
		
	// Read operation on the positive edge of the clock
	always @(posedge clk)
		if (re)		rd		<= mem[ra];		
endmodule
