module tb_dpsram;

    parameter DEPTH = 8, WIDTH = 32;
    parameter DEPTH_LOG = $clog2(DEPTH);

    reg                     clk;
    reg                     cs_a, we_a, cs_b, we_b;
    reg  [DEPTH_LOG-1:0]    ad_a, ad_b;
    reg  [WIDTH-1:0]        wd_a, wd_b;
    wire [WIDTH-1:0]        rd_a, rd_b;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock generation: toggles every 5 time units
    end

    initial begin
        cs_a <= 0; we_a <= 0;
        cs_b <= 0; we_b <= 0;
        @(posedge clk);

        // DPSRAM Port A Write
        // Writes data ('h20 + i) to the first half of memory through Port A
        for (int i = 0; i < DEPTH/2; i++) begin
            cs_a <= 1;
            we_a <= 1;
            ad_a <= i;
            wd_a <= 'h20 + i;
            @(posedge clk);
        end

        cs_a <= 0;  // Disable Port A after writing
        we_a <= 0;
        @(posedge clk);

        // DPSRAM Port A Read
        // Reads data from the second half of memory through Port A
        for (int i = DEPTH/2; i < DEPTH; i++) begin
            cs_a <= 1;
            ad_a <= i;
            @(posedge clk);
        end
        cs_a <= 0;  // Disable Port A after reading
        @(posedge clk);

        // DPSRAM Port B Write
        // Writes data ('h30 + i) to the second half of memory through Port B
        for (int i = DEPTH/2; i < DEPTH; i++) begin
            cs_b <= 1;
            we_b <= 1;
            ad_b <= i;
            wd_b <= 'h30 + i;
            @(posedge clk);
        end

        cs_b <= 0;  // Disable Port B after writing
        we_b <= 0;
        @(posedge clk);

        // DPSRAM Port B Read
        // Reads data from the first half of memory through Port B
        for (int i = 0; i < DEPTH/2; i++) begin
            cs_b <= 1;
            ad_b <= i;
            @(posedge clk);
        end
        cs_b <= 0;  // Disable Port B after reading
        @(posedge clk);

        $finish;  // End the simulation
    end

    initial begin
        $dumpfile("tb_dpsram.vcd");  // Create a VCD file for waveform viewing
        $dumpvars(1, tb_dpsram);     // Dump variables for analysis
    end

    // DPSRAM instance
    // Instantiates the DPSRAM with DEPTH and WIDTH
    dpsram #(DEPTH, WIDTH) u_dpsram_8x32 (
        .clk(clk),
        .cs_a(cs_a),
        .we_a(we_a),
        .ad_a(ad_a),
        .wd_a(wd_a),
        .rd_a(rd_a),
        .cs_b(cs_b),
        .we_b(we_b),
        .ad_b(ad_b),
        .wd_b(wd_b),
        .rd_b(rd_b)
    );

endmodule
