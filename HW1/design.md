# While Statement Design Principles

The implementation of the `while` loop in the p0 compiler follows the standard logic of high-level language translation into assembly-like instructions (Quadruples). 

## 1. Logic Structure
A `while` loop is essentially a conditional jump combined with an unconditional jump back to the start. The generated code follows this pattern:

1.  **L_START**: The instruction index where the condition evaluation begins.
2.  **Condition Evaluation**: Instructions that calculate the condition (e.g., `a < 5`).
3.  **JMP_F (Jump if False)**: If the condition is 0, jump to **L_END**.
4.  **Loop Body**: The statements inside the `{ ... }` block.
5.  **JMP (Unconditional Jump)**: Jump back to **L_START** to re-evaluate the condition.
6.  **L_END**: The instruction index immediately following the loop.

## 2. Label Placement & Backpatching
Because the destination of the `JMP_F` instruction (the end of the loop) is not known until the entire loop body has been parsed, we use a technique called **Backpatching**:
- We record the index of the `JMP_F` instruction.
- We emit the instruction with a placeholder destination (`?`).
- Once parsing of the loop body is complete, we update the `result` field of the recorded `JMP_F` instruction with the current `quad_count`.

## 3. Immediate Failure Handling
If the condition is false on the first check, the `JMP_F` instruction will immediately redirect the Program Counter (PC) to `L_END`, ensuring the loop body is never executed, which is the correct behavior for a `while` statement.
