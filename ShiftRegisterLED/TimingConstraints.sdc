create_clock -name InputOscillator -period 20 [get_ports {clk}]

set_false_path -from [get_ports {sw}]

set_false_path -from [get_ports {rst}]

set_false_path -to [get_ports {led[*]}]