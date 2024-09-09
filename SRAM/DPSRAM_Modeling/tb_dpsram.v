module tb_dpsram;
​
    parameter DEPTH = 8, WIDTH = 32;
    parameter DEPTH_LOG = $clog2(DEPTH);
​
    reg                     clk;
    reg                     cs_a, we_a, cs_b, we_b;
    reg  [DEPTH_LOG-1:0]    ad_a, ad_b;
    reg  [WIDTH-1:0]        wd_a, wd_b;
    wire [WIDTH-1:0]        rd_a, rd_b;
​
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
​
    initial begin
        cs_a <= 0; we_a <= 0;
        cs_b <= 0; we_b <= 0;
        @(posedge clk);
​
        // DPSRAM Port A Write
        for (int i = 0; i < DEPTH/2; i++) begin
            cs_a <= 1;
            we_a <= 1;
            ad_a <= i;
            wd_a <= 'h20 + i;
            @(posedge clk);
        end
​
        cs_a <= 0;
        we_a <= 0;
        @(posedge clk);
​
        // DPSRAM Port A Read
        for (int i = DEPTH/2; i < DEPTH; i++) begin
            cs_a <= 1;
            ad_a <= i;
            @(posedge clk);
        end
        cs_a <= 0;
        @(posedge clk);
​
        // DPSRAM Port B Write
        for (int i = DEPTH/2; i < DEPTH; i++) begin
            cs_b <= 1;
