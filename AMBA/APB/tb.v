module tb;
	localparam AW=5, DW=32;           // Define address width (AW) and data width (DW)
	localparam WRITE=1, READ=0;       // Define constants for WRITE and READ operations
	
	// APB (Advanced Peripheral Bus) related signals
	reg   			pclk, presetn;
	
	reg   [31:0] 	paddr;            // APB address signal
	reg          	penable, pwrite;  // penable: APB enable signal, pwrite: Write enable signal
	reg	  [DW-1:0] 	pwdata;           // APB write data signal
	reg				psel_0;           // Select signal for the first slave
	wire            pready_0, pslverr_0;	// Ready and error signals for the first slave
	wire  [DW-1:0] 	prdata_0;         // Read data signal for the first slave
	reg				psel_1;           // Select signal for the second slave
	wire            pready_1, pslverr_1;	// Ready and error signals for the second slave
	wire  [DW-1:0] 	prdata_1;         // Read data signal for the second slave
	
	// Interface signals for status and control registers
	reg  [31:0] 	status32_0, status32_1; // 32-bit status registers
	reg  [15:0] 	status16_0, status16_1; // 16-bit status registers
	reg  [ 7:0] 	status8_0,  status8_1;  // 8-bit status registers
	wire [31:0] 	control32_0, control32_1; // 32-bit control registers
	wire [15:0] 	control16_0, control16_1; // 16-bit control registers
	wire [ 7:0] 	control8_0,  control8_1;  // 8-bit control registers
	
	// Clock generation with a period of 10ns
	initial begin
		pclk	= 0;
		forever #5 pclk = ~pclk;  // Toggle pclk every 5ns to create a 10ns period
	end

	// Reset signal initialization and control
	initial begin
		presetn = 1;   // Initially de-assert the reset (active low)
		#20 presetn = 0;  // Assert reset after 20ns
		#30 presetn = 1;  // De-assert reset after 30ns
	end

	// APB request sequence generation
	initial begin
		{penable, psel_0, psel_1, pwrite} <= 0;  // Initialize control signals to 0
		@(posedge presetn);  // Wait for reset de-assertion
		repeat (2) @(posedge pclk);  // Wait for two clock cycles
		
		// Write transactions to slave 0
		for (int i = 0; i < 'h20; i = i + 4) 
			apb_req (WRITE, 'h00 + i, 'hFFFFFF00 + i);  
			
		// Write transactions to slave 1
		for (int i = 0; i < 'h20; i = i + 4) 
			apb_req (WRITE, 'h20 + i, 'hFFFFFF80 + i);  
			
		// Read transactions from slave 0
		for (int i = 0; i < 'h20; i = i + 4) 
			apb_req (READ , 'h00 + i, 0);	
		
		// Read transactions from slave 1
		for (int i = 0; i < 'h20; i = i + 4) 
			apb_req (READ , 'h20 + i, 0);	
		
		repeat (2) @(posedge pclk);  // Wait for two clock cycles
		$finish;  // End the simulation
	end

	// Assign values to the status registers for slave 0
	assign status32_0	= 'h32032032;  // 32-bit status register value for slave 0
	assign status16_0	= 'h1601;      // 16-bit status register value for slave 0
	assign status8_0	= 'h80;        // 8-bit status register value for slave 0

	// Assign values to the status registers for slave 1
	assign status32_1	= 'h32132132;  // 32-bit status register value for slave 1
	assign status16_1	= 'h1611;      // 16-bit status register value for slave 1
	assign status8_1	= 'h81;        // 8-bit status register value for slave 1


	// Task to handle APB transactions
	task apb_req (
		input 		 cmd,           // Command: READ or WRITE
		input [31:0] addr,          // APB address
		input [31:0] data           // Data for write operations
	); 
		{penable, pwrite} <= 0;  // Initialize penable and pwrite
		psel_0 <= addr[31:AW] == 0;  // Select slave 0 if the upper bits of the address match
		psel_1 <= addr[31:AW] == 1;  // Select slave 1 if the upper bits of the address match
		
		// Handle the command (READ or WRITE)
		case (cmd)
			WRITE: begin
				paddr  <= addr;     // Set the address
				pwdata <= data;     // Set the data to be written
				pwrite <= 1'b1;     // Enable write operation
			end
			READ: begin
				paddr  <= addr;     // Set the address for reading
				pwrite <= 1'b0;     // Set to read mode
			end    
		endcase
		
		@(posedge pclk);  // Wait for one clock cycle
		penable <= 1;     // Enable the APB transfer (second phase)
		@(posedge pclk);  // Wait for one clock cycle
		{penable, psel_0, psel_1, pwrite} <= 0;  // Reset control signals after the transfer
		@(posedge pclk);  // Wait for one clock cycle
	endtask

	// Generate simulation dump file
	initial begin
		$dumpfile("tb.vcd");        // Specify the name of the dump file
		$dumpvars(1, tb);           // Dump the variables of the testbench
	end

	// Instantiate the first apb_regs module (slave 0)
	apb_regs #(.DW(DW), .AW(AW)) u_apb_regs_0 (   	
      .pclk     (pclk),            // Connect pclk signal
	  .presetn	(presetn),         // Connect reset signal
      .paddr    (paddr[AW-1:0]),   // Connect address signal
      .pwrite   (pwrite),          // Connect write enable signal
      .psel     (psel_0),          // Connect slave 0 select signal
      .penable  (penable),         // Connect enable signal
      .pwdata   (pwdata),          // Connect write data
      .prdata   (prdata_0),        // Connect read data output
      .pready   (pready_0),        // Connect ready signal
      .pslverr  (pslverr_0),       // Connect error signal

	  // Connect interface for status and control registers
      .status32 (status32_0),
      .status16 (status16_0),
      .status8  (status8_0 ),
      .control32(control32_0),
      .control16(control16_0),
      .control8 (control8_0) 
   );

	// Instantiate the second apb_regs module (slave 1)
	apb_regs #(.DW(DW), .AW(AW)) u_apb_regs_1 (   	
		.pclk     (pclk),            // Connect pclk signal
		.presetn  (presetn),         // Connect reset signal
		.paddr    (paddr[AW-1:0]),   // Connect address signal
		.pwrite   (pwrite),          // Connect write enable signal
		.psel     (psel_1),          // Connect slave 1 select signal
		.penable  (penable),         // Connect enable signal
		.pwdata   (pwdata),          // Connect write data
		.prdata   (prdata_1),        // Connect read data output
		.pready   (pready_1),        // Connect ready signal
		.pslverr  (pslverr_1),       // Connect error signal
		
		// Connect interface for status and control registers
		.status32 (status32_1),
		.status16 (status16_1),
		.status8  (status8_1 ),
		.control32(control32_1),
		.control16(control16_1),
		.control8 (control8_1) 
   );
endmodule
