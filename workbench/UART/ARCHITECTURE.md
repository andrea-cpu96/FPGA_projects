# UART — Architecture Document

> **Living document** — updated continuously as the design progresses.
> Target device: Intel Cyclone IV E **EP4CE6E22C8** · Quartus Prime **20.1.0 Lite**
> HDL: VHDL (project registers `UART.vhd`, top-level entity `UART`)

**Status legend:** ✅ defined · 🚧 placeholder / to be defined · 💡 proposed (not yet confirmed)

---

## 1. System Overview

Classic UART link implemented as two independent blocks under one top-level module:

- **Transmitter (TX)** — converts parallel data into a serial frame and drives the `tx` line.
- **Receiver (RX)** — deserializes the incoming `rx` line back into parallel data.

### 1.1 Module hierarchy

```
UART (top level)
│
├── TX (Transmitter)
│   ├── P2S   — Parallel-to-Serial Converter
│   ├── BRG   — Baud Rate Generator
│   ├── SSBG  — Start/Stop Bit Generator
│   └── BRSG  — Busy/Ready Signal Generator
│
└── RX (Receiver)                🚧 structure to be defined
```

---

## 2. Module Map

| Module | Full name | Parent | Role (one line) | Status |
|---|---|---|---|---|
| `UART` | Top-level wrapper | — | Clock/reset distribution, TX/RX instantiation, external interface | ✅ skeleton |
| `TX` | Transmitter | `UART` | Serializes parallel data into an 8N1 frame on `tx` | ✅ broken into 4 blocks |
| `P2S` | Parallel-to-Serial Converter | `TX` | Shifts 8-bit parallel data out LSB-first, one bit per baud tick | ✅ defined |
| `BRG` | Baud Rate Generator | `TX` | Divides the system clock to produce the baud-rate tick | ✅ defined |
| `SSBG` | Start/Stop Bit Generator | `TX` | Frames the data stream with start (0) and stop (1) bits | ✅ defined |
| `BRSG` | Busy/Ready Signal Generator | `TX` | Handshake/status: reports when TX is busy or ready to accept data | ✅ defined |
| `RX` | Receiver | `UART` | Deserializes `rx` into parallel data | 🚧 to be defined |

### 2.1 Source files

| File | Module | Status |
|---|---|---|
| `UART.vhd` | `UART` (top) | 🚧 empty stub (clk/rst only) |
| `UART_TX.vhd` | `UART_TX` (TX top; instantiates BRG + P2S) | 🚧 placeholder created, code pending |
| `baudrate_gen.vhd` | `baudrate_gen` (BRG) | 🚧 **template added & registered in `.qsf`** — entity `baudrate_gen` (clk, rst), code pending |
| `parallel_to_serial.vhd` | `parallel_to_serial` (P2S) | 🚧 placeholder created, code pending |

> NOTE: registered so far: `baudrate_gen.vhd`. Still to register in `UART.qsf` when code lands:
>
> ```tcl
> set_global_assignment -name VHDL_FILE UART_TX.vhd
> set_global_assignment -name VHDL_FILE parallel_to_serial.vhd
> ```

---

## 3. Top-Level Module — `UART`

Wraps TX and RX and owns the external interface.

### 3.1 External interface

| Signal | Dir | Width | Description | Status |
|---|---|---|---|---|
| `clk` | in | 1 | System clock | ✅ in current stub |
| `rst` | in | 1 | Reset (sync vs async policy TBD) | ✅ in current stub |
| `tx` | out | 1 | Serial transmit line to the external UART device | 💡 expected |
| `rx` | in | 1 | Serial receive line from the external UART device | 💡 expected |
| `data_in[7:0]` | in | 8 | Parallel data byte to transmit | 💡 proposed — could also be internal (test pattern / FIFO) |
| `data_valid` | in | 1 | Pulse telling TX to load `data_in` and start | 💡 proposed |
| `tx_busy` / `tx_ready` | out | 1 | TX status (from BRSG) | 💡 proposed |
| `data_out[7:0]` | out | 8 | Received byte | 🚧 with RX |

> NOTE: `UART.vhd` currently contains only the empty `clk`/`rst` stub — the interface above will be filled in as the blocks get implemented.
>
> **Generics (planned):** `G_CLK_FREQ` / `G_BAUD` are declared on the top entity `UART` and propagated down via `generic map` — `UART_TX` (and later `RX`) compute derived values locally (e.g. the BRG `divider = G_CLK_FREQ / G_BAUD`).

---

## 4. Transmitter (TX)

Serializes an 8-bit byte into a standard 8N1 frame (start bit, 8 data bits LSB-first, stop bit) at the configured baud rate.

### 4.1 Internal block diagram

```
                ┌─────────────────── Transmitter (TX) ───────────────────┐
                │                                                        │
data[7:0] ─────►│ ┌───────┐  serial bit  ┌────────┐                      │
data_valid ────►│ │  P2S  ├─────────────►│  SSBG  ├── tx ────────────────┼──► to top level
                │ └───▲───┘              └───▲────┘  (framed serial out) │
                │     │                      │                           │
                │     │      baud_tick       │ framing control           │
                │     │           ┌──────────┴───┐                       │
                │     └───────────┤     BRG      │◄── clk                │
                │                 └──────────────┘                       │
                │ ┌───────┐                                              │
                │ │ BRSG  ├── tx_busy / tx_ready ────────────────────────►│──► to top level
                │ └───▲───┘                                              │
                │     └── TX state (shift register / frame counters)       │
                └─────────────────────────────────────────────────────────┘
```

### 4.2 P2S — Parallel-to-Serial Converter

**Purpose:** loads the 8-bit data byte on `data_valid`, then shifts it out one bit per baud tick, LSB first (standard UART bit order).

| Signal | Dir | Width | Description |
|---|---|---|---|
| `clk`, `rst` | in | 1 | Clock / reset |
| `data[7:0]` | in | 8 | Byte to serialize |
| `load` / `data_valid` | in | 1 | Load byte and start shifting |
| `baud_tick` | in | 1 | Advance one bit (from BRG) |
| `bit_out` | out | 1 | Current data bit, to SSBG |
| `done` | out | 1 | All 8 bits shifted out (frame position info) |

Implementation hint: 8-bit shift register + 3-bit bit counter; idle value of `bit_out` is resolved by SSBG framing.

### 4.3 BRG — Baud Rate Generator

**Purpose:** divides the system clock to generate a single-cycle `baud_tick` pulse at the configured baud rate; paces every TX block.

**Actual interface (as implemented in `baudrate_gen.vhd`):**

| Signal | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | System clock |
| `rst_n` | in | 1 | Reset, **active-low** |
| `divider` | in | integer (unconstrained) | Tick period in clock cycles; baud = `CLK_FREQ / divider`. TODO: constrain (e.g. `natural range 0 to 65535`) |
| `baud_tick` | out | 1 | One-clock-wide pulse every `divider` cycles |

Implementation notes: the counter runs `0 … divider-1`, so the tick period is exactly `divider` clock cycles → use `divider = CLK_FREQ / BAUD` (e.g. 50 MHz / 115200 = 433 → 115.47 kBd, +0.24 % error, well within UART tolerance). Free-running (no frame gating). Reset is written async-style but the sensitivity list is `clk` only, so it currently behaves as a *synchronous* reset — settle this in decision #5.

---

### 4.4 SSBG — Start/Stop Bit Generator

**Purpose:** builds the framed output: drives `tx` low for one baud period (start bit = 0), passes the 8 data bits through unchanged, then drives `tx` high for one baud period (stop bit = 1). Line idles high.

| Signal | Dir | Width | Description |
|---|---|---|---|
| `bit_in` | in | 1 | Data bit from P2S |
| `baud_tick` | in | 1 | Bit timing (from BRG) |
| frame-phase control | in | — | Start/stop insertion control (from TX sequencer or P2S `done`) — exact form TBD |
| `tx` | out | 1 | Framed serial output |

### 4.5 BRSG — Busy/Ready Signal Generator

**Purpose:** status/handshake block. `tx_ready = 1` (equivalently `tx_busy = 0`) when TX can accept a new byte; `tx_busy = 1` for the entire frame (start bit through stop bit). Prevents the upstream logic from overwriting the shift register mid-frame.

| Signal | Dir | Width | Description |
|---|---|---|---|
| TX state inputs | in | — | Frame/bit counters or `load`/`done` events — exact form TBD |
| `tx_busy` | out | 1 | 1 while a frame is being transmitted |
| `tx_ready` | out | 1 | 1 when idle and able to accept new data (typically `NOT tx_busy`) |

### 4.6 TX frame format (8N1)

```
        idle   start   b0   b1   b2   b3   b4   b5   b6   b7   stop   idle
 line: ─────┐      ┌────┐                                 ┌─────────┐     ┌──────
            └──────┘    └─────────────────────────────────┘         └─────┘
             (1)    (0)   LSB ───────────────────────── MSB           (1)   (1)
```

Parity and extra stop bits: not planned for v1 — TBD.

### 4.7 Transmit sequence

1. **Idle:** `tx = 1`, `tx_ready = 1`.
2. Upstream asserts `data_valid` with `data[7:0]` → P2S loads the byte; BRSG drops `tx_ready` (asserts `tx_busy`).
3. SSBG drives the **start bit** (0) for one baud period.
4. P2S shifts out **D0…D7 (LSB first)**, one bit per baud tick.
5. SSBG drives the **stop bit** (1) for one baud period.
6. BRSG re-asserts `tx_ready`; back to step 1.

---

## 5. Receiver (RX) — 🚧 to be defined

Mirror image of TX: watches `rx` for the falling edge (start bit), samples the middle of each bit period, and reassembles the byte.

**Suggested blocks (💡 mirror of TX — pending your definition):**

| Candidate | TX counterpart | Role |
|---|---|---|
| S2P (Serial-to-Parallel) | P2S | Shift in 8 bits, present byte on `data_out` |
| BRG (shared or separate) | BRG | Baud tick; RX usually needs a mid-bit sampling scheme (e.g., 16× oversampling) |
| Start-bit detector | SSBG | Falling-edge detection + mid-start-bit validity check (glitch filter) |
| Data-valid / error generator | BRSG | `data_valid` pulse + flags (framing error, overrun) |

**Decisions to make:** oversampling factor, shared vs. separate BRG, error flags, glitch filtering on `rx`.

---

## 6. Open Design Decisions

| # | Topic | Options / notes | Status |
|---|---|---|---|
| 1 | System clock frequency | 50 MHz typical for EP4CE6 boards — confirm | 🚧 |
| 2 | Target baud rate(s) | 9600 / 115200 …; fixed or runtime-configurable | 🚧 |
| 3 | BRG divider | ✅ runtime input `divider : integer`, free-running; baud = CLK_FREQ / divider. Open: constrain to `natural range` instead of unconstrained integer | 🚧 |
| 4 | Frame format | 8N1 fixed, or configurable data bits / parity / stop bits | 🚧 |
| 5 | Reset style | Active-low `rst_n` chosen for BRG/TX; async vs. sync semantics still to settle | 🚧 |
| 6 | Data source/sink | External pins, internal test pattern, FIFO, loopback test | 🚧 |
| 7 | RX sampling strategy | Straight baud tick vs. 16× oversampling | 🚧 |
| 8 | HDL for all modules | Project currently registers `UART.vhd` (VHDL) — confirm | 🚧 |
| 9 | Parameter propagation | ✅ `G_CLK_FREQ` / `G_BAUD` generics declared on top entity `UART`, passed down via `generic map`; derived values (BRG `divider`) computed in `UART_TX` from the generics, not duplicated per level | 🚧 |

---

## 7. Verification

### 7.1 baudrate_gen — testbench `sim_baudrate/baudrate_gen_tb.vhd` (simulation-only, intentionally **not** registered in `.qsf`)

Self-checking TB; monitors on rising edges (same sampling convention as the DUT) and verifies:

- **Tick period** == `divider` clock cycles (tick-to-tick)
- **Reset alignment** — first tick arrives exactly `divider + 1` edges after the last reset edge
- **Pulse width** == 1 clock cycle (for `divider >= 2`)
- **Re-alignment after a mid-run reset**, repeated for `divider = 4, 10, 433` (115200 Bd @ 50 MHz) `and 5208` (9600 Bd)
- `divider = 1` / `divider = 0` intentionally **not** tested (continuous tick / hang — see §6, decision 3)

Two ways to run the TB:

- **GUI (normal flow):** open `sim_baudrate.mpf` → `Compile → Compile All` → `Simulate → Start Simulation…` → `work.baudrate_gen_tb` (Optimization tab: uncheck *Enable optimization*) → in the **Objects** window select `clk`, `rst_n`, `divider`, `baud_tick` (plus `dut/counter`, `dut/baud`) → right-click → **Add to Wave** → `run 500 ns`, then `run -all`; drag-select a region on the wave to zoom. **Add the signals *before* running** — ModelSim only records what is already in the Wave window.
- **Command line:** `vsim -c -do sim_run.do` (compiles the DUT from `../baudrate_gen.vhd` + the local TB, runs, prints the PASS/FAIL verdict).

**Status:** ✅ **PASSED** — executed 2026-09-04 with ModelSim ASE (440,320 ns simulated, 1 s wall time): `BRG TEST PASSED — 42 ticks checked, 0 errors, 0 warnings`. Note: the VC++ 2013 x86 runtime (`msvcr120.dll` / `msvcp120.dll`) had to be installed first — ModelSim ASE does not launch without it. **Re-verified after moving everything into `sim_baudrate/`: PASS — 42 ticks, 0 errors.**

Manual desk-check of the DUT trace (`divider = 4`): sampled ticks at edges 5, 9, 13 … → period = 4 = `divider`, pulse = 1 cycle ✓ — consistent with the TB expectations.

---

## 8. Changelog

| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-09-04 | Initial skeleton from module list: top-level + TX blocks (P2S, BRG, SSBG, BRSG); RX placeholder |
| 0.2 | 2026-09-04 | Created placeholder source files `UART_TX.vhd`, `baudrate_gen.vhd`, `parallel_to_serial.vhd`; added §2.1 source-file map |
| 0.3 | 2026-09-04 | BRG template added (entity `baudrate_gen`, clk/rst); registered `baudrate_gen.vhd` in `UART.qsf`; validated via Analysis & Elaboration |
| 0.4 | 2026-09-04 | BRG first implementation (runtime `divider` input, active-low `rst_n`, `baud_tick` out); §4.3 updated to actual interface; UART_TX instantiation guidance |
| 0.5 | 2026-09-04 | Decision #9: clock/baud configuration provided from top (`UART`) as generics `G_CLK_FREQ`/`G_BAUD`, propagated via generic map; `divider` derived in `UART_TX` |
| 0.6 | 2026-09-04 | Added self-checking testbench `baudrate_gen_tb.vhd` (+ `sim_run.do`); added §7 Verification; local ModelSim run blocked by missing VC++ 2013 x86 runtime |
| 0.7 | 2026-09-04 | Installed VC++ 2013 x86 runtime (missing `msvcr120.dll`/`msvcp120.dll`); executed `baudrate_gen_tb` in ModelSim: **PASS — 42 ticks checked, 0 errors** |
| 0.8 | 2026-09-04 | Organized simulation into `sim_baudrate/` (TB, `sim_run.do`, `work`, `.mpf`); cleaned root artifacts; re-ran from new location: **PASS — 42 ticks, 0 errors** |



