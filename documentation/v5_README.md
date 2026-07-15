================================================================
 DESIGN JOURNEY
 v5 Systolic Array Controller
================================================================
FSM-based operand scheduler for a 2x2 systolic array -- from a
broken first assumption to a verified, timing-correct controller.

  REVISION ..... v5
  ARRAY SIZE ... 2 x 2
  STATUS ....... Verified


----------------------------------------------------------------
1. OBJECTIVE
----------------------------------------------------------------
Build an FSM-based controller that feeds a 2x2 systolic array
with the correct operand schedule for matrix multiplication --
driving the PE grid's inputs, tracking completion, and flushing
the pipeline cleanly.


----------------------------------------------------------------
2. THE JOURNEY
----------------------------------------------------------------
This design went through two real attempts. The first one looked
reasonable, passed a basic sanity check, and was wrong for a
reason that only became clear under a waveform viewer. The
second one is what's running today.

--- Attempt 1 -- The Timing-First Assumption --------------------

The initial design used the sequence below, on the assumption
that the bug -- whatever it turned out to be -- was a timing
problem: not enough cycles for data to propagate through the
array.

  IDLE -> CLEAR -> STREAM0 -> WAIT0 -> STREAM1 -> WAIT1 -> DONE

  [ WHY IT WAS WRONG ]
  The bug was not insufficient waiting time -- it was incorrect
  operand scheduling.

  PE01 and PE10 need operands arriving from different directions
  in the same cycle. No amount of extra WAIT states can fix
  operands that are misaligned to begin with.

--- The Turning Point --------------------------------------------

Adding WAIT states treated the symptom, not the cause. Systolic
arrays are timing-driven architectures in a stricter sense than
"wait longer" implies -- every PE needs the right operand on the
right cycle, from the right direction, or the array computes
garbage regardless of how long it's given to settle. That
reframing is what led to rebuilding the schedule itself instead
of the wait logic around it.

--- Attempt 2 -- Fixing the Schedule, Not the Delay --------------

The corrected design replaces the WAIT/STREAM alternation with an
explicit, cycle-accurate stream of operand pairs. Each cycle
below is (a-row-input, a-col-input, b-row-input, b-col-input)
feeding the array's edges:

  Cycle   PE(row,col) inputs -- a / b
  -----   ----------------------------
    0     (a00, 0, b00, 0)
    1     (a01, a10, b10, b01)
    2     (0, a11, 0, b11)
    3     (0, 0, 0, 0)

The final FSM reflects this directly -- one state per cycle of
the schedule, rather than generic stream/wait pairs:

  IDLE -> CLEAR -> STREAM0 -> STREAM1 -> STREAM2 -> STREAM3
       -> WAIT -> DONE


----------------------------------------------------------------
3. CONTROLLER RESPONSIBILITIES
----------------------------------------------------------------
  - Clear accumulators before a new matrix multiply begins
  - Generate the cycle-accurate operand stream shown above
  - Drive enable, busy, and done handshake signals
  - Flush the pipeline fully before signaling completion


----------------------------------------------------------------
4. VERIFICATION
----------------------------------------------------------------
Once the schedule was fixed, verification focused on proving it
held across the cases that would expose alignment errors, not
just "does it produce roughly the right numbers."

  Test case                        Purpose
  --------------------------       ------------------------------
  Positive matrix multiplication   Baseline correctness
  Zero matrix                      Confirms clean accumulator
                                    clear
  Identity matrix                  Isolates pass-through operand
                                    routing
  Signed arithmetic                Checks sign handling through
                                    the PEs
  Boundary values (+127 / -127)    Checks saturation / overflow
                                    behavior at range edges

  - Used GTKWave to step through operand propagation
    cycle-by-cycle and confirm alignment
  - Deliberately separated controller bugs from datapath bugs
    before debugging either
  - Built a self-checking testbench using tasks, verified against
    all cases above


----------------------------------------------------------------
5. MISTAKES AND LEARNINGS
----------------------------------------------------------------
  [ WHAT I'D TELL MYSELF AT THE START ]

  "It's not working" is not the same as "it needs more time."
  Adding WAIT states was the fastest lever to pull, but it was
  solving the wrong problem -- the real fix required re-deriving
  the schedule.

  Systolic arrays are timing-driven architectures: correctness
  lives in per-cycle operand alignment, not in total elapsed
  cycles.

  Separating controller bugs from datapath bugs early made
  root-causing far faster once I stopped assuming it was one or
  the other.

  A self-checking testbench across varied cases (zero, identity,
  signed, boundary) caught issues a single "happy path" test
  would have missed.


----------------------------------------------------------------
6. FUTURE WORK
----------------------------------------------------------------
  - Parameterize array size to NxN instead of fixed 2x2
  - Add a memory / AXI interface for streaming operands from
    external memory
  - Support continuous streaming (back-to-back matrix multiplies
    without a full drain)
  - Add configurable data width
