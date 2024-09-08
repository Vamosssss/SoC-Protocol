
module sram_model #(
        parameter DEPTH = 8,
        parameter WIDTH = 32,
        parameter DEPTH_LOG = $clog2(DEPTH)
)(
        input clk,
        input cs, we,
        input [DEPTH_LOG-1:0] ad,
        input [WIDTH-1:0] din,
        output reg [WIDTH-1:0] dout
);


reg [WIDTH-1:0] mem[DEPTH-1:0];

initial begin
        for (int i=0; i<DEPTH; i++) mem[i] = 0;
end

always @(posedge clk)
        if (cs&we) mem[ad] <= din;
        else if (cs) dout <= mem[ad];



endmodule
