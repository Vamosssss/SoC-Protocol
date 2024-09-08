module tb_sram;
	
	parameter	DEPTH =8, WIDTH=32;
	parameter	DEPTH_LOG = $clog2(DEPTH);
	
	reg 				clk;
	reg 				cs, we;
	reg  [DEPTH_LOG-1:0] ad;
	reg  [WIDTH-1:0] 	din;
	wire [WIDTH-1:0]	dout;
	
	initial begin
		clk	= 0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		cs <= 0; we <= 0;
		@(posedge clk);
		for (int i=0;i<8;i++) begin
			cs 	<= 1; we <= 1;
			ad 	<= i;
			din <= 'h10+i;
			@(posedge clk);			
		end		
		
		cs <= 0; we <= 0;
		@(posedge clk);
		
		for (int i=0;i<8;i++) begin
			cs <= 1; we <= 0;
			ad <= i;			
			@(posedge clk);			
		end
		
		repeat (3) @(posedge clk);
		$finish;
	end

	
	sram_model #(DEPTH, WIDTH) u_sram_8x32 (clk, cs, we, ad, din, dout);
	
endmodule
