module tb;
  // Testbench signals
  reg clk, rstn;
  reg push, pop;
  reg [7:0] din;
  wire [7:0] dout;
  wire full, empty, a_full, a_empty;
  
  // Clock generation: 10 time units period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Reset generation
  initial begin
    rstn = 1;
    #20 rstn = 0;   // Assert reset
    #30 rstn = 1;   // Deassert reset
  end
  
  // Push operations
  initial begin
    push <= 0;       @(posedge rstn); // Wait for reset deassertion
    push <= 0;       @(posedge clk);  // Wait for clock edge
    push <= 1; din <= 'h10; @(posedge clk); // Push data 0x10
    push <= 1; din <= 'h11; @(posedge clk); // Push data 0x11
    push <= 1; din <= 'h12; @(posedge clk); // Push data 0x12
    push <= 1; din <= 'h13; @(posedge clk); // Push data 0x13
    push <= 0;       @(posedge clk); // Stop pushing
  end
  
  // Pop operations
  initial begin
    pop <= 0;        @(posedge rstn); // Wait for reset deassertion
    pop <= 0;        repeat (8) @(posedge clk); // Wait for FIFO to fill
    pop <= 1; @(posedge clk); pop <= 0; @(posedge clk); // Pop one item
    pop <= 1; @(posedge clk); pop <= 0; @(posedge clk); // Pop another item
    pop <= 1; @(posedge clk); pop <= 0; @(posedge clk); // Continue popping
    pop <= 1; @(posedge clk); pop <= 0; @(posedge clk); // Continue popping
    pop <= 0;        repeat (2) @(posedge clk); // Wait for remaining pops
    $finish;         // End simulation
  end
  
  // Dump waveform data for viewing
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(1, tb);
  end
  
  // Instantiate the FIFO module
  sync_fifo #(4,8,1,1) u_sync_fifo (
    clk, rstn, push, pop, din, dout, full, empty, a_full, a_empty
  );
  
endmodule
