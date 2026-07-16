# RTL INT8 Systolic Array Accelerator (Verilog)

A parameterized RTL implementation of a systolic array based matrix multiplication accelerator written in Verilog HDL.

This project was built from scratch as a learning-oriented RTL design project, gradually evolving from a single signed MAC into a parameterized N×N systolic array with a reusable verification environment.

---

## Project Objectives

- Learn RTL design methodology
- Understand systolic array architecture
- Practice hierarchical hardware design
- Implement parameterized Verilog modules
- Develop self-checking verification environments
- Gain experience with FSM based controllers and dataflow architectures

---

# Project Evolution

## Version 1 – Signed MAC

Implemented a signed Multiply-Accumulate (MAC) unit.

Features:
- Signed 8-bit operands
- 32-bit accumulator
- Enable control
- Clear control
- Synchronous design

---

## Version 2 – Processing Element (PE)

Wrapped the MAC into a reusable Processing Element.

Each PE performs:

- Registered A propagation
- Registered B propagation
- Local accumulation

Outputs:
- A propagated to the right
- B propagated downward
- Partial sum accumulator

---

## Version 3

Internal design experiments and architecture refinements.

---

## Version 4 – 2×2 Systolic Array

Connected four Processing Elements into a 2×2 systolic array.

Implemented:

- Horizontal propagation of matrix A
- Vertical propagation of matrix B
- Fully pipelined data movement
- Matrix multiplication using systolic dataflow

---

## Version 5 – Controller

Designed an FSM-based controller responsible for streaming matrix data into the systolic array.

Implemented states:

```
IDLE
↓
CLEAR
↓
STREAM0
↓
STREAM1
↓
STREAM2
↓
STREAM3
↓
WAIT
↓
DONE
```

Responsibilities:

- Generate streaming schedule
- Pipeline flushing
- Busy / Done signalling
- Automatic matrix computation

---

## Version 6 – Parameterized Systolic Array

Generalized the fixed 2×2 architecture into a reusable parameterized N×N array.

Features:

- Parameterizable matrix dimension (N)
- Parameterizable data width
- Parameterizable accumulator width
- Generate loop based PE instantiation
- Generic interconnection network
- Reusable architecture

Parameters:

```verilog
parameter N = 8;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH = 32;
```

---

# Verification

A reusable self-checking testbench was developed.

Verification flow:

```
Reset DUT

↓

Load Matrix

↓

Compute Golden Result

↓

Stream Matrix

↓

Compare RTL Output

↓

PASS / FAIL
```

The testbench automatically:

- Computes software matrix multiplication
- Streams matrices into the DUT
- Compares RTL outputs against software reference
- Reports PASS/FAIL

---

# Streaming Schedule

For a 2×2 matrix multiplication the streaming schedule is

Cycle 0

```
A = [a00 0]
B = [b00 0]
```

Cycle 1

```
A = [a01 a10]
B = [b10 b01]
```

Cycle 2

```
A = [0 a11]
B = [0 b11]
```

Cycle 3

```
A = [0 0]
B = [0 0]
```

This schedule naturally generalizes for larger parameterized arrays.

---

# Architecture

```
                +----------------------+
                |   Controller (v5)    |
                +----------+-----------+
                           |
                     Streaming Inputs
                           |
                           v
                +----------------------+
                | Parameterized Array  |
                |        (v6)          |
                +----------+-----------+
                           |
         ----------------------------------------
         |        |        |        |            |
        PE       PE       PE       PE         ...
         |        |        |        |
         ----------------------------------------
                           |
                           v
                    Matrix Product
```

---

# Processing Element

Each PE performs

```
             A_in
               |
               v
         +-------------+
         | Multiply    |
         | Accumulate  |
         +-------------+
          |         |
          |         |
      A_out      B_out
```

---

# Technologies Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- VS Code

---

# Project Structure

```
rtl/
│
├── v1_signed_mac_pe.v
├── v4_systolic_pe.v
├── v4_systolic_array_2x2.v
├── v5_systolic_controller.v
└── v6_parameterized_systolic_array.v

tb/
│
└── v6_parameterized_systolic_array_tb.v

waveforms/

README.md
```

---

# Current Status

Completed

- Signed MAC
- Processing Element
- 2×2 Systolic Array
- FSM Controller
- Parameterized N×N Array
- Self-checking Testbench
- Golden Model Verification

---

# Future Improvements

Planned future work includes:

- Generic parameterized streaming controller
- External SRAM/BRAM interface
- AXI-Stream input interface
- Tile-based matrix multiplication
- Multi-matrix batching
- Performance counters
- SystemVerilog assertions
- UVM-based verification

---

# Learning Outcomes

This project helped me understand:

- RTL design methodology
- Hierarchical hardware design
- Parameterized Verilog
- Generate constructs
- Finite State Machines
- Systolic array architectures
- Dataflow scheduling
- Self-checking verification
- Matrix multiplication hardware implementation

---

# License

This project is released under the MIT License.
