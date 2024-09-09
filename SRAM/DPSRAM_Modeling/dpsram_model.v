module dpsram #(		
	parameter	DEPTH=8,
	parameter	WIDTH=32,
	parameter	DEPTH_LOG=$clog2(DEPTH)
)(
	input					clk,
	input					cs_a, we_a,
	input 	[DEPTH_LOG-1:0] ad_a,
	input 		[WIDTH-1:0]	wd_a,
	output reg  [WIDTH-1:0]	rd_a,
	
//	input					clk_b			
	input					cs_b, we_b,
	input 	[DEPTH_LOG-1:0] ad_b,
	input 		[WIDTH-1:0]	wd_b,
	output reg  [WIDTH-1:0]	rd_b
);
	reg [WIDTH-1:0]	mem[DEPTH-1:0];
	
	initial begin
		for (int i=0;i<DEPTH;i++)	mem[i] = 0;
	end
	
	always @(posedge clk)
		if (cs_a & we_a)	mem[ad_a]	<= wd_a;
		else if   (cs_a)	rd_a		<= mem[ad_a];
	
	always @(posedge clk)
		if (cs_b & we_b)	mem[ad_b]	<= wd_b;
		else if   (cs_b)	rd_b		<= mem[ad_b];
		
endmodule
