module uart_tx(
    input  clk,              // system clock
    input  reset,            // async reset
    input  transmit,         // load signal to send data
    input  [7:0] data_in,    // 8-bit parallel data
    output reg tx,               // serial output
    output reg busy           // transmitter busy signal

);
reg [3:0] TX_bit_index;   
reg [10:0] TX_shift_reg;// full frame: (start, data[0-7],paritybit, stop)
wire Tx_paritybit;

assign Tx_paritybit=(^data_in==1)?1:0;

always@(posedge clk or posedge reset)begin
    if(reset)begin
            tx <= 1'b1;          // idle line is high
            busy <= 0;
            TX_shift_reg <= 11'b11111111111;
            TX_bit_index <= 0;
            end
    else begin
            if (transmit && !busy) begin
                // Load full frame: start(0), data_in (LSB first), stop(1)
                TX_shift_reg <= {1'b1,Tx_paritybit, data_in,1'b0}; // MSB first = Stop, Data, Start
                busy <= 1;
                TX_bit_index <= 0;
            end else if (busy ) begin
                tx <= TX_shift_reg[0];               // send LSB first
                TX_shift_reg <= {1'b0,TX_shift_reg[10:1] }; // shift right
                TX_bit_index <= TX_bit_index+ 1;

                if (TX_bit_index == 10) begin
                    busy <= 0;
                    tx <= 1'b1;                   // return line to idle
                end
            end
        end
    end

endmodule


