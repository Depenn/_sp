# Function Call Mechanism Analysis

The p0 compiler simulates the behavior of a real CPU using a "Call Stack" and "Stack Frames" to manage function execution and memory isolation.

## 1. Stack Frame & Scope Isolation
The Virtual Machine (VM) maintains a global `Frame stack[1000]` array and a Stack Pointer `sp`.
- Each `Frame` is an isolated memory space for a function call.
- It contains its own `names` and `values` arrays for local variables.
- When a function is called, `sp` is incremented (`sp++`), creating a new frame. This prevents the callee from accidentally overwriting the caller's variables.

## 2. Parameter Passing Flow
Arguments are passed from the **Caller** to the **Callee** using a three-step mechanism:
1.  **PARAM (Caller Side)**: The caller evaluates the arguments and pushes them onto a temporary `param_stack`.
2.  **CALL (Transfer)**: The VM increments `sp`, saves the return address, and moves values from `param_stack` to the new frame's `incoming_args` buffer.
3.  **FORMAL (Callee Side)**: Inside the function body, `FORMAL` instructions take values from `incoming_args` and define them as local variables in the current frame.

## 3. Return Address & Flow Control
To ensure the program can resume execution after a function finishes:
- The `CALL` instruction stores the current `pc + 1` into `stack[sp].ret_pc`.
- The `RET_VAL` instruction retrieves this address, decrements the stack pointer (`sp--`) to "pop" the frame, and sets the global `pc` back to the return address.

## 4. Local Variable Scoping
The functions `get_var` and `set_var` are strictly bound to `stack[sp]`. 
- This means a function only searches for variables within its own frame.
- In the standard p0 implementation, this creates **Purely Local Scope**: a function cannot see global variables (which are in `stack[0]`) unless they are passed as parameters.

## 5. Recursion Support
Because every call (including recursive ones) triggers `sp++`, each level of recursion gets its own unique stack frame. For example, in a factorial function, `fact(3)` and `fact(2)` exist in different frames, allowing them to have their own independent variable `n` without conflict.
