

module sram_model #(
	parameter	DEPTH=8,                     // Memory depth, default is 8
	parameter	WIDTH=32,                    // Data width, default is 32
	parameter	DEPTH_LOG=$clog2(DEPTH)      // Logarithm base 2 of DEPTH to calculate address width
)(
	input					clk,           // Clock signal
	input					cs, we,        // Chip select (cs) and Write enable (we) signals
	input 	[DEPTH_LOG-1:0] ad,           // Address input
	input 		[WIDTH-1:0]	din,           // Data input for writing
	output reg  [WIDTH-1:0]	dout           // Data output for reading
);
	reg [WIDTH-1:0]	mem[DEPTH-1:0];         // Memory array declaration
	
	// Initialization block
	initial begin
		for (int i=0;i<DEPTH;i++)	mem[i] = 0;   // Initialize memory to zero
	end
	
	// Sequential block for memory read and write operations
	always @(posedge clk)
		if (cs & we)	mem[ad]	<= din;       // Write data to memory if cs and we are asserted
		else if (cs)	dout	<= mem[ad];   // Read data from memory if cs is asserted but we is not
endmodule
