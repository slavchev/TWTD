Demo program that calculates matrix determinant using IBM Personal Computer APL 1.00

Build steps:

```
(Insert APL.IMG in A: and boot in IBM PC/emulator)
MASM /R AP500;
LINK AP500;
DEL AP500.OBJ
EXE2BIN AP500.EXE AP500.COM
DEL AP500.EXE

APL AP500
(Once APL starts)
      )IN TEST
      INITM
      PERF M10
      PERF2 M10
      PERF3 M10
```
