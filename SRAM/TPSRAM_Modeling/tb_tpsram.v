module tb_tpsram;

    parameter DEPTH = 8, WIDTH = 32;
    parameter DEPTH_LOG = $clog2(DEPTH);

    reg                    clk;
    reg                    we, re;
    reg  [DEPTH_LOG-1:0]   wa, ra;
    reg  [WIDTH-1:0]       wd;
    wire [WIDTH-1:0]       rd;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        we <= 0;
        re <= 0;
        @(posedge clk);

        // TPSRAM Write
        for (int i = 0; i < DEPTH; i++) begin
            we <= 1;
            wa <= i;
            wd <= 'h10 + i;
            @(posedge clk);
        end

        we <= 0;
        @(posedge clk);

        // TPSRAM Read
        for (int i = 0; i < DEPTH; i++) begin
            re <= 1;
            ra <= i;
            @(posedge clk);
        end

        re <= 0;
        @(posedge clk);

        $finish;
    end


    // TPSRAM instance
    tpsram #(DEPTH, WIDTH) u_tpsram_8x32 (
        .clk(clk),
        .we(we),
        .wa(wa),
        .wd(wd),
        .re(re),
        .ra(ra),
        .rd(rd)
    );

endmodule
