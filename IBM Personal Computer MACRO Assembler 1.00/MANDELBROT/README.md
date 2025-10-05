Renders Mandelbrot set in CGA mode 4. Use IBM PC DOS 1.00 and IBM Macro Assembler 1.00 to compile the demo. The code is based on this [VGA demo](https://github.com/wbhart/PCRetroProgrammer/blob/main/MANDEL2.ASM).

Build steps:
```
MASM.EXE MANDEL;

LINK.EXE
< Answer "mandel" when asked for object modules
< Answer "mandel" when asked for run file

DEBUG.COM
-n mandel.exe
-l
-n mandel.com
-rcx
122
-w
-q

MANDEL.COM
```

DEMO.IMG disk image is bootable IBM PC DOS 1.00 and contains the source code and required build tools.
