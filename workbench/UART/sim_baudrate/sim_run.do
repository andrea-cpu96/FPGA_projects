# ModelSim BATCH flow for the BRG testbench
# Run from inside sim_baudrate/:  vsim -c -do sim_run.do
# (For the GUI use sim_gui.do instead - it also populates the Wave window.)
transcript file sim_transcript.log
onerror {quit -f}

# Always compile into a clean local library.
if {[file exists work/_info]} { vdel -lib work -all }
vlib work

vcom -quiet ../baudrate_gen.vhd
vcom -quiet baudrate_gen_tb.vhd
vsim -voptargs=+acc work.baudrate_gen_tb
run -all
quit -f
