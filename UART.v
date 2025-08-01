module TOP_MOD (
    input  wire clk,            // System clock (e.g., 50 MHz)
    input  wire reset,          // Asynchronous reset
    output wire txd,            // Serial output to external UART

    // TX interface
    input  wire [7:0] data_in,  // Parallel data to transmit
    input  wire transmit,       // Transmit request
    output wire tx_busy,        // TX busy flag

    // RX interface
    output wire [7:0] data_out, // Received parallel data
    output wire valid_rx,       // Valid RX flag
    output wire parity_error,   // RX parity error
    output wire stop_error      // RX stop bit error
);
wire [10:0] tx_reg_debug;
wire [10:0] rx_reg_debug;
wire [3:0]  rx_counter2;
wire [3:0]  align_counter2;


assign rx_counter2 = rx_inst.rx_counter;
assign align_counter2 = rx_inst.align_counter;
assign tx_reg_debug = tx_inst.TX_shift_reg;
assign rx_reg_debug = rx_inst.rx_shift_reg;
    // Internal wires
    wire oversample_tick;
    wire bit_tick;

    // === Instantiate baud tick generator (shared for TX and RX) ===
    uart_oversample_tick_gen #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600),
        .OVER(16)
    ) baud_gen (
        .clk(clk),
        .reset(reset),
        .oversample_tick(oversample_tick), // unused (for oversampled RX)
        .bit_tick(bit_tick)                // used as TX and RX baud tick
    );

    // === UART Transmitter ===
    uart_tx tx_inst (
        .clk(bit_tick),
        .reset(reset),
        .transmit(transmit),
        .data_in(data_in),
        .tx(txd),            // connect to external txd pin
        .busy(tx_busy)
        
    );

    // === UART Receiver ===
    uart_rx rx_inst (
         .oversample_tick(oversample_tick), 
        .bit_tick(bit_tick) ,
        .reset(reset),
        .rxd(txd),           // connect to external rxd pin
   
        .data_out(data_out),
        .valid_rx(valid_rx),
        .parity_error(parity_error),
        .stop_error(stop_error)
    );

endmodule
