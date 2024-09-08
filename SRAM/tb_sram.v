module tb_sram;

parameter DEPTH=8, WIDTH=32;
parameter DEPTH_LOG = $clog2(DEPTH);

reg clk;
reg cs, we;
reg [DEPTH_LOG-1:0] ad;
reg [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;

//clk gen//
initial begin
        clk = 0;
        forever #5 clk = ~clk;
end

//WRITE//
initial begin
        cs <=0; we <=0;
        @(posedge clk);
        for (int i=0; i<DEPTH; i++) begin
                cs<=1; we<=1; //WRITE SIGNAL//
                ad<=i;
                din<= 'h10 + i;
                @(posedge clk);

        end



        cs<=0; we<=0;
        @(posedge clk);
//READ//

        for(int i=0; i<DEPTH; i++) begin
                cs<=1; we<=0;
                ad<=i;
                @(posedge clk);
        end

        @(posedge clk);
        @(posedge clk);

        $finish;
end
  
  initial begin
    $dumpfile("tb_sram.vcd");
    $dumpvars(1,tb_sram);
  end
  


sram_model #(.DEPTH(DEPTH), .WIDTH(WIDTH)) u_sram_8x32(clk, cs, we, ad, din, dout);

endmodule
