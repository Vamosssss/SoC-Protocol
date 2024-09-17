module apb_regs  #(		// Parameterized APB register module
	parameter	DW=32, 	// Data Width, default is 32 bits
	parameter	AW=5	// Address Width, default is 5 bits
)(    
   input             	pclk,            // APB clock signal
   input			 	presetn,         // Asynchronous reset signal (active low)
   
   input      [AW-1:0] 	paddr,           // APB address bus
   input             	psel,            // Select signal (activated when the slave is selected)
   input             	penable,         // Enable signal (indicates the second phase of an APB transfer)
   input             	pwrite,          // Write signal (1 for write, 0 for read)
   output            	pready,          // Indicates that the slave is ready for the transfer
   input	  [DW-1:0] 	pwdata,          // Write data bus (from APB to slave)
   output reg [DW-1:0] 	prdata,          // Read data bus (from slave to APB)
   output            	pslverr,         // Slave error signal

   // Interface
   input      [31:0] 	status32,        // 32-bit status register input
   input      [15:0] 	status16,        // 16-bit status register input
   input      [ 7:0] 	status8,         // 8-bit status register input
   output reg [31:0] 	control32,       // 32-bit control register output
   output reg [15:0] 	control16,       // 16-bit control register output
   output reg [ 7:0] 	control8         // 8-bit control register output
);

// Write operation signal generation
// apb_write is activated when psel, penable, and pwrite are all active
	wire apb_write = psel & penable & pwrite;

// Read operation signal generation
// apb_read is activated when psel is active and pwrite is inactive
	wire apb_read  = psel & ~pwrite;

// Always ready for data transfer (pready is set to 1)
	assign pready  = 1'b1;

// No slave error (pslverr is set to 0)
	assign pslverr = 1'b0;

// Control register write logic
// Triggered on the rising edge of pclk or falling edge of presetn
// When reset, all control registers are initialized to 0
	always @(posedge pclk or negedge presetn)
	if (!presetn) begin
		control32 <= 0;  // Initialize control32 to 0 upon reset
		control16 <= 0;  // Initialize control16 to 0 upon reset
		control8  <= 0;  // Initialize control8 to 0 upon reset
	end 
	// If a write operation is detected, write pwdata to the appropriate control register based on paddr
	else if  (apb_write) begin
		case (paddr)
		// 5'h00 can be used as an identification register
		5'h04 : control32 <= pwdata;          // Write to control32 when paddr is 5'h04
		5'h08 : control16 <= pwdata[15:0];    // Write to control16 (lower 16 bits of pwdata) when paddr is 5'h08
		5'h0C : control8  <= pwdata[7:0];     // Write to control8 (lower 8 bits of pwdata) when paddr is 5'h0C
		// 5'h10 is reserved
		// 5'h14, 5'h18, and 5'h1C are read-only status register addresses
		endcase
	end

// Read data return logic
// Triggered on the rising edge of pclk or falling edge of presetn
// When reset, prdata is initialized to 0
	always @(posedge pclk or negedge presetn)
	if (!presetn) begin	
		prdata	<= 0;   // Initialize prdata to 0 upon reset
	end 
	// If a read operation is detected, return the corresponding value based on paddr
	else if (apb_read) begin
		case (paddr)
		5'h00 : prdata <= 'h12345678;         // Return fixed value (e.g., identification) when paddr is 5'h00
		5'h04 : prdata <= control32;          // Return control32 when paddr is 5'h04
		5'h08 : prdata <= {16'h0, control16}; // Return control16 with upper 16 bits set to 0 when paddr is 5'h08
		5'h0C : prdata <= {24'h0, control8};  // Return control8 with upper 24 bits set to 0 when paddr is 5'h0C
		// 5'h10 is reserved
		5'h14 : prdata <= status32;           // Return status32 when paddr is 5'h14
		5'h18 : prdata <= {16'h0, status16};  // Return status16 with upper 16 bits set to 0 when paddr is 5'h18
		5'h1C : prdata <= {24'h0, status8};   // Return status8 with upper 24 bits set to 0 when paddr is 5'h1C
		default: prdata <= 0;                 // For undefined addresses, return 0
		endcase
	end 
	
endmodule
