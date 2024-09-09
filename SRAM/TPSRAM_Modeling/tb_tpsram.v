module tb_tpsram;

    parameter DEPTH = 8, WIDTH = 32;
    parameter DEPTH_LOG = $clog2(DEPTH);

    reg                    clk;        // Clock signal
    reg                    we, re;     // Write enable, Read enable signals
    reg  [DEPTH_LOG-1:0]   wa, ra;     // Write address, Read address
    reg  [WIDTH-1:0]       wd;         // Write data
    wire [WIDTH-1:0]       rd;         // Read data

    // Clock generation: Toggle every 5 time units
    initial begin
        clk = 0;
        forever #5 clk = ~clk;        // Generates a clock with a period of 10 time units
    end

    // Test sequence
    initial begin
        we <= 0;                      // Initialize write enable to 0
        re <= 0;                      // Initialize read enable to 0
        @(posedge clk);               // Wait for the positive edge of the clock

        // TPSRAM Write
        for (int i = 0; i < DEPTH; i++) begin
            we <= 1;                  // Set write enable
            wa <= i;                  // Set write address
            wd <= 'h10 + i;           // Set write data (starting from 0x10, incrementing)
            @(posedge clk);           // Wait for the next clock cycle
        end

        we <= 0;                      // Disable write after the loop
        @(posedge clk);               // Wait for one clock cycle

        // TPSRAM Read
        for (int i = 0; i < DEPTH; i++) begin
            re <= 1;                  // Set read enable
            ra <= i;                  // Set read address
            @(posedge clk);           // Wait for the next clock cycle
        end

        re <= 0;                      // Disable read after the loop
        @(posedge clk);               // Wait for one clock cycle

        $finish;                      // End the simulation
    end

    // TPSRAM instance
    tpsram #(DEPTH, WIDTH) u_tpsram_8x32 (  // Instantiate the TPSRAM with the given depth and width
        .clk(clk),
        .we(we),
        .wa(wa),
        .wd(wd),
        .re(re),
        .ra(ra),
        .rd(rd)
    );

endmodule
