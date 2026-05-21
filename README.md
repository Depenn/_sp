# System Programming — Notes, Exercises & Reports
# 課程：系統程式 -- 筆記、習題與報告

欄位 | 內容
-----|--------
學期 | 114 學年下學期
學生 |  林順義
學號末兩碼 | 21
教師 | [陳鍾誠](https://www.nqu.edu.tw/educsie/index.php?act=blog&code=list&ids=4)
學校科系 | [金門大學資訊工程系](https://www.nqu.edu.tw/educsie/index.php)
課程教材 | https://github.com/ccc114b/cpu2os<br/>https://github.com/cccbook/ai-teach-you/blob/main/sp/tw/README.md<br/>https://github.com/ccc-c/c0computer


---

## Homework Overview

| HW | Topic | Language | Description |
|----|-------|----------|-------------|
| **HW1** | p0 Compiler & Virtual Machine | C (with Rust reference) | A compiler and VM for the p0 language — a minimal C-like language with functions, recursion, while-loops, and if-statements. |
| **HW2** | SimpleCalc Interpreter | Python | A tree-walk interpreter for a custom language called SimpleCalc, featuring variables, arithmetic, conditionals, and loops. |
| **HW3** | JavaPeaks Web Directory | HTML, CSS, JavaScript | An interactive web directory of mountains in Java, Indonesia — with map integration, search, filtering, and WhatsApp basecamp contacts. |
| **HW4** | The Verilog Architect | Verilog, Markdown | A multi-chapter book on digital design, covering combinational/sequential logic, ALU construction, and a minimal RISC-V processor. |
| **HW5** | Concurrent Programming | C (POSIX Threads) | Three classic OS concurrency problems: Dining Philosophers, Producer-Consumer, and Bank Account race conditions. |
| **HW6** | Process & File Summary | Markdown | A theoretical summary of Linux system programming concepts (fork, exec, file descriptors, I/O redirection). |
| **HW7** | verilog0c — Verilog-to-C Translator | C, Verilog | A translator that converts a synthesizable Verilog subset into equivalent C programs for simulation and testing. |

---

### HW1 — p0 Compiler & Virtual Machine

#### Problem

Design a compiler for the **p0 language**, a minimal C-like language that supports functions, recursion, `if`-statements, and `while`-loops. The compiler must translate p0 source code into intermediate code (quadruples), and a bundled virtual machine must execute them.

#### General Approach

The standard compiler pipeline: **Lexing → Parsing → Intermediate Code Generation → Execution**. The lexer breaks source text into tokens. The parser (recursive descent) builds structure and emits quadruples — simple three-address instructions like `ADD t1 a b` or `JMP_F cond ?`. A VM then interprets these quadruples using a stack-based frame model.

#### My Implementation

The entire compiler and VM live in a **single C file** (`compiler.c`):

- **Lexer**: Reads the source character-by-character. Handles comments (`//` and `/* */`), skips whitespace, and classifies tokens (keywords: `func`, `if`, `return`, `while`; operators; identifiers; numbers).
- **Parser**: Recursive-descent parser that mirrors the p0 EBNF grammar. For each parsed construct, it calls `emit()` to generate quadruples. Uses **backpatching** for control flow — `JMP_F` and `JMP` instructions initially have placeholder destinations that are filled once the target address is known.
- **Virtual Machine**: Maintains a call stack of `Frame` structs. Each frame holds its own local variables (`names`/`values` arrays), a return address, and incoming argument buffer. The VM simulates a CPU program counter loop, dispatching each quadruple. Recursive functions get clean stack isolation — each call increments the stack pointer.

#### Why This Approach

- **Single-file design** keeps the project simple and compileable with a single `gcc` command — no Makefile or build system needed.
- **Backpatching** avoids a separate label-fixing pass; jump destinations are patched in-place once known, which is both efficient and easy to debug.
- **Stack-frame isolation** makes recursion trivial: each `CALL` pushes a new frame, and `RET_VAL` pops it. The `sp` (stack pointer) ensures callee variables never collide with caller variables.

---

### HW2 — SimpleCalc Interpreter

#### Problem

Build a tree-walk interpreter for **SimpleCalc**, a custom scripting language with variables, integer arithmetic (`+`, `-`, `*`, `/`), comparison operators, `if-else` branching, `while` loops, and `print` output.

#### General Approach

Three-phase interpreter: **Lexer → Parser (AST) → Interpreter**. The lexer tokenizes the source, the parser builds an Abstract Syntax Tree (AST), and the interpreter walks the AST recursively to produce results.

#### My Implementation

- **Lexer** (`lexer.py`): Converts source code into a flat list of `Token` objects. Token types include identifiers, numbers, operators, keywords (`if`, `else`, `while`, `print`), and structural symbols (`{`, `}`, `;`, `(`, `)`).
- **Parser** (`parser.py`): Reads tokens and constructs an AST using recursive descent. Each grammar rule returns an AST node (e.g., `AssignNode`, `IfNode`, `WhileNode`, `BinOpNode`). The parser is **strict** — it validates syntax at parse time and raises clear errors.
- **Interpreter** (`interpreter.py`): Walks the AST using a visitor pattern. Maintains an environment dictionary for variable bindings. Each node type has a corresponding `interpret_*` method. Control flow (`if`/`while`) is handled natively in Python.
- **Entry point** (`main.py`): Reads a `.sc` file, chains lex → parse → interpret, and reports errors.

#### Why This Approach

- **Separated phases** make the code easy to debug — each phase can be tested independently.
- **AST-based interpretation** is simpler than bytecode generation and still demonstrates the core of language implementation.
- **Python** was chosen for rapid prototyping; the interpreter logic is clear without being buried in memory management.

---

### HW3 — JavaPeaks Web Directory

#### Problem

Create an interactive web directory that displays mountains in Java, Indonesia, with features including search, region/difficulty filtering, an interactive map, and WhatsApp links to basecamps.

#### General Approach

Static frontend with **Tailwind CSS** for styling and **Leaflet.js** for map rendering. Data is loaded from a local JSON file. All filtering and rendering happens client-side via vanilla JavaScript.

#### My Implementation

- **HTML** (`index.html`): Semantic layout with a navigation bar, hero section, filter controls (search input + region/difficulty dropdowns), a Leaflet map container, a card grid for mountain listings, and a modal dialog for detailed information.
- **CSS** (`style.css`): Minimal custom styles complementing Tailwind. Card hover effects, modal transitions, responsive grid adjustments, and map sizing.
- **JavaScript** (`script.js`): Loads `gunung.json`, renders mountain cards with difficulty badges and height stats. Implements real-time search and multi-filter logic. Leaflet map displays markers for each mountain. Clicking a card or marker opens a detail modal with description, popular hiking paths, estimated cost, and a WhatsApp link to the basecamp.
- **Data** (`gunung.json`): JSON array of mountain objects, each with name, region, height, difficulty, description, coordinates, image URL, popular paths, and basecamp contact.

#### Why This Approach

- **Vanilla JavaScript** avoids framework overhead — the app is simple enough that React/Vue would be overkill.
- **Tailwind via CDN** allows rapid styling without a build step. Classes are composed directly in HTML.
- **JSON data file** separates content from code, making it easy to add or edit mountain entries without touching HTML/JS.

---

### HW4 — The Verilog Architect

#### Problem

Write an educational book titled **"The Verilog Architect: From Logic Gates to RISC-V"** that teaches digital design from a hardware mindset. The book must include both explanatory chapters and runnable Verilog code examples.

#### General Approach

Markdown chapters for the book content, plus standalone Verilog files (each with its own testbench) for hands-on simulation. Icarus Verilog (`iverilog`) is used as the simulation tool.

#### My Implementation

The book is divided into 4 chapters:

| Chapter | Title | Content |
|---------|-------|---------|
| 1 | The Hardware Mindset | Why Verilog ≠ software; parallelism; combinational vs sequential thinking; synthesis mental model |
| 2 | Combinational vs Sequential | D flip-flops, counters, shift registers, FSM (traffic light controller) |
| 3 | Building the ALU | From adder to full 8-operation ALU with zero/overflow/carry flags |
| 4 | RISC-V Instruction Set | Register file, instruction decoder, minimal RISC-V datapath |

Each chapter has companion code in `code-examples/` organized by chapter. Every example is self-contained — module + testbench in one file — so running `iverilog file.v && vvp a.out` is all that's needed.

#### Why This Approach

- **Markdown** is universally readable on GitHub and easy to edit. No PDF generation pipeline needed.
- **Self-contained examples** minimize the learning barrier — students can run them immediately without navigating a complex project.
- **Progressive complexity** lets readers build understanding from gates → ALU → CPU, mirroring how hardware is actually designed.

---

### HW5 — Concurrent Programming

#### Problem

Solve three classic concurrency problems in C using POSIX threads:
1. **Dining Philosophers**: 5 philosophers sharing 5 forks, demonstrating deadlock and its prevention.
2. **Producer-Consumer**: Multiple producers and consumers sharing a bounded buffer.
3. **Bank Account**: Multiple threads depositing and withdrawing from a shared account.

#### General Approach

Use `pthreads` for threading and `pthread_mutex_t` / `sem_t` for synchronization. Each problem demonstrates a specific concurrency pattern and its pitfalls.

#### My Implementation

##### 1. Dining Philosophers

Two versions:
- **`philosopher_deadlock.c`**: All philosophers pick up left fork first then right fork. With 5 philosophers all eating simultaneously, the circular wait condition causes deadlock.
- **`philosopher_solution.c`**: Breaks the circular wait by having philosopher 5 pick up the **right** fork first. This prevents the cycle from closing, so at least one philosopher can always eat.

Deadlock detection: The deadlock version uses a 3-second timeout and thread cancellation to demonstrate the stall.

##### 2. Producer-Consumer (`producer_consumer.c`)

A bounded buffer of size 5. Two semaphores (`empty` initialized to 5, `full` initialized to 0) and one mutex coordinate access:
- Producers wait on `empty`, lock mutex, insert item, unlock mutex, post `full`.
- Consumers wait on `full`, lock mutex, remove item, unlock mutex, post `empty`.

This ensures producers block when the buffer is full and consumers block when it's empty, with the mutex preventing race conditions on the buffer indices.

##### 3. Bank Account (`bank_account.c`)

Multiple threads each perform 100,000 deposit/withdrawal pairs. Without a mutex, the non-atomic read-modify-write cycle on the balance causes a race condition. With `pthread_mutex_lock`/`unlock` around each balance update, the final balance correctly remains $0.00.

#### Why This Approach

- **Two versions** of the Dining Philosophers make the deadlock concept tangible — you can see it happen vs. not happen.
- **Semaphores for Producer-Consumer** are the textbook solution and demonstrate counting semaphore semantics naturally.
- **Mutex for Bank Account** shows the simplest possible critical section pattern.
- Each `.c` file is standalone and compileable with `gcc -lpthread`, keeping the learning focused on concurrency, not build tools.

---

### HW6 — Process & File Summary

#### Problem

Write a theoretical summary of Linux system programming concepts: process creation (`fork`), program execution (`execvp`), file descriptors, and I/O operations (`open`, `close`, `read`, `write`, `dup2`).

#### General Approach

Research and synthesize the ccc114b/cccocw course materials into a structured reference document covering both conceptual explanations and code snippets.

#### My Implementation

A Markdown document (`summary_process_file.md`) organized into sections:
- **Process Management**: `fork()` behavior, copy-on-write, return value semantics. `execvp()` and how it replaces the process image.
- **File Descriptors**: stdin/stdout/stderr numbering; how `open()` returns the lowest available FD.
- **Basic File Operations**: `open()`, `close()`, `read()`, `write()` signatures and usage.
- **I/O Redirection**: `dup2()` for redirecting stdout to a file or pipe.

#### Why This Approach

- **Markdown** is ideal for a reference document — readable on GitHub, easy to update, and supports inline code blocks for examples.
- **Structured sections** make it quick to find specific topics (fork, exec, dup2) without scrolling through prose.

---

### HW7 — verilog0c: Verilog-to-C Translator

#### Problem

Build a translator that converts a synthesizable subset of Verilog into equivalent C code. The C output should be compilable with `gcc` and executable — allowing simulation of Verilog designs without Icarus Verilog.

#### General Approach

Standard compiler pipeline: **Lexer → Parser (AST) → Code Generator**. The lexer tokenizes Verilog source (`module`, `wire`, `reg`, `assign`, `always`, `initial`, `if`, `case`, `for`, system tasks). The parser builds an AST. The code generator walks the AST and emits C code.

#### My Implementation

The translator is split across multiple C files:

| File | Purpose |
|------|---------|
| `lexer.c` / `lexer.h` | Tokenizes Verilog source. Handles identifiers, numbers (decimal/hex/binary), keywords, directives (`\`define`), and operators. |
| `parser.c` / `parser.h` | Recursive-descent parser following the Verilog subset EBNF. Builds an AST where each node represents a module, port, wire, reg, assignment, always block, or instantiation. |
| `ast.c` / `ast.h` | AST node types and tree management (`create_node`, `append_child`, `free_ast`). |
| `codegen.c` / `codegen.h` | Walks the AST and emits C code. Each Verilog construct maps to a C equivalent — `wire` → variable, `always @(posedge clk)` → clock-edge check, `assign` → immediate computation. |
| `verilog0c.c` | Entry point: reads input `.v` file, calls `parse_verilog()`, then `generate_c_code()`. |

The project supports a Verilog subset including:
- Module declarations with input/output ports and vectors (`[3:0]`)
- `wire` and `reg` declarations
- Continuous assignments (`assign`)
- `always @(posedge ...)` blocks for sequential logic
- `if`/`case`/`for` statements
- `$display`, `$readmemh`, `$finish` system tasks
- Module instantiation and parameterization

The `v/` directory contains test designs (halfadder, fulladder, comparator, mux2to1, mcu0m CPU) that are translated to C and verified.

There are also archived versions (`_version/v0.1/` and `_version/v0.2/`) tracking the project's evolution.

#### Why This Approach

- **Multi-file C project** mirrors real compiler organization — lexer, parser, AST, and codegen are independent modules with clear interfaces.
- **Subset targeting** keeps the project manageable while still covering enough Verilog to implement a working CPU (mcu0m).
- **Self-verifying tests**: each `v/*.v` file produces an equivalent `.c` file that can be compiled and run to check correctness against the Verilog behavior.
- **Incremental versions** in `_version/` document the development history, showing how features were added step by step.

---

## Dependencies

| Tool | Used For | Installation |
|------|----------|-------------|
| **GCC** | Compiling C files (HW1, HW5, HW7) | `gcc` (via MSYS2/MinGW on Windows, or system package manager on Linux/macOS) |
| **Python 3** | Running the SimpleCalc interpreter (HW2) | [python.org](https://python.org) or system package manager |
| **Icarus Verilog** | Simulating Verilog examples (HW4) | `apt install iverilog` / `brew install icarus-verilog` |
| **GTKWave** | Viewing Verilog waveforms (HW4, optional) | `apt install gtkwave` / `brew install gtkwave` |

---

## How to Compile & Run

### HW1 — p0 Compiler & VM
```bash
cd HW1
gcc -o compiler compiler.c
./compiler p0/while.p0       # Run while-loop example
./compiler p0/recursive.p0   # Run recursive factorial example
```

### HW2 — SimpleCalc Interpreter
```bash
cd HW2
python main.py example.sc
```

### HW3 — JavaPeaks Web Directory
Open `HW3/index.html` in any modern browser. No build step required.

### HW4 — The Verilog Architect
```bash
cd HW4/code-examples
iverilog -o output ch1/adder.v
vvp output
```

### HW5 — Concurrent Programming
```bash
cd HW5

# Dining Philosophers
gcc -o philosopher_deadlock philosopher_deadlock.c -lpthread
./philosopher_deadlock

gcc -o philosopher_solution philosopher_solution.c -lpthread
./philosopher_solution

# Producer-Consumer
gcc -o producer_consumer producer_consumer.c -lpthread
./producer_consumer

# Bank Account
gcc -o bank_account bank_account.c -lpthread
./bank_account
```

### HW7 — verilog0c
```bash
cd HW7/verilog0c
gcc ast.c codegen.c lexer.c parser.c verilog0c.c -o verilog0c
./vrun.sh halfadder   # Translate & compile halfadder, then run
./vrun.sh mcu0m       # Translate & compile the MCU0 CPU, then run
```
