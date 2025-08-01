vlib work
vlog UART.v TX.v RX2_.V boud_rate_generator.v UART_tb.v
vsim -voptargs=+acc work.help
add wave *
add wave -position insertpoint  \
sim:/help/uut/rx_inst/waiting_mid_bit \
sim:/help/uut/rx_inst/aligned \
sim:/help/uut/rx_inst/rx_counter \
sim:/help/uut/rx_inst/align_counter \
sim:/help/uut/tx_reg_debug \
sim:/help/uut/rx_reg_debug \
sim:/help/uut/oversample_tick \
sim:/help/uut/bit_tick
run -all
#quit -sim