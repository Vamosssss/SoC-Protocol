module tpsram #(		
	parameter	DEPTH=8,
	parameter	WIDTH=32,
	parameter	DEPTH_LOG=$clog2(DEPTH)
)(
	input					clk,	//write clk
	input					we, 	//write enable
	input 	[DEPTH_LOG-1:0] wa,		//write addr
	input 		[WIDTH-1:0]	wd,		//write data
	//input					rclk	//read clk
	input					re, 	//read enable
	input 	[DEPTH_LOG-1:0] ra,		//read addr
	output reg	[WIDTH-1:0]	rd		//read data
);
	reg [WIDTH-1:0]	mem[DEPTH-1:0];
	
	initial begin
		for (int i=0;i<DEPTH;i++)	mem[i] = 0;
	end
	
	always @(posedge clk)
		if (we)		mem[wa]	<= wd;
		
	always @(posedge clk)
		if (re)		rd		<= mem[ra];		
endmodule
