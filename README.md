# 🚀 Parameterized INT8 Systolic Array Accelerator

[![HDL](https://img.shields.io/badge/HDL-Verilog-blue.svg)](#)
[![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-orange.svg)](#)
[![Waveform](https://img.shields.io/badge/Waveform-GTKWave-yellow.svg)](#)
[![Architecture](https://img.shields.io/badge/Architecture-N%C3%97N%20Systolic%20Array-purple.svg)](#)
[![Precision](https://img.shields.io/badge/Precision-INT8-red.svg)](#)
[![Status](https://img.shields.io/badge/Status-RTL%20Complete-success.svg)](#current-status)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)

> A parameterized **INT8 matrix-multiplication accelerator implemented in Verilog RTL**, evolving from a signed Multiply-Accumulate (MAC) unit into a reusable **N×N systolic array** with an FSM-based streaming controller and a self-checking verification environment.

The project was developed incrementally to understand how matrix-multiplication accelerators can be constructed from simple, reusable RTL building blocks.

---

## 📌 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Design Objectives](#2-design-objectives)
3. [Project Evolution](#3-project-evolution)
4. [Architecture](#4-architecture)
5. [Processing Element](#5-processing-element)
6. [Systolic Dataflow](#6-systolic-dataflow)
7. [Streaming Schedule](#7-streaming-schedule)
8. [Parameterized Design](#8-parameterized-design)
9. [Controller](#9-controller)
10. [Verification](#10-verification)
11. [Technologies Used](#11-technologies-used)
12. [Repository Structure](#12-repository-structure)
13. [Current Status](#13-current-status)
14. [Design Trade-offs](#14-design-trade-offs)
15. [Future Improvements](#15-future-improvements)
16. [Learning Outcomes](#16-learning-outcomes)
17. [Interview Talking Points](#17-interview-talking-points)
18. [License](#18-license)

---

# 1. Project Overview

Matrix multiplication is a fundamental operation in many hardware-acceleration workloads.

This project implements matrix multiplication using a **systolic array architecture**, where multiple Processing Elements (PEs) operate concurrently while matrix operands move through the array in a regular dataflow pattern.

The design evolved through multiple stages:

```text
Signed MAC
    ↓
Processing Element
    ↓
2×2 Systolic Array
    ↓
FSM Controller
    ↓
Parameterized N×N Systolic Array
    ↓
Reusable RTL Accelerator
```

### Core computation

```text
A ∈ Z^(N×N)
B ∈ Z^(N×N)

C = A × B
```

Each output element is computed as:

```text
C[i][j] = Σ A[i][k] × B[k][j]
```

The hardware maps this computation spatially across an array of PEs.

---

# 2. Design Objectives

The project was designed to build practical understanding of:

- RTL design methodology
- Systolic array architecture
- Matrix-multiplication dataflow
- Hierarchical hardware design
- Parameterized Verilog
- Generate-based hardware replication
- FSM-based control
- Pipelined data movement
- Self-checking verification
- Hardware/software reference-model comparison

The emphasis is on understanding the architecture from the bottom up rather than starting directly with a large accelerator.

---

# 3. Project Evolution

## Version 1 — Signed MAC

The first implementation was a signed Multiply-Accumulate unit.

### Features

- Signed 8-bit operands
- 32-bit accumulator
- Enable control
- Clear control
- Synchronous operation

```text
A × B → Product → Accumulator
```

---

## Version 2 — Processing Element

The MAC was wrapped into a reusable **Processing Element (PE)**.

Each PE:

1. Multiplies incoming operands
2. Accumulates the partial result
3. Forwards operands to neighboring PEs

```text
             A_in
               │
               ▼
        ┌───────────────┐
B_in ──►│      MAC      │
        └───────────────┘
          │           │
        A_out       B_out
```

---

## Version 3 — Architecture Experiments

This stage involved internal design experiments and architecture refinements before moving to the fixed systolic-array implementation.

---

## Version 4 — 2×2 Systolic Array

Four PEs were connected to create the first complete systolic array.

### Implemented

- Horizontal propagation of matrix `A`
- Vertical propagation of matrix `B`
- Registered data movement
- Concurrent MAC operations
- Matrix multiplication using systolic dataflow

```text
              B ↓        B ↓
             ┌───┐      ┌───┐
A →          │PE │ ───→ │PE │
             └───┘      └───┘
               ↓          ↓
             ┌───┐      ┌───┐
A →          │PE │ ───→ │PE │
             └───┘      └───┘
```

---

## Version 5 — FSM Controller

An FSM-based controller was introduced to automate the streaming schedule.

### Controller states

```text
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

### Responsibilities

- Start matrix computation
- Generate the streaming sequence
- Control pipeline flushing
- Track computation progress
- Generate `busy` / `done` signalling
- Automate matrix multiplication

---

## Version 6 — Parameterized N×N Array

The fixed 2×2 implementation was generalized into a reusable parameterized architecture.

### Parameters

```verilog
parameter N = 8;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH = 32;
```

### Features

- Parameterizable matrix dimension
- Parameterizable operand width
- Parameterizable accumulator width
- Generate-loop PE instantiation
- Generic interconnection network
- Reusable N×N architecture

---

# 4. Architecture

The overall architecture consists of a controller and a parameterized computational array:

```text
                    ┌──────────────────────┐
                    │   FSM Controller     │
                    │      (Version 5)     │
                    └──────────┬───────────┘
                               │
                        Streaming Data
                               │
                               ▼
              ┌────────────────────────────────┐
              │     Parameterized N×N Array    │
              │            (Version 6)         │
              │                                │
              │   ┌────┐ ┌────┐      ┌────┐   │
              │   │ PE │ │ PE │  ... │ PE │   │
              │   └────┘ └────┘      └────┘   │
              │   ┌────┐ ┌────┐      ┌────┐   │
              │   │ PE │ │ PE │  ... │ PE │   │
              │   └────┘ └────┘      └────┘   │
              │    ...       ...        ...   │
              │   ┌────┐ ┌────┐      ┌────┐   │
              │   │ PE │ │ PE │  ... │ PE │   │
              │   └────┘ └────┘      └────┘   │
              └────────────────┬───────────────┘
                               │
                               ▼
                         Matrix Product C
```

### Data movement

```text
Matrix A
  → → → → →
  → → → → →
  → → → → →

Matrix B
  ↓ ↓ ↓ ↓ ↓
  ↓ ↓ ↓ ↓ ↓
  ↓ ↓ ↓ ↓ ↓

              ↓
        Partial Products
              ↓
        Accumulated Result
```

Each PE receives operands from its neighbors, performs a local MAC operation, and forwards the operands onward.

---

# 5. Processing Element

The Processing Element is the fundamental computational unit.

```text
                 A_in
                   │
                   ▼
              ┌─────────┐
B_in ────────►│   MAC   │
              │         │
              └─────────┘
                   │
              Partial Sum

A_out ─────────────────►

B_out ────────────────►
```

### PE responsibilities

| Function | Description |
|---|---|
| Multiply | Computes the signed product of `A` and `B` |
| Accumulate | Adds the product to the local partial sum |
| A propagation | Registers and forwards `A` to the right |
| B propagation | Registers and forwards `B` downward |

---

# 6. Systolic Dataflow

The key idea is **spatial reuse of operands**.

Instead of sending every matrix element independently to every multiplier, operands move through the array while each PE performs useful work.

```text
A → PE → PE → PE → PE
      ↓
B     PE → PE → PE
      ↓
      PE → PE → PE
      ↓
      PE → PE → PE
```

### Dataflow characteristics

- `A` propagates horizontally.
- `B` propagates vertically.
- Partial sums remain local to each PE.
- Neighboring PEs communicate through registered signals.
- Multiple MAC operations occur in parallel.

---

# 7. Streaming Schedule

For a 2×2 matrix multiplication, the implemented streaming schedule is:

### Cycle 0

```text
A = [a00  0]
B = [b00  0]
```

### Cycle 1

```text
A = [a01 a10]
B = [b10 b01]
```

### Cycle 2

```text
A = [ 0  a11]
B = [ 0  b11]
```

### Cycle 3

```text
A = [0 0]
B = [0 0]
```

The zero padding allows operands to enter the array at the appropriate time and lets the pipeline naturally flush.

The same principle is used when extending the architecture to larger parameterized arrays.

---

# 8. Parameterized Design

The array is generated using Verilog parameters and generate constructs.

```verilog
parameter N = 8;
parameter DATA_WIDTH = 8;
parameter ACC_WIDTH = 32;
```

| Parameter | Purpose |
|---|---|
| `N` | Matrix / systolic-array dimension |
| `DATA_WIDTH` | Width of signed input operands |
| `ACC_WIDTH` | Width of accumulated matrix products |

### Example scaling

```text
N = 2  →  2×2 array  →   4 PEs
N = 4  →  4×4 array  →  16 PEs
N = 8  →  8×8 array  →  64 PEs
```

The same RTL structure can therefore be elaborated for different array sizes and data widths.

---

# 9. Controller

The controller coordinates the computation around the systolic datapath.

```text
              start
                │
                ▼
             ┌──────┐
             │ IDLE │
             └──┬───┘
                │
                ▼
             ┌──────┐
             │CLEAR │
             └──┬───┘
                │
                ▼
          ┌────────────┐
          │ STREAMING  │
          │  STATES    │
          └─────┬──────┘
                │
                ▼
             ┌──────┐
             │ WAIT │
             └──┬───┘
                │
                ▼
             ┌──────┐
             │ DONE │
             └──────┘
```

### Controller responsibilities

- Accept computation start
- Clear accumulated state
- Schedule operand streaming
- Maintain pipeline timing
- Wait for data propagation to complete
- Assert completion

> **Current limitation:** the controller is based on the implemented streaming sequence. A fully generic controller that automatically derives the schedule for arbitrary `N` is planned work.

---

# 10. Verification

A reusable **self-checking testbench** was developed for the parameterized array.

### Verification flow

```text
             Reset DUT
                │
                ▼
          Load Matrices
                │
                ▼
       Software Golden Model
                │
                ▼
        Stream Data to DUT
                │
                ▼
       Capture RTL Results
                │
                ▼
      Compare C_RTL vs C_GOLDEN
                │
          ┌─────┴─────┐
          ▼           ▼
        PASS          FAIL
```

### Automated checks

The testbench:

- Loads input matrices
- Computes a software matrix-multiplication reference
- Streams operands into the DUT
- Collects the hardware result
- Compares RTL outputs against the golden result
- Reports `PASS` / `FAIL`

This makes verification repeatable instead of relying only on manual waveform inspection.

---

# 11. Technologies Used

| Tool / Technology | Purpose |
|---|---|
| Verilog HDL | RTL implementation |
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform inspection |
| VS Code | RTL development |

---

# 12. Repository Structure

```text
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

The versioned RTL structure preserves the evolution from the original MAC to the final parameterized array.

---

# 13. Current Status

| Component | Status |
|---|---|
| Signed MAC | ✅ Complete |
| Processing Element | ✅ Complete |
| 2×2 Systolic Array | ✅ Complete |
| FSM Controller | ✅ Complete |
| Parameterized N×N Array | ✅ Complete |
| Self-checking Testbench | ✅ Complete |
| Golden-model Verification | ✅ Complete |
| Generic parameterized controller | 🔄 Planned |
| External memory interface | 🔄 Planned |
| AXI-Stream interface | 🔄 Planned |
| SystemVerilog assertions | 🔄 Planned |
| UVM verification | 🔄 Planned |

---

# 14. Design Trade-offs

### Parallelism vs. Hardware Cost

Increasing `N` increases the number of Processing Elements approximately as:

```text
Number of PEs = N²
```

Larger arrays therefore provide more parallel MAC resources while requiring more hardware.

### Throughput vs. Area

Replicating PEs enables concurrent multiply-accumulate operations, but increases the number of multipliers, accumulators, registers, and interconnect resources.

### Parameterization vs. Controller Complexity

A parameterized array improves reuse, but a completely generic streaming controller requires additional scheduling logic compared with the current fixed streaming sequence.

### Local Communication

The systolic architecture primarily uses nearest-neighbor communication between PEs, creating a regular dataflow structure.

---

# 15. Future Improvements

## Architecture

- Generic parameterized streaming controller
- External SRAM / BRAM interface
- Tile-based matrix multiplication
- Multi-matrix batching
- Larger configurable array sizes

## Interfaces

- AXI-Stream input/output interface
- Memory-mapped accelerator interface

## Verification

- SystemVerilog assertions
- Constrained-random verification
- Functional coverage
- UVM-based verification

## Performance Analysis

- Cycle-count instrumentation
- Performance counters
- Throughput measurements
- Resource / area analysis after synthesis
- Comparison across different `N`, `DATA_WIDTH`, and `ACC_WIDTH` configurations

---

# 16. Learning Outcomes

This project provided practical experience with:

- RTL design methodology
- Hierarchical hardware design
- Signed arithmetic
- Multiply-Accumulate datapaths
- Processing Element design
- Parameterized Verilog
- Generate constructs
- Finite State Machines
- Pipelined data movement
- Systolic array architectures
- Dataflow scheduling
- Self-checking testbenches
- Golden-model verification
- Matrix multiplication hardware implementation

---

# 17. Interview Talking Points

### RTL Design

**Why start with a MAC?**

The MAC is the fundamental arithmetic operation of the matrix-multiplication datapath. Building it first allowed the Processing Element and systolic array to be constructed hierarchically.

### Architecture

**Why use a systolic array?**

The architecture allows matrix operands to move through a regular network of PEs while each PE performs local computation, enabling spatial parallelism and operand reuse.

### Dataflow

**How do operands move through the array?**

Matrix `A` propagates horizontally while matrix `B` propagates vertically. Each PE performs a local multiply-accumulate operation and forwards operands to neighboring PEs.

### Control

**Why is an FSM required?**

The FSM generates the streaming schedule, clears the array, manages pipeline timing, and determines when the computation has completed.

### Verification

**How was the accelerator verified?**

A software matrix-multiplication implementation acts as the golden reference. The testbench streams the same matrices into the RTL and compares the resulting matrix element-by-element.

### Parameterization

**What changes when `N` increases?**

The same RTL structure is elaborated into a larger array using generate constructs. The number of PEs scales as `N²`, while streaming and control requirements also grow with array dimension.

---

# 18. License

This project is released under the **MIT License**.
