Demo program that renders Batman logo for IBM PC-DOS 1.00 using IBM Personal Computer Fortran 1.00

Build steps:

```
(Insert DISK1-FOR1.IMG in A: and DISK5-SOURCE.IMG in B: and boot in IBM PC/emulator)
B:
A:FOR1 BATMAN;
(Insert DISK2-FOR2.IMG in A:)
A:FOR2
(Insert DISK3-MASM.IMG in A:)
A:MASM UTIL;
(Insert DISK4-LINK.IMG in A:)
A:LINK BATMAN+UTIL;

(Test BATMAN.EXE)
BATMAN.EXE
```
