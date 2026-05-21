# Code Examples

All examples use Icarus Verilog (`iverilog`). Each file contains both the module and its testbench.

## Running Examples

```bash
# Compile and run a single example
iverilog -o output chX/example.v
vvp output

# View waveform (if $dumpfile is used)
gtkwave output.vcd
```

## Chapter 1: Hardware Mindset

| File | Description |
|------|-------------|
| `led_blinker.v` | LED rotator with counter -- basic module structure |
| `adder.v` | N-bit adder with overflow detection |

## Chapter 2: Combinational vs Sequential

| File | Description |
|------|-------------|
| `d_flip_flop.v` | D-FF variants: async reset, sync reset, enable |
| `counter.v` | Up/down counter with load |
| `shift_register.v` | Universal shift register |
| `fsm_traffic_light.v` | Traffic light Moore FSM |

## Chapter 3: Building the ALU

| File | Description |
|------|-------------|
| `alu.v` | Full 8-operation ALU with zero/overflow/carry flags |

## Chapter 4: RISC-V Instruction Set

| File | Description |
|------|-------------|
| `regfile.v` | 32-register file with 2 read ports, 1 write port |
| `decoder.v` | RISC-V instruction field decoder |
| `simple_riscv.v` | Minimal RISC-V-like processor (simulated) |
