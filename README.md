# RTL-Design-of-a-5-Stage-In-Order-Pipelined-RISC-V-RV32I-Processor

A Verilog implementation of a 32-bit RISC-V RV32I processor featuring both 
a single-cycle and a 5-stage pipelined datapath, built bottom-up with each 
module independently verified before integration.

---

## Repository Structure
.
├── src/
│   ├── alu.v
│   ├── register_file.v
│   ├── instruction_memory.v
│   ├── data_memory.v
│   ├── imm_gen.v
│   ├── control_unit.v
│   ├── pc.v
│   ├── if_id_reg.v
│   ├── id_ex_reg.v
│   ├── ex_mem_reg.v
│   ├── mem_wb_reg.v
│   ├── hazard_unit.v
│   ├── riscv_single_cycle.v
│   └── riscv_pipeline.v
├── tb/
│   ├── alu_tb.v
│   ├── register_file_tb.v
│   ├── instruction_memory_tb.v
│   ├── data_memory_tb.v
│   ├── imm_gen_tb.v
│   ├── control_unit_tb.v
│   └── riscv_pipeline_tb.v
├── docs/
│   └── waveforms/
└── README.md

---


### Pipeline Stages
IF → ID → EX → MEM → WB

| Stage | Name | Function |
|---|---|---|
| IF | Instruction Fetch | Read instruction from memory using PC |
| ID | Instruction Decode | Decode opcode, read registers, generate immediate |
| EX | Execute | ALU operation, branch address computation |
| MEM | Memory Access | Load / store to data memory |
| WB | Write Back | Write result back to register file |

### Hazard Handling

| Hazard | Cause | Solution |
|---|---|---|
| Data hazard | Instruction needs result of previous instruction | EX-EX and MEM-EX forwarding via `forward_a`/`forward_b` muxes |
| Load-use hazard | LW result not ready for next instruction | Stall + bubble insertion |
| WB-to-ID gap | RF read and write in same cycle | Internal register file forwarding |

---

## Modules

| Module | Description |
|---|---|
| `alu.v` | 32-bit ALU — ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| `register_file.v` | 32×32 register file, x0 hardwired to zero, internal WB forwarding |
| `instruction_memory.v` | Instruction ROM with hardcoded RV32I test program |
| `data_memory.v` | Synchronous write, asynchronous read data RAM |
| `imm_gen.v` | Immediate generator — I, S, B, U, J type encodings |
| `control_unit.v` | Main decoder — generates all control signals from opcode/funct3/funct7 |
| `pc.v` | Program counter with synchronous reset |
| `if_id_reg.v` | IF/ID pipeline register with stall support |
| `id_ex_reg.v` | ID/EX pipeline register with flush support |
| `ex_mem_reg.v` | EX/MEM pipeline register |
| `mem_wb_reg.v` | MEM/WB pipeline register |
| `hazard_unit.v` | Generates `forward_a`/`forward_b` select signals, stall, flush |
| `riscv_single_cycle.v` | Single-cycle top-level datapath |
| `riscv_pipeline.v` | 5-stage pipelined top-level datapath |

---

## Supported Instructions

| Type | Instructions |
|---|---|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI |
| Load | LW |
| Store | SW |
| Branch | BEQ, BNE, BLT, BGE |
| Jump | JAL |
| Upper Immediate | LUI, AUIPC |

---

## Test Program

```asm
addi x1, x0, 5      # x1 = 5
addi x2, x0, 10     # x2 = 10
add  x3, x1, x2     # x3 = 15  (tests EX-EX forwarding)
sub  x4, x1, x2     # x4 = -5  (tests MEM-EX + WB-to-ID forwarding)
```

### Simulation Output
=== RISC-V Pipeline Testbench ===
x1 = 5   (expected 5)
x2 = 10  (expected 10)
x3 = 15  (expected 15)
x4 = -5  (expected -5)
=== Done ===

---
## Simulation Results

### Output Verification

![Output](PASTE_IMAGE_URL_HERE)

### Pipeline Waveform

![Pipeline Waveform](PASTE_SECOND_IMAGE_URL_HERE)

---
## Tools

| Tool | Purpose |
| Xilinx Vivado | RTL design, simulation, waveform analysis |
| Verilog HDL | Hardware description language |

---

## Key Design Decisions

- **Single-cycle first:** Built and verified a single-cycle datapath before pipelining to fully understand the datapath before adding pipeline complexity.
- **Bottom-up integration:** Every module independently verified before top-level integration.
- **Forwarding over stalling:** Data hazards resolved through `forward_a`/`forward_b` mux forwarding wherever possible — stalls only inserted for load-use hazards.
- **Register file internal forwarding:** When WB writes and ID reads the same register in the same cycle, the register file returns the new value directly, closing the WB-to-ID forwarding gap.

---

## Planned — Track 2 (ASIC Implementation)

Planned future work includes taking this processor through a complete RTL-to-GDS-II flow:

- Synthesis — Yosys
- Static Timing Analysis — OpenSTA
- Physical Design — OpenLane + OpenROAD
- PDK — SkyWater Sky130 (130nm open-source process)
- Final output — GDS-II

---

## References

- [RISC-V Unprivileged ISA Specification](https://riscv.org/specifications/)
- Patterson & Hennessy — *Computer Organization and Design: RISC-V Edition*
- [SkyWater Sky130 PDK](https://github.com/google/skywater-pdk)
- [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane)
