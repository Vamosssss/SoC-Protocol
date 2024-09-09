module sync_fifo #(		
	parameter	DEPTH=8,           // Depth of the FIFO (number of entries)
	parameter	WIDTH=32,          // Width of the data bus (number of bits per entry)
	parameter	AF_LEVEL = 1,      // Almost Full threshold level (number of entries before FIFO is almost full)
	parameter	AE_LEVEL = 1,      // Almost Empty threshold level (number of entries before FIFO is almost empty)
  	parameter	DEPTH_LOG=$clog2(DEPTH) // Log base 2 of the depth, used for pointer width
)(
	input					clk,        // Clock signal
	input					rstn,       // Active-low reset signal
	input					push,       // Push signal to write data into FIFO
	input					pop,        // Pop signal to read data from FIFO
	input 		[WIDTH-1:0]	din,       // Data input bus
	output 		[WIDTH-1:0]	dout,      // Data output bus
	output					full,       // FIFO full flag
	output					empty,      // FIFO empty flag
	output					a_full,     // Almost full flag
	output					a_empty     // Almost empty flag
);

	// Memory array for storing FIFO data
	reg [WIDTH-1:0]		mem[DEPTH-1:0]; 

	// Write pointer (index for writing data into FIFO)
	reg [DEPTH_LOG-1:0]	wr_ptr;

	// Read pointer (index for reading data from FIFO)
	reg [DEPTH_LOG-1:0]	rd_ptr;

	// Difference between write pointer and read pointer
	reg [DEPTH_LOG  :0]	diff_ptr;

	// Synchronous reset and write operation
	always @(posedge clk, negedge rstn)
	if	(!rstn) begin
		// Reset FIFO memory to zero on reset
		for (int i=0; i<DEPTH; i++) 
			mem[i] = 0;
	end else if (push) begin
		// Write data into FIFO at the location pointed by write pointer
		mem[wr_ptr] <= din;
	end
	
	// Synchronous reset and write pointer update
	always @(posedge clk, negedge rstn)
	if		(!rstn) 
		// Reset write pointer on reset
		wr_ptr <= 0;
	else if (push) 
		// Increment write pointer when push is active
		wr_ptr <= wr_ptr + 1;
	
	// Synchronous reset and read pointer update
	always @(posedge clk, negedge rstn)
	if		(!rstn) 
		// Reset read pointer on reset
		rd_ptr <= 0;
	else if (pop) 
		// Increment read pointer when pop is active
		rd_ptr <= rd_ptr + 1;
	
	// Data output assignment
	assign dout = mem[rd_ptr];

	/* 
	// The following commented code was used for keeping the data after a pop operation until the next data is pushed.
	// This can be useful if you want to hold the previous data after a pop until new data is pushed.
	wire [DEPTH_LOG-1:0] rd_ptr_2 = rd_ptr + pop - 1;
	assign dout = mem[rd_ptr_2]; 
	*/

	// Update the difference between write and read pointers
	always @(posedge clk, negedge rstn)
	if		(!rstn) 
		// Reset the difference pointer on reset
		diff_ptr <= 0;
	else 
		// Update the difference pointer based on push and pop signals
		diff_ptr <= diff_ptr + push - pop;	
	
	// FIFO full flag: set when difference pointer is greater than or equal to FIFO depth
	assign	full  = diff_ptr >= DEPTH;

	// Almost full flag: set when difference pointer is greater than or equal to FIFO depth minus almost full level
	assign	a_full = diff_ptr >= DEPTH - AF_LEVEL;

	// FIFO empty flag: set when difference pointer is zero
	assign	empty = diff_ptr == 0;

	// Almost empty flag: set when difference pointer is less than or equal to almost empty level
	assign	a_empty = diff_ptr <= AE_LEVEL;	
	
endmodule
