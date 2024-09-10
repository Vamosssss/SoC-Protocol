module async_fifo #(		
	parameter	DEPTH=8,            // FIFO depth (number of storage locations)
	parameter	WIDTH=8,            // Data width (number of bits per entry)
  	parameter	DEPTH_LOG=$clog2(DEPTH)  // Logarithm of the depth (used for addressing)
)(
	input           	rstn,              // Active-low reset signal
	// WCLK DOMAIN
	input           	wclk,              // Write clock
	input           	push,              // Push signal (indicates data write)
	input [WIDTH-1:0] 	din,               // Data input
	output          	full,              // Full flag (indicates FIFO is full)
	// RCLK DOMAIN
	input           	rclk,              // Read clock
	input           	pop,               // Pop signal (indicates data read)
	output [WIDTH-1:0] 	dout,              // Data output
	output          	empty              // Empty flag (indicates FIFO is empty)
);

	// FIFO memory storage, with DEPTH entries of WIDTH-bit each
	reg  [WIDTH-1:0] 	mem [DEPTH-1:0];
	
	// WCLK DOMAIN
	reg  [DEPTH_LOG:0] 	wptr_bin;         // Binary write pointer
	wire [DEPTH_LOG:0] 	wptr_gray;        // Gray-coded write pointer
	reg  [DEPTH_LOG:0] 	rptr_gray_meta, rptr_gray_wclk;  // Meta-stabilized read pointer (synchronized to the write clock domain)
	
	// RCLK DOMAIN
	reg  [DEPTH_LOG:0] 	rptr_bin;         // Binary read pointer
	wire [DEPTH_LOG:0] 	rptr_gray;        // Gray-coded read pointer
	reg  [DEPTH_LOG:0] 	wptr_gray_meta, wptr_gray_rclk;  // Meta-stabilized write pointer (synchronized to the read clock domain)
	
	// WCLK DOMAIN: Write data to FIFO memory when 'push' is high and FIFO is not full
	always @(posedge wclk or negedge rstn)
	if 		(!rstn) // Reset condition: Initialize FIFO memory
		for (int i=0; i<DEPTH; i++)	
			mem[i] <= 0;		
	else if (push & ~full) // Write data when 'push' is asserted and FIFO is not full
		mem[wptr_bin[DEPTH_LOG-1:0]] <= din;
	
	
	// WCLK DOMAIN: Binary write pointer logic
	always @(posedge wclk or negedge rstn)
	if 		(!rstn)		// Reset condition: Reset write pointer
		wptr_bin <= 0;
	else if (push & ~full)  // Increment write pointer on valid push
		wptr_bin <= wptr_bin + 1;
	
	// Convert binary write pointer to Gray code
	assign wptr_gray = bin2gray(wptr_bin);	
	
	// WCLK DOMAIN: Synchronize the read pointer to the write clock domain (2-stage synchronization)
	always @(posedge wclk or negedge rstn)
	if 		(!rstn) begin  // Reset condition: Clear the synchronized read pointer
		rptr_gray_meta <= 0;
		rptr_gray_wclk <= 0;
	end else begin  // Synchronize the read pointer from the read clock domain to the write clock domain
		rptr_gray_meta <= rptr_gray;
		rptr_gray_wclk <= rptr_gray_meta;	// Second stage of synchronization
	end   		

	// WCLK DOMAIN: Full condition detection using Gray-coded pointers
	// Check if the write pointer is one position ahead of the read pointer, meaning the FIFO is full
	assign full = (wptr_gray[DEPTH_LOG-:2]  == ~rptr_gray_wclk[DEPTH_LOG-:2]) &&
				  (wptr_gray[DEPTH_LOG-2:0] == rptr_gray_wclk[DEPTH_LOG-2:0]);

	// RCLK DOMAIN: Binary read pointer logic
	always @(posedge rclk or negedge rstn)
	if 		(!rstn)		// Reset condition: Reset read pointer
		rptr_bin <= 0;
	else if (pop & ~empty) // Increment read pointer on valid pop
		rptr_bin <= rptr_bin + 1;
	
	// Convert binary read pointer to Gray code
	assign rptr_gray = bin2gray(rptr_bin);		
	
	// RCLK DOMAIN: Synchronize the write pointer to the read clock domain (2-stage synchronization)
	always @(posedge rclk or negedge rstn)
	if 		(!rstn) begin  // Reset condition: Clear the synchronized write pointer
		wptr_gray_meta <= 0;
		wptr_gray_rclk <= 0;
	end else begin  // Synchronize the write pointer from the write clock domain to the read clock domain
		wptr_gray_meta <= wptr_gray;
		wptr_gray_rclk <= wptr_gray_meta;
	end

	// RCLK DOMAIN: Empty condition detection using Gray-coded pointers
	// Check if the read pointer is equal to the write pointer, meaning the FIFO is empty
	assign empty = (rptr_gray == wptr_gray_rclk);
	
	// Output data from the FIFO when valid, using the binary read pointer
	assign dout = mem[rptr_bin[DEPTH_LOG-1:0]];
	
	// Function to convert a binary number to Gray code
	function [DEPTH_LOG:0] bin2gray;
		input  [DEPTH_LOG:0] bin;
		begin
			bin2gray = (bin >> 1) ^ bin;  // Gray code conversion
		end
	endfunction
		
endmodule

