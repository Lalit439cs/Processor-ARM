# Processor-ARM
Designed hardware for implementing a processor that can execute  a subset of ARM instructions.</br>
In Computer Architecture course,designed Microarchitecture for a subset of ARM instructions.</br>
The designs are expressed in VHDL language and then simulated and synthesized. 
 
### ARM 32 bit-Instruction Set-

Arithmetic: <add|sub|rsb|adc|sbc|rsc> {cond} {s} </br>
Logical: <and | orr | eor | bic> {cond} {s} </br>
Test: <cmp | cmn | teq | tst> {cond} </br>
Move: <mov | mvn> {cond} {s}</br>
Branch: <b | bl> {cond}</br>
Multiply: <mul | mla | smull | smlal | umull | umlal> {cond} {s}</br>
Load/store: <ldr | str> {cond} {b | h | sb | sh }</br>
SW interrupt: reset,I/O related ISRs</br>
cond: <EQ|NE|CS|CC|MI|PL|VS|VC|HI|LS|GE|LT|GT|LE|AL> </br>

### Stages-
Here started with a skeleton design, the hardware is to be built in several stages outlined below, adding some functionality at every stage.

**Stage 1: Design and testing of basic modules** </br>
The module set includes ALU, Register File, Program Memory and Data Memory.

**Stage 2: Single cycle design for a tiny subset of instructions** </br>
The subset of instructions is {add, sub, cmp, mov, ldr, str, beq, bne, b} with limited 
variants/features.

**Stage 3: Multi-cycle design for the tiny subset of instructions** </br>
Continuing with same instructions as used in stage 2, modify the circuit to follow a 
multi-cycle aproach.

**Stage 4: Support for all DP opcodes** </br>
The ALU designed in stage 1 already supports all DP opcodes, use this stage to 
extensively test the design covering all DP instructions. Continue with limited 
features/variants defined for stage 2.

**Stage 5: Support for shift and rotate features** </br>
Augment the design with a shifter module and add appropriate shift/rotate features to 
DP and DT instructions.

**Stage 6: Support for all data transfer features** </br>
The features to be supported include byte and half word transfers (signed and 
unsigned), auto increment/decrement and pre/post indexing.

**Stage 7: All multiply group instructions** </br>
Augment the design with a multiply-accumulate module and add all the multiply 
group instructions to the set.

**Stage 8: Include remaining instructions and features** </br>
Include bl and swi instructions and provide support for full predication.



