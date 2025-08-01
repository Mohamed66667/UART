module uart_rx (
    input clk,
    input  wire reset,
    input  wire rxd,
    input  wire oversample_tick, // Tick every 1/16 of a bit time
    input  wire bit_tick,        // Tick once per bit (every 16 ticks)

    output reg [7:0] data_out,
    output reg       valid_rx,
    output reg       parity_error,
    output reg       stop_error
);

    reg        receiving;
    reg        aligned;
    reg        sample_enable;
    reg [3:0]  rx_counter;
    reg [10:0] rx_shift_reg;
    reg [3:0]  align_counter;
    reg        Rx_paritybit;

    // Internal signal for midpoint alignment
    reg waiting_mid_bit;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            receiving       <= 0;
            aligned         <= 0;
            waiting_mid_bit <= 0;
            align_counter   <= 0;
            rx_counter      <= 0;
            sample_enable   <= 0;
            rx_shift_reg    <= 0;
            data_out        <= 0;
            valid_rx        <= 0;
            parity_error    <= 0;
            stop_error      <= 0;
            Rx_paritybit    <= 0;
        end else begin
            valid_rx <= 0; // one cycle pulse

            // Alignment logic using oversample_tick
            if (oversample_tick) begin
                if (!receiving && !waiting_mid_bit && !rxd) begin
                    receiving       <= 1;
                    waiting_mid_bit <= 1;
                    align_counter   <= 0;
                end

                if (waiting_mid_bit) begin
                    align_counter <= align_counter + 1;
                    if (align_counter == 7) begin
                        waiting_mid_bit <= 0;
                        aligned         <= 1;
                        rx_counter      <= 0;
                    end
                end
            end

            // Sampling logic using bit_tick
            if (bit_tick && aligned) begin
                rx_shift_reg <= {rxd, rx_shift_reg[10:1]};
                rx_counter   <= rx_counter + 1;

                if (rx_counter == 10) begin
                    aligned       <= 0;
                    receiving     <= 0;

                    data_out      <= rx_shift_reg[8:1];
                    Rx_paritybit  <= rx_shift_reg[9];
                    parity_error  <= (rx_shift_reg[9] != ^rx_shift_reg[8:1]);
                    stop_error    <= (rxd != 1);
                    valid_rx      <= 1;
                end
            end
        end
    end

endmodule
