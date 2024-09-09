module tb_spsram_swap;		
	
	parameter	DEPTH =8, WIDTH=32;
	parameter	DEPTH_LOG = $clog2(DEPTH);
	
	reg 					clk;
	reg						cs_a, we_a, cs_b, we_b;
	reg  [DEPTH_LOG-1:0] 	ad_a, ad_b;
	reg  [WIDTH-1:0]		wd_a, wd_b;
	wire [WIDTH-1:0]		rd_a, rd_b;
	
	reg						swap;
	
	initial begin
		clk	= 0;
		forever #5 clk = ~clk;
	end
		
	initial begin
		swap <= 0;
		{cs_a,we_a,cs_b,we_b} <= 0;		
		@(posedge clk);
		//initial_write
		for (int i=0;i<DEPTH;i++) begin
			{cs_a,we_a,cs_b,we_b} <= '1;	
			ad_a <= i; ad_b <= i;
			wd_a <= 'h10+i; wd_b <= 'h20+i;
			@(posedge clk);			
		end					
		{cs_a,we_a,cs_b,we_b} <= 0;		
		@(posedge clk);
		
		//swap
		swap <= 1; @(posedge clk);
		for (int i=0;i<DEPTH;i++) begin
			cs_a <= 1; we_a <= 0; cs_b <= 1; we_b <= 0; ad_a <= i; ad_b <= i;
			@(posedge clk);
			cs_a <= 1; we_a <= 1; cs_b <= 1; we_b <= 1; ad_a <= i; ad_b <= i;			
			@(posedge clk);
		end
		swap <= 0; 
		{cs_a,we_a,cs_b,we_b} <= 0;	
		@(posedge clk);
		
		//check
		for (int i=0;i<DEPTH;i++) begin
			cs_a <= 1; we_a <= 0; cs_b <= 1; we_b <= 0; ad_a <= i; ad_b <= i;
			@(posedge clk);			
		end					
		{cs_a,we_a,cs_b,we_b} <= 0;		
				
		repeat(2) @(posedge clk);
		$finish;
	end	
	
	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(1, tb);
	end
	
	wire [WIDTH-1:0]	wd_aa = swap? rd_b: wd_a;
	wire [WIDTH-1:0]	wd_bb = swap? rd_a: wd_b;
	
	spsram #(DEPTH, WIDTH) u_spsram_8x32_a (clk,cs_a,we_a,ad_a,wd_aa,rd_a);
	spsram #(DEPTH, WIDTH) u_spsram_8x32_b (clk,cs_b,we_b,ad_b,wd_bb,rd_b);
		    
	
endmodule
