/*module baud_tick_gen (
    input  clk,             // system clock
    input  reset,           // asynchronous reset
    output reg baud_tick        // 1-cycle pulse at baud rate
);

    
    parameter CLK_FREQ = 50000000;  // 50 MHz
    parameter BAUD_RATE = 9600;     // 9600 bps
    parameter DIVISOR = CLK_FREQ / BAUD_RATE;

    // For DIVISOR ≈ 5208, 13 bits are enough (2^13 = 8192)
    reg [12:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter <= 0;
                baud_tick <= 1;
            end else begin
                counter <= counter + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule*/
module uart_oversample_tick_gen (
    input wire clk,               // system clock (e.g., 50 MHz)
    input wire reset,             // async reset
    output reg oversample_tick,   // ticks every 1/(baud×16)
    output reg bit_tick           // ticks once every 16 oversample ticks (i.e., 1 baud tick)
);

    // === CONFIGURATION ===
    parameter CLK_FREQ = 50000000;    // 50 MHz
    parameter BAUD_RATE = 9600;       // desired UART baud rate
    parameter OVER = 16;              // oversampling factor (usually 16)
    parameter DIVISOR = CLK_FREQ / (BAUD_RATE * OVER); // 50M / (9600*16) ≈ 326

    // === MANUAL BIT WIDTH (enough to count to DIVISOR-1) ===
    reg [9:0] div_counter;            // 10 bits is enough for DIVISOR ~ 326
    reg [3:0] over_counter;           // counts 0–15 for 16 oversamples

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_counter      <= 0;
            over_counter     <= 0;
            oversample_tick  <= 0;
            bit_tick         <= 0;
        end else begin
            if (div_counter == DIVISOR - 1) begin
                div_counter <= 0;
                oversample_tick <= 1;

                if (over_counter == OVER - 1) begin
                    over_counter <= 0;
                    bit_tick <= 1;     // 1 full bit period completed
                end else begin
                    over_counter <= over_counter + 1;
                    bit_tick <= 0;
                end
            end else begin
                div_counter <= div_counter + 1;
                oversample_tick <= 0;
                bit_tick <= 0;
            end
        end
    end

endmodule


