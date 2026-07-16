# RTL INT8 AI Accelerator – Version 6

A parameterized RTL implementation of a systolic array based matrix multiplication accelerator written in Verilog.

This project was developed incrementally, beginning from a single signed Multiply-Accumulate (MAC) unit and evolving into a scalable parameterized systolic array with an automated self-checking verification environment.

---

# Project Overview

The objective of this project is to understand how modern AI accelerators (Google TPU, NVIDIA Tensor Cores, etc.) perform matrix multiplication using systolic arrays.

Rather than implementing a complete AI accelerator immediately, the project was divided into multiple versions where each version introduced one new architectural concept.

Current Progress:

```
v1 → Signed MAC
      ↓
v2 → Processing Element (PE)
      ↓
v4 → 2×2 Systolic Array
      ↓
v5 → FSM Based Controller
      ↓
v6 → Parameterized N×N Systolic Array
```

---

# Features

- Parameterized array size (N × N)
- Parameterized data width
- Parameterized accumulator width
- Modular Processing Element (PE)
- Generate-loop based hardware generation
- Streaming dataflow architecture
- Self-checking verification environment
- Software golden reference model
- Automatic PASS/FAIL reporting

---

# Project Architecture

```
                +--------------------+
                |    Matrix Stream   |
                +----------+---------+
                           |
                           v
              +-------------------------+
              | Parameterized Systolic  |
              |        Array            |
              +-------------------------+
               |      |      |      |
               v      v      v      v
            +-----+ +-----+ +-----+ +-----+
            | PE  | | PE  | | PE  | | PE  |
            +-----+ +-----+ +-----+ +-----+
```

Each PE performs

```
ACC = ACC + A × B
```

while forwarding

- A horizontally
- B vertically

creating the systolic dataflow.

---

# Processing Element

Each Processing Element contains

- Signed multiplier
- Accumulator
- Input registers
- Pipeline forwarding registers

Inputs

```
A_in
B_in
```

Outputs

```
A_out
B_out
Accumulator Output
```

---

# Parameterization

The design is fully parameterized.

```verilog
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH  = 32;
parameter N          = 8;
```

Changing

```
N = 2
```

to

```
N = 4
```

or

```
N = 8
```

automatically generates the required hardware without modifying RTL.

---

# Generate Loop Implementation

Instead of manually instantiating every PE,

the array is generated automatically.

```verilog
generate
for(i=0;i<N;i=i+1)
begin
    for(j=0;j<N;j=j+1)
    begin
        v4_systolic_pe PE(...);
    end
end
endgenerate
```

This greatly improves scalability and code reuse.

---

# Dataflow

Matrix multiplication is performed using a streaming architecture.

Example for a 2×2 multiplication

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

This skewed dataflow allows every Processing Element to receive operands at the correct cycle.

---

# Verification Methodology

A self-checking testbench was developed.

The verification environment consists of

```
Clock Generation

↓

Reset Task

↓

Matrix Loader

↓

Golden Model

↓

Streaming Driver

↓

Result Checker
```

---

## Golden Reference Model

The expected output is computed entirely in software.

```text
for i
    for j
        for k
            C[i][j] += A[i][k] × B[k][j]
```

This allows automatic verification of the RTL output.

---

## Automatic Result Checking

The testbench compares

```
RTL Output
```

against

```
Golden Output
```

and reports

```
PASS
```

or

```
FAIL
```

along with the exact mismatch location.

Example

```
Mismatch at C[1][0]

Expected : 43

Got      : 41
```

---

# Simulation

Simulator

```
Icarus Verilog
```

Waveform Viewer

```
GTKWave
```

Compile

```bash
iverilog -g2012 -o v6_test \
v1_signed_mac_pe.v \
v4_systolic_pe.v \
v6_parameterized_systolic_array.v \
v6_parameterized_systolic_array_tb.v
```

Run

```bash
vvp v6_test
```

---

# Example Output

```
Checking Results

PASS

Golden Matrix

19 22
43 50

RTL Output

19 22
43 50
```

---

# Concepts Learned

Through this project I learned

- RTL design methodology
- Signed arithmetic
- Processing Element design
- Systolic array architecture
- Matrix multiplication dataflow
- Parameterized Verilog
- Generate statements
- FSM based controller design
- Self-checking verification
- Golden reference modeling
- Automated verification

---

# Future Improvements

Planned future work

- Parameterized Controller
- Memory Interface
- Tile Based Matrix Multiplication
- AXI Interface
- SRAM Integration
- SystemVerilog Assertions
- Randomized Verification
- FPGA Implementation
- INT8 Convolution Engine

---

# Repository Structure

```
rtl/

    v1_signed_mac_pe.v

    v4_systolic_pe.v

    v4_systolic_array_2x2.v

    v5_systolic_controller.v

    v6_parameterized_systolic_array.v

tb/

    v6_parameterized_systolic_array_tb.v

waveforms/

docs/
```

---

# Project Status

Current Version

```
Version 6
```

Status

```
Stable

Verified using self-checking testbench
```

---

# Author

Arpan

Electrical Engineering Undergraduate

Interested in RTL Design, Digital IC Design and AI Hardware Accelerators.
