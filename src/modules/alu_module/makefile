# Nombres de archivo
MODULE     = alu_module
TB         = $(MODULE)_tb
SRC        = $(MODULE).v
TESTBENCH  = $(TB).v
OUT        = simv
VCD        = waveform.vcd

.PHONY: all run view clean

# Compila el módulo y el testbench
all: $(SRC) $(TESTBENCH)
	iverilog -o $(OUT) $(SRC) $(TESTBENCH)

# Ejecuta la simulación
run: all
	vvp $(OUT)

# Visualiza la señal si existe VCD
view: run
	gtkwave $(VCD)

# Limpia los archivos intermedios
clean:
	rm -f $(OUT) $(VCD)
