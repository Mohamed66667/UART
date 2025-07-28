
 module uart_rx (
    input  clk,
    input  reset,
    input  rxd,
    input  RX_baud_tick,

    output reg [7:0] data_out,
    output reg valid_rx,
    output reg parity_error,
    output reg stop_error
);

    reg receiving;
    reg [3:0] RX_counter;           // 0 to 11 (11 bits total)
    reg [10:0] RX_shift_reg;        // [start][data][parity][stop]
    reg Rx_paritybit;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            receiving     <= 0;
            RX_counter    <= 0;
            RX_shift_reg  <= 0;
            data_out      <= 0;
            valid_rx      <= 0;
            parity_error  <= 0;
            stop_error    <= 0;
            
            Rx_paritybit  <= 0;
        end else begin
            valid_rx <= 0;

            // Start receiving on falling edge
            if (!receiving && !rxd)
                receiving <= 1;

            if (receiving && RX_baud_tick) begin
                RX_shift_reg <= {rxd, RX_shift_reg[10:1]};
                RX_counter <= RX_counter + 1;


                if (RX_counter == 10) begin
                    receiving <= 0;
                    RX_counter <= 0;
                    
                    // Extract data and check errors
                    data_out <= RX_shift_reg[8:1]; // data bits
                    valid_rx <= 1;

                    Rx_paritybit <= ^RX_shift_reg[8:1]; // recalc parity
                    parity_error <= (RX_shift_reg[9] != Rx_paritybit);
                    stop_error <= (rxd != 1); // stop bit should be 1
                end
            end
        end
    end

endmodule
