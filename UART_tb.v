

module help;

    // Clock and reset
    reg clk;
    reg reset;

    // TX interface
    reg [7:0] data_in;
    reg transmit;
    wire tx_busy;
    wire txd;

    // RX interface
    wire [7:0] data_out;
    wire valid_rx;
    wire parity_error;
    wire stop_error;

    // Instantiate the UART TOP module
    TOP_MOD uut (
        .clk(clk),
        .reset(reset),
        .txd(txd),
        .data_in(data_in),
        .transmit(transmit),
        .tx_busy(tx_busy),
        .data_out(data_out),
        .valid_rx(valid_rx),
        .parity_error(parity_error),
        .stop_error(stop_error)
    );

    // Clock generation: 50 MHz
    always #10 clk = ~clk;  // 20 ns period

    initial begin
        // Initial values
        clk = 0;
        reset = 1;
        transmit = 0;
        data_in = 8'h00;

        // Reset pulse
        #100;
        reset = 0;

        // Wait a bit then transmit a byte
        #200;
        data_in = 8'h3e;  // 10100101
        transmit = 1;

        #(50000*20);              // 1 clk cycle
        transmit = 0;

        // Wait long enough for frame to complete (11 bits × bit time = ~1.14 ms @ 9600 baud)
      #1146000;
        // Display output
        if (valid_rx) begin
            $display("Received: %h", data_out);
            if (parity_error)
                $display("Parity Error!,tx_parity=%h,rx_parit=%h",uut.Tx_paritybit2,uut.Rx_paritybit2);
            if (stop_error)
                $display("Stop Bit Error!");
        end else begin
            $display("No valid_rx signal received.");
        end

        #100;
        $stop;
        $display("TX Reg: %h | RX Reg: %h,RX Reg: %h,RX Reg: %h", uut.tx_reg_debug, uut.rx_reg_debug, uut.rx_counter2, uut.align_counter2);

    end

endmodule
