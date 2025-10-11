Implement MORE utility for IBM PC-DOS 1.00 using IBM Personal Computer Pascal 1.00

Build steps:

```
(Insert DISK1-PAS1.IMG in A: and DISK5-SOURCE.IMG in B: and boot in IBM PC/emulator)
B:
A:PAS1 MORE;
(Insert DISK2-PAS2.IMG in A:)
A:PAS2
(Insert DISK3-MASM.IMG in A:)
A:MASM UTIL;
(Insert DISK4-LINK.IMG in A:)
A:LINK
< Answer "more,util" when asked for object modules
< Answer "more" when asked for run file

(Test MORE.EXE)
MORE MORE.PAS
```
