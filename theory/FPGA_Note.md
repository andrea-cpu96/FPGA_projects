# FPGA VHDL COURSE

## 1. Necessary Tools
- **FPGA Altera Cyclone IV**: developer board with many peripherals available.  
- **USB Blaster**: external module needed to program the FPGA.  
- **Intel Quartus software**: development tool to program FPGAs.  

---

## 2. Installing Quartus
- **Quartus 20.1**  
- **Quartus Prime**: installation file for Quartus IDE.  
- **ModelSim-Intel**: installation file for simulating FPGA on PC.  
- **Cyclone IV device support**: installation file for specific FPGA family support.  

---

## 3. FPGA Fundamentals
- **Definition**: FPGA = Field Programmable Gate Array, an array of logic gates programmable many times.  
- **Built-in blocks**: logic gates, registers, configurable routing, configurable blocks, memories, PLLs, DSP, and others.  

### CLB (Configurable Logic Block)
- All FPGAs are made of logic and registers. These components form CLBs, the main basic block of FPGAs.  
- Elements inside a CLB:  
  - **LUT (Look-Up Table)**: implements combinational logic.  
  - **D-Flip-Flop**: includes clock and reset input.  
  - **MUX**: acts as a switch to select which output goes outside the CLB.  

### Other Cells
- **IO cell**: input/output pins.  
- **PLL cell**: used for clock scaling.  
- **RAM cell**: volatile memories.  

### Architecture
- CLBs connected to other blocks (including other CLBs).  
- **Programmable Routing**: connections between blocks are configurable.  

### Advantages
- Custom digital circuits.  
- More peripherals, customizable as needed.  
- Parallel logic and higher speeds compared to processors.  
- Overcome processor limits (e.g., 64-bit buses).  
- Useful for extensive data processing.  

---

## 4. VHDL and RTL
- **Languages**: FPGA programming via VHDL or Verilog.  
- **VHDL**: verbose but deterministic, preferred for safety-critical applications.  
- **RTL (Register Transfer Level)**: synthesizable VHDL code describing registers and combinational logic.  
- **Behavioral code**: non-synthesizable, used for simulation.  

---

## 5. FPGA Design Flow
1. Start from design specification (Requirement Specifications).  
2. Write RTL code and Test-Bench (RTL + Behavioral).  
3. Define timing constraints.  
4. Synthesize with synthesis tool → Netlist.  
5. Implementation tool → placement, routing, optimization.  
6. Verify timing under all conditions.  
7. Generate binary file for FPGA configuration.  
8. Store binary in external flash attached to FPGA chip.  
9. Program flash via JTAG programmer (Intel USB Blaster).  
10. FPGA reads flash automatically at power-up.  

---

## 6. VHDL Basics

### Signals
- **Definition**:  
  `signal signal_name : data_type := initial_val;`  
  *(initial value runs only in simulation)*  
- **Assignment**:  
  `signalA <= signalB;`  
 
### Data Types
- **bit**  
  `signal a : bit := '1';`  

- **boolean**  
  `signal b : boolean := true;`  

- **integer**  
  `signal c : integer := 42;`  

- **real**  
  `signal d : real := 3.14;`  

- **character**  
  `signal e : character := 'A';`  

- **string**  
  `signal f : string := "CIAO";`  

- **bit_vector**  
  `signal g : bit_vector(3 downto 0) := "1010";`  

- **std_logic**  
  `signal h : std_logic := '0';`  

- **std_ulogic**  
  `signal hu : std_ulogic := '1';`  

- **std_logic_vector**  
  `signal i : std_logic_vector(7 downto 0) := "11001100";`  

- **signed**  
  `signal j : signed(7 downto 0) := "10011011";`  

- **unsigned**  
  `signal k : unsigned(7 downto 0) := "01010101";`  

- **time**  
  `signal l : time := 10 ns;`  

- **natural**  
  `signal m : natural := 100;`  

- **positive**  
  `signal n : positive := 7;`  

---

### Enumeration
```vhdl
type state_t is (IDLE, RUN, DONE);
signal s : state_t := IDLE;
```

---

### Subtypes
```vhdl
subtype small_nat is natural range 0 to 15;
signal sn : small_nat := 10;

subtype byte_t is std_logic_vector(7 downto 0);
signal bv : byte_t := x"AA";

subtype nat_t is integer range 0 to integer'high;
signal n : nat_t := 42;

subtype pos_t is integer range 1 to integer'high;
signal p : pos_t := 7;

subtype small_int is integer range 0 to 15;
signal si : small_int := 10;

subtype byte_t is std_logic_vector(7 downto 0);
signal b : byte_t := x"AA";

subtype word_t is std_logic_vector(15 downto 0);
signal w : word_t := x"1234";

subtype flag_t is boolean;
signal f : flag_t := true;

subtype short_delay is time range 0 ns to 100 ns;
signal td : short_delay := 50 ns;

subtype nibble_t is std_logic_vector(3 downto 0);
signal nb : nibble_t := "1010";
```

---

### Arrays
```vhdl
type int_array is array (0 to 3) of integer;
signal ia : int_array := (1, 2, 3, 4);

type bool_array is array (0 to 1) of boolean;
signal ba : bool_array := (true, false);

type sl_array is array (0 to 2) of std_logic;
signal sla : sl_array := ('0', '1', 'Z');

type matrix is array (0 to 1, 0 to 1) of integer;
signal mat : matrix := ((1,2),(3,4));
```

---

### Records
```vhdl
type point is record
  x : integer;
  y : integer;
end record;
signal p : point := (x => 10, y => 20);

type mixed_reg is record
  flag : boolean;
  val  : integer;
end record;
signal mr : mixed_reg := (flag => true, val => 42);

type logic_reg is record
  bit_a : std_logic;
  bit_b : std_logic_vector(3 downto 0);
end record;
signal lr : logic_reg := (bit_a => '1', bit_b => "1010");

type inner is record
  a : integer;
  b : integer;
end record;
type outer is record
  id   : natural;
  data : inner;
end record;
signal o : outer := (id => 1, data => (a => 5, b => 6));

type timed is record
  start : time;
  stop  : time;
end record;
signal t : timed := (start => 10 ns, stop => 20 ns);
```
---

# VHDL Operators

## 1. Arithmetic Operators
- **Addition (+)**  
  `signal sum : integer := 5 + 3;`

- **Subtraction (-)**  
  `signal diff : integer := 10 - 4;`

- **Multiplication (*)**  
  `signal prod : integer := 6 * 7;`

- **Division (/)**  
  `signal div : integer := 20 / 5;`

- **Modulus (mod)**  
  `signal r : integer := 17 mod 3; -- result = 2`

- **Remainder (rem)**  
  `signal r2 : integer := 17 rem 3; -- result = 2`

---

## 2. Relational Operators
- **Equal (=)**  
  `signal eq : boolean := (a = b);`

- **Not equal (/=)**  
  `signal ne : boolean := (a /= b);`

- **Less than (<)**  
  `signal lt : boolean := (a < b);`

- **Less than or equal (<=)**  
  `signal le : boolean := (a <= b);`

- **Greater than (>)**  
  `signal gt : boolean := (a > b);`

- **Greater than or equal (>=)**  
  `signal ge : boolean := (a >= b);`

---

## 3. Logical Operators
- **and**  
  `signal x : std_logic := '1' and '0';`

- **or**  
  `signal y : std_logic := '1' or '0';`

- **nand**  
  `signal z : std_logic := '1' nand '1';`

- **nor**  
  `signal w : std_logic := '0' nor '0';`

- **xor**  
  `signal v : std_logic := '1' xor '0';`

- **xnor**  
  `signal u : std_logic := '1' xnor '1';`

- **not**  
  `signal n : std_logic := not '1';`

---

## 4. Shift Operators
- **sll (shift left logical)**  
  `signal sl : bit_vector(3 downto 0) := "1010" sll 1;`

- **srl (shift right logical)**  
  `signal sr : bit_vector(3 downto 0) := "1010" srl 1;`

- **sla (shift left arithmetic)**  
  `signal sla_ex : signed(3 downto 0) := "1010" sla 1;`

- **sra (shift right arithmetic)**  
  `signal sra_ex : signed(3 downto 0) := "1010" sra 1;`

- **rol (rotate left)**  
  `signal rl : bit_vector(3 downto 0) := "1010" rol 1;`

- **ror (rotate right)**  
  `signal rr : bit_vector(3 downto 0) := "1010" ror 1;`

---

## 5. Concatenation Operator
- **& (concatenation)**  
  `signal concat : std_logic_vector(7 downto 0) := "1010" & "0101";`

---

## 6. Miscellaneous Operators
- **Exponentiation (**)**  
  `signal exp : integer := 2 ** 3; -- result = 8`
 
---

# Structure of a VHDL File (.vhd)

## 1. Library and Use Clauses
Every VHDL file begins with **library declarations** and **use clauses**.  
- **Libraries** are collections of packages. The most common is `IEEE`.  
- **Use clauses** import specific packages from a library, giving access to data types (`std_logic`, `signed`, `unsigned`) and functions.  

Example:
```vhdl
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
```
Without these, you cannot use standard logic types or arithmetic on vectors.

---

## 2. Entity Declaration
The **entity** defines the external interface of your design.  
- It is like the “black box” view: what inputs and outputs exist.  
- Inside the `port` section you declare signals with direction (`in`, `out`, `inout`) and type.  
- The entity does not describe behavior, only the interface.  

Example:
```vhdl
entity my_entity is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    data_in  : in  std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0)
  );
end my_entity;
```

---

## 3. Architecture Body
The **architecture** describes the internal implementation of the entity.  
- You can have multiple architectures for the same entity (e.g., one behavioral, one RTL).  
- Inside the architecture you can declare internal signals, constants, and components.  
- The architecture contains **concurrent statements** (executed in parallel) and **processes** (sequential code triggered by signals).  

Example:
```vhdl
architecture rtl of my_entity is
  signal temp : std_logic_vector(7 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      temp <= (others => '0');
    elsif rising_edge(clk) then
      temp <= data_in;
    end if;
  end process;

  data_out <= temp;
end rtl;
```
This architecture implements a simple register: on each clock edge, `data_in` is stored in `temp` and then sent to `data_out`.

---

## 4. Configuration (Optional)
A **configuration** specifies which architecture is bound to which entity.  
- Useful when you have multiple architectures and want to select one for synthesis or simulation.  
- Rarely used in small projects, but important in large designs.  

Example:
```vhdl
configuration cfg of my_entity is
  for rtl
  end for;
end cfg;
```

---

## 5. Package Declaration (Optional)
Packages allow you to define **reusable elements**: constants, types, functions, procedures.  
- They are like “header files” in other languages.  
- You can share packages across multiple entities/architectures.  

Example:
```vhdl
package my_pkg is
  constant DATA_WIDTH : integer := 8;
  type state_t is (IDLE, RUN, DONE);
end package my_pkg;
```

---

## 6. Package Body (Optional)
If your package declares functions or procedures, the **package body** contains their implementation.  

Example:
```vhdl
package body my_pkg is
  function add_one(x : integer) return integer is
  begin
    return x + 1;
  end function;
end package body my_pkg;
```

---

## 7. Testbench (Separate File)
A **testbench** is a special VHDL file used only for simulation.  
- It instantiates the entity under test (UUT = Unit Under Test).  
- Provides stimulus (input signals) and checks outputs.  
- Contains non-synthesizable code (e.g., `wait for 10 ns`).  

Example:
```vhdl
entity tb_my_entity is
end tb_my_entity;

architecture sim of tb_my_entity is
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal din   : std_logic_vector(7 downto 0);
  signal dout  : std_logic_vector(7 downto 0);
begin
  uut: entity work.my_entity(rtl)
    port map (
      clk => clk,
      reset => reset,
      data_in => din,
      data_out => dout
    );

  -- Clock generation
  clk <= not clk after 10 ns;

  -- Stimulus
  process
  begin
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    din <= "10101010";
    wait for 100 ns;
    wait;
  end process;
end sim;
```
---

# Process Block in VHDL

A **process block** in VHDL is a fundamental construct used to describe sequential behavior within an architecture. Unlike concurrent statements, which are executed in parallel, a process block executes its statements sequentially whenever an event occurs on one of the signals listed in its sensitivity list. The sensitivity list defines which signals trigger the process when they change value.

Inside a process, both variables and signals can be used. Variables update immediately within the process, while signals update after the process suspends. A process typically contains conditional statements such as `if` or `case`, making it suitable for modeling clocked logic, finite state machines, and complex sequential operations.

It is important to note that a process block can describe **synthesizable RTL logic** (registers and combinational circuits) or **non‑synthesizable behavioral logic** (simulation‑only constructs). The distinction depends entirely on how the process is written: if it uses clock edges and proper sensitivity lists, it represents RTL hardware; if it uses simulation‑only statements such as `wait for 10 ns`, it is behavioral and cannot be synthesized.


### Sequential Behavior Inside Processes (generalized)

All statements inside a `process` are executed sequentially in simulation: the process body (whether it contains `if`/`case`, `for`/`while` loops, assignments, or other statements) runs statement-by-statement whenever the process is triggered by its sensitivity list. This sequential execution model applies to the entire process body, not only to loops.

Important clarification: sequential execution in source code (simulation time) does not necessarily imply serial or time-stepped hardware. For combinational logic described inside a process (no clock edge), synthesis tools commonly translate the sequential description into parallel hardware — for example, unrolling loops into replicated gates or mapping a sequence of independent assignments to parallel logic.

Examples (combinational and sequential forms):

```vhdl
-- Combinational: sequential code that synthesizes to parallel logic
process(a_bus, b_bus)
begin
  for i in 0 to 2 loop
    y_bus(i) <= a_bus(i) and b_bus(i);
  end loop;
end process;

-- Sequential control and combinational calculation within the same process
process(clk, a, b)
begin
  if rising_edge(clk) then
    reg <= data_in; -- synchronous register
  else
    if a = '1' then
      tmp := b; -- variable assignment inside the process (immediate)
    else
      tmp := (others => '0');
    end if;
  end if;
end process;
```

Key points and rules:

- Execution vs hardware: the process body executes sequentially in simulation; synthesis interprets the behavior and typically maps combinational descriptions into parallel logic and sequential descriptions into registers/FSMs.
- Signals (`<=`) use signal-update semantics: assignments schedule updates visible after the process suspends (last-assignment-wins within the same process activation for the same signal).
- Variables (`:=`) update immediately and are useful for intermediate calculations or to avoid multiple signal updates; variables do not directly map to hardware unless assigned to signals.
- Loops are syntactic tools: combinational loops are usually unrolled by synthesis; synchronous loops (inside `rising_edge(clk)`) typically infer multiple registers or repeated logic based on the body of the loop.
- Always ensure combinational processes include all referenced inputs in the sensitivity list (or use `process(all)`) to avoid simulation/synthesis mismatches and unintended latches.

In short: the code inside a `process` is sequential in simulation, but synthesis will map that sequential description to the appropriate parallel or sequential hardware. The concept applies to all statements in the process, not just loops.

Brief summary: Although a `process` executes statements in order during simulation, that ordered source determines the hardware the synthesizer generates. If the same signal is assigned multiple times within one process activation, the last assignment determines the signal's value ("last-assignment-wins"). Variable assignments take effect immediately and can affect later statements in the same activation, while signal assignments schedule updates visible after the process suspends. Conditional chains using `if`/`elsif` (or chained `when-else`) are priority-based (first-true branch wins), whereas `with-select` and `case` express non-priority, parallel selection; prefer `case` for clear, non-priority multi-way selection. Write statement order and choice of constructs intentionally so the resulting hardware (registers, muxes, or parallel logic) matches your design intent.

## Register Processes
A **register process** is the most common type of process used in synchronous digital design. It models registers that store data on a clock edge.  
- The sensitivity list usually contains the **clock** and optionally a **reset** signal.  
- The process checks for a rising or falling edge of the clock.  
- On reset, the register is cleared; otherwise, on the clock edge, the register captures the input value.  

Example of a register process:
```vhdl
process(clk, reset)
begin
  if reset = '1' then
    q <= '0';
  elsif rising_edge(clk) then
    q <= d;
  end if;
end process;
```
This process models a D flip-flop with asynchronous reset. The output `q` is cleared when `reset` is active, otherwise it takes the value of `d` on each rising edge of `clk`. This is **synthesizable RTL code**.

## Using the Sensitivity List
The **sensitivity list** determines when the process is evaluated.  
- For **sequential logic (registers)**, include the clock and reset signals.  
- For **combinational logic**, include all input signals that affect the output.  
- If a signal is missing from the sensitivity list in combinational logic, simulation results may differ from synthesis, leading to unintended latches.  

Example of a combinational process:
```vhdl
process(a, b, sel)
begin
  if sel = '0' then
    y <= a;
  else
    y <= b;
  end if;
end process;
```
Here, the sensitivity list includes all inputs (`a`, `b`, `sel`) to ensure correct combinational behavior. This is also **synthesizable RTL code**.

---

In summary, a **process block** is a general construct that can describe either **RTL hardware** (registers and combinational logic, synthesizable) or **behavioral logic** (simulation‑only, non‑synthesizable). **Register processes** rely on clock and reset signals in the sensitivity list to model synchronous registers, while **combinational processes** must include all input signals to ensure correct synthesis and avoid unintended latches.

NOTE; different processes must not change the same output signal.

# Top-Level Entity and Components in VHDL

A **top-level entity** in VHDL represents the highest abstraction level of a design. It defines the external interface of the entire project, specifying all input and output ports that connect the FPGA design to the outside world. The top-level entity acts as the entry point for synthesis and implementation: when the design is compiled, this entity is the one mapped to the physical pins of the FPGA. Typically, it contains only the port declarations and does not describe internal behavior directly; instead, it instantiates lower-level modules (components) inside its architecture.

A **component** in VHDL is a reusable building block that represents another entity within the design. Components are declared in the architecture of the top-level entity (or in packages) and then instantiated to build hierarchical designs. Each component has its own entity and architecture, defining its interface and behavior. By instantiating components, the top-level entity connects them together using signals, creating a structured design where complex systems are built from smaller, manageable modules.

### Example
```vhdl
-- Top-level entity
entity TopLevel is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    sw    : in  std_logic_vector(2 downto 0);
    led   : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of TopLevel is
  -- Component declaration
  component StateMachineProject is
    port (
      clk   : in  std_logic;
      sw    : in  std_logic_vector(2 downto 0);
      led   : out std_logic_vector(2 downto 0)
    );
  end component;

  -- Internal signals
  signal sw_sig  : std_logic_vector(2 downto 0);
  signal led_sig : std_logic_vector(2 downto 0);

begin
  -- Component instantiation
  U1: StateMachineProject
    port map (
      clk => clk,
      sw  => sw_sig,
      led => led_sig
    );

  -- Connect outputs to top-level ports
  led <= led_sig;
  sw_sig <= sw;
end rtl;
```

In this example, the **TopLevel entity** defines the external interface of the design, while the **StateMachineProject component** is instantiated inside its architecture. The signals `sw_sig` and `led_sig` act as internal connections between the top-level ports and the component. This hierarchical approach allows complex FPGA designs to be organized into smaller, reusable modules, improving readability, maintainability, and scalability.
---

# FPGA I/O Buffers

---
I/O buffers are specialized circuits inside the FPGA that manage the interface between internal logic and external pins. They ensure electrical compatibility, protect the FPGA core, and enable reliable signal transmission. Common buffer types include input buffers (IBUF), which translate external signal levels to the FPGA core; output buffers (OBUF), which drive external pins with configurable drive strength and slew rate; and bidirectional buffers (IOBUF), which let a single pin act as input or output under control of an enable signal. Clock buffers (e.g., BUFG, BUFH, BUFR) distribute clock signals across the device with low skew. I/O buffers are configurable for many standards (LVCMOS, LVDS, SSTL, HSTL, etc.), allowing the FPGA to interface with diverse external devices. Correct I/O buffer configuration is essential for signal integrity and overall system reliability, particularly in mission‑critical applications.
---

# FPGA VHDL COURSE

## 1. Necessary Tools
- **FPGA Altera Cyclone IV**: developer board with many peripherals available.  
- **USB Blaster**: external module needed to program the FPGA.  
- **Intel Quartus software**: development tool to program FPGAs.  

---

## 2. Installing Quartus
- **Quartus 20.1**  
- **Quartus Prime**: installation file for Quartus IDE.  
- **ModelSim-Intel**: installation file for simulating FPGA on PC.  
- **Cyclone IV device support**: installation file for specific FPGA family support.  

---

## 3. FPGA Fundamentals
- **Definition**: FPGA = Field Programmable Gate Array, an array of logic gates programmable many times.  
- **Built-in blocks**: logic gates, registers, configurable routing, configurable blocks, memories, PLLs, DSP, and others.  

### CLB (Configurable Logic Block)
- All FPGAs are made of logic and registers. These components form CLBs, the main basic block of FPGAs.  
- Elements inside a CLB:  
  - **LUT (Look-Up Table)**: implements combinational logic.  
  - **D-Flip-Flop**: includes clock and reset input.  
  - **MUX**: acts as a switch to select which output goes outside the CLB.  

### Other Cells
- **IO cell**: input/output pins.  
- **PLL cell**: used for clock scaling.  
- **RAM cell**: volatile memories.  

### Architecture
- CLBs connected to other blocks (including other CLBs).  
- **Programmable Routing**: connections between blocks are configurable.  

### Advantages
- Custom digital circuits.  
- More peripherals, customizable as needed.  
- Parallel logic and higher speeds compared to processors.  
- Overcome processor limits (e.g., 64-bit buses).  
- Useful for extensive data processing.  

---

## 4. VHDL and RTL
- **Languages**: FPGA programming via VHDL or Verilog.  
- **VHDL**: verbose but deterministic, preferred for safety-critical applications.  
- **RTL (Register Transfer Level)**: synthesizable VHDL code describing registers and combinational logic.  
- **Behavioral code**: non-synthesizable, used for simulation.  

---

## 5. FPGA Design Flow
1. Start from design specification (Requirement Specifications).  
2. Write RTL code and Test-Bench (RTL + Behavioral).  
3. Define timing constraints.  
4. Synthesize with synthesis tool → Netlist.  
5. Implementation tool → placement, routing, optimization.  
6. Verify timing under all conditions.  
7. Generate binary file for FPGA configuration.  
8. Store binary in external flash attached to FPGA chip.  
9. Program flash via JTAG programmer (Intel USB Blaster).  
10. FPGA reads flash automatically at power-up.  

---

## 6. VHDL Basics

### Signals
- **Definition**:  
  `signal signal_name : data_type := initial_val;`  
  *(initial value runs only in simulation)*  
- **Assignment**:  
  `signalA <= signalB;`  

### Data Types
- **bit**  
  `signal a : bit := '1';`  

- **boolean**  
  `signal b : boolean := true;`  

- **integer**  
  `signal c : integer := 42;`  

- **real**  
  `signal d : real := 3.14;`  

- **character**  
  `signal e : character := 'A';`  

- **string**  
  `signal f : string := "CIAO";`  

- **bit_vector**  
  `signal g : bit_vector(3 downto 0) := "1010";`  

- **std_logic**  
  `signal h : std_logic := '0';`  

- **std_ulogic**  
  `signal hu : std_ulogic := '1';`  

- **std_logic_vector**  
  `signal i : std_logic_vector(7 downto 0) := "11001100";`  

- **signed**  
  `signal j : signed(7 downto 0) := "10011011";`  

- **unsigned**  
  `signal k : unsigned(7 downto 0) := "01010101";`  

- **time**  
  `signal l : time := 10 ns;`  

- **natural**  
  `signal m : natural := 100;`  

- **positive**  
  `signal n : positive := 7;`  

---

### Enumeration
```vhdl
type state_t is (IDLE, RUN, DONE);
signal s : state_t := IDLE;
```

---

### Subtypes
```vhdl
subtype small_nat is natural range 0 to 15;
signal sn : small_nat := 10;

subtype byte_t is std_logic_vector(7 downto 0);
signal bv : byte_t := x"AA";

subtype nat_t is integer range 0 to integer'high;
signal n : nat_t := 42;

subtype pos_t is integer range 1 to integer'high;
signal p : pos_t := 7;

subtype small_int is integer range 0 to 15;
signal si : small_int := 10;

subtype byte_t is std_logic_vector(7 downto 0);
signal b : byte_t := x"AA";

subtype word_t is std_logic_vector(15 downto 0);
signal w : word_t := x"1234";

subtype flag_t is boolean;
signal f : flag_t := true;

subtype short_delay is time range 0 ns to 100 ns;
signal td : short_delay := 50 ns;

subtype nibble_t is std_logic_vector(3 downto 0);
signal nb : nibble_t := "1010";
```

---

### Arrays
```vhdl
type int_array is array (0 to 3) of integer;
signal ia : int_array := (1, 2, 3, 4);

type bool_array is array (0 to 1) of boolean;
signal ba : bool_array := (true, false);

type sl_array is array (0 to 2) of std_logic;
signal sla : sl_array := ('0', '1', 'Z');

type matrix is array (0 to 1, 0 to 1) of integer;
signal mat : matrix := ((1,2),(3,4));
```

---

### Records
```vhdl
type point is record
  x : integer;
  y : integer;
end record;
signal p : point := (x => 10, y => 20);

type mixed_reg is record
  flag : boolean;
  val  : integer;
end record;
signal mr : mixed_reg := (flag => true, val => 42);

type logic_reg is record
  bit_a : std_logic;
  bit_b : std_logic_vector(3 downto 0);
end record;
signal lr : logic_reg := (bit_a => '1', bit_b => "1010");

type inner is record
  a : integer;
  b : integer;
end record;
type outer is record
  id   : natural;
  data : inner;
end record;
signal o : outer := (id => 1, data => (a => 5, b => 6));

type timed is record
  start : time;
  stop  : time;
end record;
signal t : timed := (start => 10 ns, stop => 20 ns);
```
---

# VHDL Operators

## 1. Arithmetic Operators
- **Addition (+)**  
  `signal sum : integer := 5 + 3;`

- **Subtraction (-)**  
  `signal diff : integer := 10 - 4;`

- **Multiplication (*)**  
  `signal prod : integer := 6 * 7;`

- **Division (/)**  
  `signal div : integer := 20 / 5;`

- **Modulus (mod)**  
  `signal r : integer := 17 mod 3; -- result = 2`

- **Remainder (rem)**  
  `signal r2 : integer := 17 rem 3; -- result = 2`

---

## 2. Relational Operators
- **Equal (=)**  
  `signal eq : boolean := (a = b);`

- **Not equal (/=)**  
  `signal ne : boolean := (a /= b);`

- **Less than (<)**  
  `signal lt : boolean := (a < b);`

- **Less than or equal (<=)**  
  `signal le : boolean := (a <= b);`

- **Greater than (>)**  
  `signal gt : boolean := (a > b);`

- **Greater than or equal (>=)**  
  `signal ge : boolean := (a >= b);`

---

## 3. Logical Operators
- **and**  
  `signal x : std_logic := '1' and '0';`

- **or**  
  `signal y : std_logic := '1' or '0';`

- **nand**  
  `signal z : std_logic := '1' nand '1';`

- **nor**  
  `signal w : std_logic := '0' nor '0';`

- **xor**  
  `signal v : std_logic := '1' xor '0';`

- **xnor**  
  `signal u : std_logic := '1' xnor '1';`

- **not**  
  `signal n : std_logic := not '1';`

---

## 4. Shift Operators
- **sll (shift left logical)**  
  `signal sl : bit_vector(3 downto 0) := "1010" sll 1;`

- **srl (shift right logical)**  
  `signal sr : bit_vector(3 downto 0) := "1010" srl 1;`

- **sla (shift left arithmetic)**  
  `signal sla_ex : signed(3 downto 0) := "1010" sla 1;`

- **sra (shift right arithmetic)**  
  `signal sra_ex : signed(3 downto 0) := "1010" sra 1;`

- **rol (rotate left)**  
  `signal rl : bit_vector(3 downto 0) := "1010" rol 1;`

- **ror (rotate right)**  
  `signal rr : bit_vector(3 downto 0) := "1010" ror 1;`

---

## 5. Concatenation Operator
- **& (concatenation)**  
  `signal concat : std_logic_vector(7 downto 0) := "1010" & "0101";`

---

## 6. Miscellaneous Operators
- **Exponentiation (**)**  
  `signal exp : integer := 2 ** 3; -- result = 8`
 
---

# Structure of a VHDL File (.vhd)

## 1. Library and Use Clauses
Every VHDL file begins with **library declarations** and **use clauses**.  
- **Libraries** are collections of packages. The most common is `IEEE`.  
- **Use clauses** import specific packages from a library, giving access to data types (`std_logic`, `signed`, `unsigned`) and functions.  

Example:
```vhdl
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
```
Without these, you cannot use standard logic types or arithmetic on vectors.

---

## 2. Entity Declaration
The **entity** defines the external interface of your design.  
- It is like the “black box” view: what inputs and outputs exist.  
- Inside the `port` section you declare signals with direction (`in`, `out`, `inout`) and type.  
- The entity does not describe behavior, only the interface.  

Example:
```vhdl
entity my_entity is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    data_in  : in  std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0)
  );
end my_entity;
```

---

## 3. Architecture Body
The **architecture** describes the internal implementation of the entity.  
- You can have multiple architectures for the same entity (e.g., one behavioral, one RTL).  
- Inside the architecture you can declare internal signals, constants, and components.  
- The architecture contains **concurrent statements** (executed in parallel) and **processes** (sequential code triggered by signals).  

Example:
```vhdl
architecture rtl of my_entity is
  signal temp : std_logic_vector(7 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      temp <= (others => '0');
    elsif rising_edge(clk) then
      temp <= data_in;
    end if;
  end process;

  data_out <= temp;
end rtl;
```
This architecture implements a simple register: on each clock edge, `data_in` is stored in `temp` and then sent to `data_out`.

---

## 4. Configuration (Optional)
A **configuration** specifies which architecture is bound to which entity.  
- Useful when you have multiple architectures and want to select one for synthesis or simulation.  
- Rarely used in small projects, but important in large designs.  

Example:
```vhdl
configuration cfg of my_entity is
  for rtl
  end for;
end cfg;
```

---

## 5. Package Declaration (Optional)
Packages allow you to define **reusable elements**: constants, types, functions, procedures.  
- They are like “header files” in other languages.  
- You can share packages across multiple entities/architectures.  

Example:
```vhdl
package my_pkg is
  constant DATA_WIDTH : integer := 8;
  type state_t is (IDLE, RUN, DONE);
end package my_pkg;
```

---

## 6. Package Body (Optional)
If your package declares functions or procedures, the **package body** contains their implementation.  

Example:
```vhdl
package body my_pkg is
  function add_one(x : integer) return integer is
  begin
    return x + 1;
  end function;
end package body my_pkg;
```

---

## 7. Testbench (Separate File)
A **testbench** is a special VHDL file used only for simulation.  
- It instantiates the entity under test (UUT = Unit Under Test).  
- Provides stimulus (input signals) and checks outputs.  
- Contains non-synthesizable code (e.g., `wait for 10 ns`).  

Example:
```vhdl
entity tb_my_entity is
end tb_my_entity;

architecture sim of tb_my_entity is
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal din   : std_logic_vector(7 downto 0);
  signal dout  : std_logic_vector(7 downto 0);
begin
  uut: entity work.my_entity(rtl)
    port map (
      clk => clk,
      reset => reset,
      data_in => din,
      data_out => dout
    );

  -- Clock generation
  clk <= not clk after 10 ns;

  -- Stimulus
  process
  begin
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    din <= "10101010";
    wait for 100 ns;
    wait;
  end process;
end sim;
```
---

# Process Block in VHDL

A **process block** in VHDL is a fundamental construct used to describe sequential behavior within an architecture. Unlike concurrent statements, which are executed in parallel, a process block executes its statements sequentially whenever an event occurs on one of the signals listed in its sensitivity list. The sensitivity list defines which signals trigger the process when they change value.

Inside a process, both variables and signals can be used. Variables update immediately within the process, while signals update after the process suspends. A process typically contains conditional statements such as `if` or `case`, making it suitable for modeling clocked logic, finite state machines, and complex sequential operations.

It is important to note that a process block can describe **synthesizable RTL logic** (registers and combinational circuits) or **non‑synthesizable behavioral logic** (simulation‑only constructs). The distinction depends entirely on how the process is written: if it uses clock edges and proper sensitivity lists, it represents RTL hardware; if it uses simulation‑only statements such as `wait for 10 ns`, it is behavioral and cannot be synthesized.

## Register Processes
A **register process** is the most common type of process used in synchronous digital design. It models registers that store data on a clock edge.  
- The sensitivity list usually contains the **clock** and optionally a **reset** signal.  
- The process checks for a rising or falling edge of the clock.  
- On reset, the register is cleared; otherwise, on the clock edge, the register captures the input value.  

Example of a register process:
```vhdl
process(clk, reset)
begin
  if reset = '1' then
    q <= '0';
  elsif rising_edge(clk) then
    q <= d;
  end if;
end process;
```
This process models a D flip-flop with asynchronous reset. The output `q` is cleared when `reset` is active, otherwise it takes the value of `d` on each rising edge of `clk`. This is **synthesizable RTL code**.

## Using the Sensitivity List
The **sensitivity list** determines when the process is evaluated.  
- For **sequential logic (registers)**, include the clock and reset signals.  
- For **combinational logic**, include all input signals that affect the output.  
- If a signal is missing from the sensitivity list in combinational logic, simulation results may differ from synthesis, leading to unintended latches.  

Example of a combinational process:
```vhdl
process(a, b, sel)
begin
  if sel = '0' then
    y <= a;
  else
    y <= b;
  end if;
end process;
```
Here, the sensitivity list includes all inputs (`a`, `b`, `sel`) to ensure correct combinational behavior. This is also **synthesizable RTL code**.

---

In summary, a **process block** is a general construct that can describe either **RTL hardware** (registers and combinational logic, synthesizable) or **behavioral logic** (simulation‑only, non‑synthesizable). **Register processes** rely on clock and reset signals in the sensitivity list to model synchronous registers, while **combinational processes** must include all input signals to ensure correct synthesis and avoid unintended latches.

NOTE; different processes must not change the same output signal.

# Top-Level Entity and Components in VHDL

A **top-level entity** in VHDL represents the highest abstraction level of a design. It defines the external interface of the entire project, specifying all input and output ports that connect the FPGA design to the outside world. The top-level entity acts as the entry point for synthesis and implementation: when the design is compiled, this entity is the one mapped to the physical pins of the FPGA. Typically, it contains only the port declarations and does not describe internal behavior directly; instead, it instantiates lower-level modules (components) inside its architecture.

A **component** in VHDL is a reusable building block that represents another entity within the design. Components are declared in the architecture of the top-level entity (or in packages) and then instantiated to build hierarchical designs. Each component has its own entity and architecture, defining its interface and behavior. By instantiating components, the top-level entity connects them together using signals, creating a structured design where complex systems are built from smaller, manageable modules.

### Example
```vhdl
-- Top-level entity
entity TopLevel is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    sw    : in  std_logic_vector(2 downto 0);
    led   : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of TopLevel is
  -- Component declaration
  component StateMachineProject is
    port (
      clk   : in  std_logic;
      sw    : in  std_logic_vector(2 downto 0);
      led   : out std_logic_vector(2 downto 0)
    );
  end component;

  -- Internal signals
  signal sw_sig  : std_logic_vector(2 downto 0);
  signal led_sig : std_logic_vector(2 downto 0);

begin
  -- Component instantiation
  U1: StateMachineProject
    port map (
      clk => clk,
      sw  => sw_sig,
      led => led_sig
    );

  -- Connect outputs to top-level ports
  led <= led_sig;
  sw_sig <= sw;
end rtl;
```

In this example, the **TopLevel entity** defines the external interface of the design, while the **StateMachineProject component** is instantiated inside its architecture. The signals `sw_sig` and `led_sig` act as internal connections between the top-level ports and the component. This hierarchical approach allows complex FPGA designs to be organized into smaller, reusable modules, improving readability, maintainability, and scalability.
---

# FPGA Netlist components

## FPGA I/O Buffers

I/O buffers are specialized circuits inside the FPGA that manage the interface between internal logic and external pins. They ensure electrical compatibility, protect the FPGA core, and enable reliable signal transmission. Common buffer types include input buffers (IBUF), which translate external signal levels to the FPGA core; output buffers (OBUF), which drive external pins with configurable drive strength and slew rate; and bidirectional buffers (IOBUF), which let a single pin act as input or output under control of an enable signal. Clock buffers (e.g., BUFG, BUFH, BUFR) distribute clock signals across the device with low skew. I/O buffers are configurable for many standards (LVCMOS, LVDS, SSTL, HSTL, etc.), allowing the FPGA to interface with diverse external devices. Correct I/O buffer configuration is essential for signal integrity and overall system reliability, particularly in mission‑critical applications.

## Logic Cells in FPGAs

Logic cells are the fundamental building blocks of an FPGA. Each cell typically contains a **Look-Up Table (LUT)** to implement combinational logic, one or more **flip-flops** to store sequential data, and auxiliary elements such as multiplexers for signal selection. Their role is to **perform logic operations and register storage**, not to handle routing. The routing fabric of the FPGA interconnects these cells, allowing complex circuits to be built from many small logic functions. Logic cells are used to implement everything from simple gates (AND, OR, XOR) to more complex structures such as counters, finite state machines, and arithmetic units. By combining thousands or millions of logic cells through programmable routing, designers can create highly customized digital systems. In practice, logic cells are the **computational core** of the FPGA, while routing and I/O buffers provide the connectivity to other cells and to the external world.

---

# Concurrent Statements

Concurrent statements are evaluated conceptually in parallel and are written directly inside an architecture (outside of `process` bodies). They model hardware that is always active, such as combinational logic, continuous signal assignments, component instantiations, generate blocks, and concurrent conditional selects.

Common concurrent forms and examples:

```vhdl
-- simple combinational assignment (concurrent)
out_sig <= a and b;

-- concurrent conditional assignment (when-else, priority)
y <= a when sel = "00" else
     b when sel = "01" else
     d;

-- with-select (concurrent, non-priority / parallel select)
with sel select
  y <= a when "00",
       b when "01",
       c when "10",
       d when others;
```

### Generate (concurrent, elaboration-time)

The `generate` statement is a concurrent, elaboration-time construct used to create replicated or conditional blocks of design elements. Generates are elaborated before simulation or synthesis begins and are commonly used to instantiate repeated structures (arrays of components), to build parameterized hardware, or to include/exclude parts of a design based on generics or constants.

Forms and examples:

- `for-generate`: replicates a block for each index in a range.

```vhdl
gen_inst: for i in 0 to 3 generate
  U_inst: my_and
    port map (a => a_bus(i), b => b_bus(i), y => y_bus(i));
end generate gen_inst;
```

- `if-generate`: conditionally includes a block when a static condition is true.

```vhdl
gen_width: if WIDTH = 8 generate
  signal tmp : std_logic_vector(WIDTH-1 downto 0);
end generate gen_width;
```

Key points and synthesis notes:

- Generates are evaluated at elaboration time; the condition and loop bounds must be static (constants, generics, or other elaboration-time expressions) so synthesis tools can unroll the generate into concrete instances.
- Each generate must be labeled (the label before `:` is used to close the block with `end generate <label>`). Labels provide a namespace for signals and instances inside the generate block.
- `for-generate` is ideal for replicating buses, arrayed arithmetic units, or banks of identical peripherals.
- `if-generate` is useful for selecting implementation variants based on generics (e.g., optional features, varying datapath widths).
- Many synthesis tools simply expand generate blocks into individual instances; check your synthesis tool's elaboration/synthesis report if the generated structure differs from expectations.
- Avoid runtime-dependent conditions in generate (they must not depend on signal values); use constants or generics instead.

**Note on `if-generate` and multiplexers:**

The `if-generate` construct is evaluated at elaboration time and therefore **does not implement a runtime multiplexer**. It selects which hardware is instantiated based on constants or generics before synthesis. If your goal is to select between signals at runtime, use a combinational multiplexer implemented with `when-else`, `with-select`, or a `case` statement inside a process (see Sequential section for `case`).

Example: runtime multiplexers (concurrent and sequential forms)

```vhdl
-- concurrent when-else (priority-based)
y <= a when sel = "00" else
     b when sel = "01" else
     c when sel = "10" else
     d;

-- concurrent with-select (parallel selection)
with sel select
  y <= a when "00",
       b when "01",
       c when "10",
       d when others;
```

# Sequential Statements

Sequential statements appear inside `process`, `function` or `procedure` bodies and execute in sequence whenever the enclosing process is triggered (by its sensitivity list or by `wait` statements). Sequential code is used to describe algorithmic behavior and synchronous elements (registers, FSMs). Typical sequential constructs include `if`, `case`, `loop`, and variable assignments.

Examples:

```vhdl
-- Sequential (inside a process): synchronous register
process(clk)
begin
  if rising_edge(clk) then
    q <= d; -- q is updated at the clock edge (register)
  end if;
end process;

-- case inside a combinational process (clear and scalable)
process(sel, a, b, c, d)
begin
  case sel is
    when "00" => y <= a;
    when "01" => y <= b;
    when "10" => y <= c;
    when others => y <= d;
  end case;
end process;
```

Key notes and guidelines:

- Use concurrent statements for simple combinational logic and for connecting components at the architecture level.
- Use sequential statements inside processes to implement synchronous logic, state machines, and algorithms that require ordered execution.
- For combinational processes include all input signals in the sensitivity list (or use `process(all)`) to avoid simulation/synthesis mismatches and unintended latches.
- Sequential signal assignments (`<=`) update signals with process-suspension semantics; variables inside a process update immediately and are useful for local computations.

Following these conventions helps make code readable, simulation-accurate, and synthesizable across tools.

# Generate Statement

The `generate` statement is a concurrent, elaboration-time construct used to create replicated or conditional blocks of design elements. Generates are elaborated before simulation or synthesis begins and are commonly used to instantiate repeated structures (arrays of components), to build parameterized hardware, or to include/exclude parts of a design based on generics or constants.

Forms and examples:

- `for-generate`: replicates a block for each index in a range.

```vhdl
gen_inst: for i in 0 to 3 generate
  U_inst: my_and
    port map (a => a_bus(i), b => b_bus(i), y => y_bus(i));
end generate gen_inst;
```

- `if-generate`: conditionally includes a block when a static condition is true.

```vhdl
gen_width: if WIDTH = 8 generate
  signal tmp : std_logic_vector(WIDTH-1 downto 0);
end generate gen_width;
```

Key points and synthesis notes:

- Generates are evaluated at elaboration time; the condition and loop bounds must be static (constants, generics, or other elaboration-time expressions) so synthesis tools can unroll the generate into concrete instances.
- Each generate must be labeled (the label before `:` is used to close the block with `end generate <label>`). Labels provide a namespace for signals and instances inside the generate block.
- `for-generate` is ideal for replicating buses, arrayed arithmetic units, or banks of identical peripherals.
- `if-generate` is useful for selecting implementation variants based on generics (e.g., optional features, varying datapath widths).
- Many synthesis tools simply expand generate blocks into individual instances; check your synthesis tool's elaboration/synthesis report if the generated structure differs from expectations.
- Avoid runtime-dependent conditions in generate (they must not depend on signal values); use constants or generics instead.

Example: parameterized adder array

```vhdl
entity adder_array is
  generic (N : natural := 4);
  port (
    A : in  std_logic_vector(N-1 downto 0);
    B : in  std_logic_vector(N-1 downto 0);
    S : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of adder_array is
begin
  gen_adders: for i in 0 to N-1 generate
    full_adder_inst: full_adder
      port map (a => A(i), b => B(i), sum => S(i));
  end generate gen_adders;
end rtl;
```

Using the `generate` statement makes designs concise, parameterizable, and easy to scale. Always ensure generate conditions are elaboration-time constants so both simulation and synthesis behave predictably.

**Note on `if-generate` and multiplexers:**

The `if-generate` construct is evaluated at elaboration time and therefore **does not implement a runtime multiplexer**. It selects which hardware is instantiated based on constants or generics before synthesis. If your goal is to select between signals at runtime, use a combinational multiplexer implemented with `when-else`, `with-select`, or a `case` statement inside a process.

Example: runtime multiplexers

```vhdl
-- when-else (priority-based, simple)
y <= a when sel = "00" else
     b when sel = "01" else
     c when sel = "10" else
     d;

-- with-select (parallel selection)
with sel select
  y <= a when "00",
       b when "01",
       c when "10",
       d when others;

-- case inside a combinational process (clear and scalable)
process(sel, a, b, c, d)
begin
  case sel is
    when "00" => y <= a;
    when "01" => y <= b;
    when "10" => y <= c;
    when others => y <= d;
  end case;
end process;
```

Why `case` is often better:

- **Clarity**: `case` expresses an explicit, non-priority selection for multiple mutually-exclusive choices, making intent and behavior clear.  
- **Scalability**: easier to extend to many branches compared to chained `when-else` statements.  
- **Synthesis behavior**: `case` commonly maps cleanly to balanced multiplexer trees or decoder + mux logic without unintended priority effects.  
- **Safety**: `case` encourages handling `others`, reducing the risk of unassigned states that could infer latches.

Use `when-else` for small priority-based choices, `with-select` for concise parallel selection, and `case` when you need readability and explicit multi-way selection.

# Latches in VHDL (latches on FPGAs)

Latches are level-sensitive storage elements that synthesis tools infer when combinational logic is written in a way that allows a signal to retain its previous value under some conditions. In VHDL, latches are commonly inferred accidentally in combinational processes when not all outputs are assigned on every control path or when the sensitivity list is incomplete.

Important clarification: latch inference is a concern for combinational logic descriptions. In properly written clocked (synchronous) processes that use an edge test (for example `if rising_edge(clk) then ...`), synthesis tools infer edge‑triggered flip‑flops (registers), not latches. The accidental latch patterns described here occur because a combinational process leaves a signal unassigned on some paths so the synthesis tool must provide storage; when you place assignments inside the clocked branch of a register process, the tool will infer flip‑flops with predictable sampling on the clock edge.

Why latches are often undesirable on FPGAs:
- Latches are level-sensitive and asynchronous storage: they complicate timing analysis and can introduce unexpected critical paths.
- FPGA flows and tools generally prefer synchronous registers (edge-triggered flip-flops) because they provide more predictable timing and easier timing closure. Latches make behavior dependent on how long an enable condition is asserted.
- Latches are not inherently wrong: they can be used intentionally to save registers, but they require careful timing and functional validation.

Accidental latch example:
```vhdl
process(a, b)
begin
  if a = '1' then
    out_sig <= b;  -- assigned only when a = '1'
  end if;
  -- when a /= '1', out_sig retains its previous value -> latch inferred
end process;
```

How to avoid accidental latches:
- Provide a default assignment for all combinational outputs at the start of the process:
```vhdl
process(a, b)
begin
  out_sig <= '0'; -- default
  if a = '1' then
    out_sig <= b;
  end if;
end process;
```
- Use `process(all)` during development for combinational processes so you don't accidentally omit signals from the sensitivity list.
- Prefer clocked (synchronous) processes when you need storage and predictable timing:
```vhdl
process(clk)
begin
  if rising_edge(clk) then
    reg <= data;
  end if;
end process;
```

Checks and tools:
- Inspect the synthesis report: tools usually list inferred latches.
- Use functional simulation to spot unexpected values that remain unchanged when they should update.
- Add assertions or checks in your testbench to detect signals that are not assigned on all paths.

Practical rules:
- In combinational processes, initialize all outputs/signals at the top of the process.
- If you need memory, prefer synchronous flip-flops for clarity and easier timing.
- If a latch is intentionally required, document the intent and constraints clearly in the source code.

This section explains how latches can appear in VHDL for FPGAs, why they are often undesired, and simple practices to avoid them.

# Good practises 

## Avoid latches
- Latches are present only in combinational process.
- Latches are a problem only when there are conditional statements (if then/case).
- You must make sure that all the outputs are defined in all possible conditions (with case statements be sure to put all the outputs in all the cases). 

## Generate scaled clocks via PLLs
- You can think to generate a scaled version of the main clock source via logic, but this new clockwill be affected by skew delay, lag and temperature changes.
- The best ay to generate scaled clocks is via PLLs that are present as dedicated hardware blocks in your FPGA.

## Avoid clock gating
- For similar reason we avoid to generate clock via logic, we also avoid to add logic (for example by adding conditions) to the clock input of a register. That logic will add delay to the clock in that input and will make it not synchronized with the actual clock. 
- Instead of clock gating, prefer the usage of data gating.

## Use registers both for entity outputs and inputs
- It is a good practise to use registers both for outputs and inputs in order to avoid glitches.
- To do that you have do assign outputs and inputs within a register process.
- In case of inputs, you should create correponding local signals, assign them with the actual inputs after the clock condition and then only use these signals within the register instead of the actual inputs. This will create input registers.

## Use pipelining
- Large combinational blocks will add larger delays and this will slower our FPGA.
- With pipeling we add some additional registers to break up large combinational functions.
- Separating complex logics with register will make the separated sub-functions simpler and thus faster compared to the initial larger one.
- In this way, we can dimension the clock period to be faster.

NOTE; you must se the clock period according to the slower path between two registers, so if you pipeling the larger path you will obtain smaller path an then you can dimension your clock period to be faster.

## Use synchronous designs
- Synchronous designs use register process with the rising or fallng edge clock condition.
- This approach is more robust to glitches compared to pure combinational logic and asynchronous designs. 
- Synchronous designs are also easier to debug.

EXAMPLE; An asynchronous button input can be affected by glitches due to voltage spikes or temperature variations that can cause the entire register to see a wrong input. 

## Two flip-flop synchronizer
- When an asynchronous input signal enters an FPGA, sampling it directly can cause metastability if it changes near the clock edge.
- To mitigate this, designers use a two‑flip‑flop chain.
- First flip‑flop (FF1) captures the asynchronous signal. It may go metastable, but usually settles within one clock cycle.
- Second flip‑flop (FF2) samples the output of FF1. By this time, the signal is stable, so FF2 provides a clean, synchronized output.
- This technique greatly reduces the probability of metastability propagating into the main logic.

## Synchronize reset de-asertion
- Reset can be an asynchronous signal.
- The de-assertion should be syncronous by using a special case of the Two flip-flop synchronizer.
- This beacause, while the assertion always have a well defined status, the deassertion can bring some registers in metastability.
- By using the Two flip-flop synchronizer with the input reset used as normal asyncrhonous reset that immediatly force to a default status (for example 1) and 0 as input, we avoid the deassertion problem, because during the deassertion the first flip flop can be metastable, but the second one will always be stable to 0. 

## Crossing clock domains
- In designs with various clocks we call each clock as clock domain.
- A clock domain is very likerly to be asynchronous with a different clock domain.
- Signals that change clock domain must be synchronized to the different domain.
- There are various technique to do that.
- Two flip-flop synchronizer.
- Using additional signals for hand-shaking.
- Using FIFOs.

## Use global routing for clock and reset signals
- This is usually automatically done by quartus.
- This avoid skew due to spatial delay of modules.

## Use internal signalse to interface actual outputs
- Directly driving output ports inside sequential logic is usually possible, but it’s not best practice. Internal signals should represent the actual registers and state, while outputs are simply assigned to those signals. This separation improves clarity, avoids synthesis ambiguities, and makes the design more reusable and maintainable.