Demo program that shows reports for IBM PC-DOS 1.00 using IBM Personal Computer COBOL 1.00

Build steps:

```
(Insert DISK1-COBOL1.IMG in A: and DISK4-SOURCE.IMG in B: and boot in IBM PC/emulator)
B:
A:COBOL REPORT;
(Insert DISK3-MASM.IMG in A:)
A:MASM UTIL;
(Insert DISK2-COBOL2.IMG in A:)
A:LINK REPORT+UTIL;

(Test REPORT.EXE or run R1.BAT, R2.BAT, R3.BAT, R4.BAT, R5.BAT)
REPORT.EXE
```
