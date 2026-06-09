
create_clock -name clk_50MHz -period 20.000 [get_ports {clk}]
set_false_path -from [get_ports {rstn UART_rx_pin}]
set_false_path -to [get_ports {UART_tx_pin}]