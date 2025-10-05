DISPLAY_WIDTH   EQU 320
DISPLAY_HEIGHT  EQU 200

DRAW_PORT_WIDTH   EQU 240
DRAW_PORT_HEIGHT  EQU 200

DELTA_X  EQU 8000h / DRAW_PORT_WIDTH
DELTA_Y  EQU 8000h / DRAW_PORT_HEIGHT
INITIAL_X    EQU 8000h / (-2)
INITIAL_Y    EQU 8000h / (-2)
MAX_ITER          EQU 16

CGA_VIDEO_PAGE1   EQU 0B800h
CGA_VIDEO_PAGE2   EQU 0BA00h

CODE SEGMENT PARA PUBLIC 'CODE'
ASSUME CS:CODE, DS:CODE, ES:CODE, SS:CODE
ORG 100h

START:

    ; change to CGA mode 4h (320x200 4 colours)
    MOV AX, 4H
    INT 10H

    ; Mandelbrot set iterates z -> z^2 + c in the
    ; complex numbers, starting with z = 0, and
    ; where c = a + bi is a complex number with
    ; -2 <= a <= 2 and -2 <= b <= 2
    ; (this region is a square in the complex plane)

    ; We draw this square on the screen, setting
    ; the pixel colour to the number of iterations
    ; it takes for the iteration to leave the circle
    ; of radius 2 in the complex plane. We set the
    ; pixel to black if it does not leave the circle
    ; after a certain number of iterations

    ; We will divide all values by 4 and use the
    ; iteration Z -> 4Z^2 + C which means we'll need
    ; values from -0.5 to 0.5 instead of -2.0 to 2.0
    ; We use 16 bit values

    ; For most of the calculation we will even divide
    ; the values by an additional factor of 2 to make
    ; it easier to check for overflows

    ; DX:AX = accum, result of multiplication
    ; DI = offset in VRAM, BX = a, CX = b, SI = x, BP = y
    ; where Z = x + yi and C = a + bi
    ; DS:[iter] = iterations (counting down to zero)
    ; DS:[endline] = offset of end of current line

    ; Pixel aspect ratio is 1:1.2, so we will use 240x200
    ; pixel region
    ; Moving in x-direction will add 1/240 = 0.0111h
    ; Moving in y-direction will add 1/200 = 0.0148h

    ; set up VRAM segment
    MOV AX, CGA_VIDEO_PAGE1
    MOV ES, AX

    ; offset of first pixel
    MOV DI, DI_EVEN

    ; set a = -0.5/2+eps and b = -0.5/2+eps
    MOV BX, INITIAL_X
    MOV CX, INITIAL_Y

    ; set up offset of line end
    MOV WORD PTR [ENDLINE], DRAW_PORT_WIDTH

PIXEL_LOOP:

    ; Z = 0
    XOR SI, SI
    XOR BP, BP

    MOV [ITER], MAX_ITER

ITER_LOOP:
    ; Z = Z + C (values are divided by 2)
    ADD SI, BX
    ADD BP, CX

    ; multiply by 2 to get actual z value
    SHL SI, 1
    JO OUTSIDE_CIRCLE
    SHL BP, 1
    JO OUTSIDE_CIRCLE

    ; 4x^2
    MOV AX, SI
    IMUL AX
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1

    ; 8xy/2
    MOV AX, SI
    MOV SI, DX
    IMUL BP
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1

    ; 4y^2
    MOV AX, BP
    MOV BP, DX
    IMUL AX
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1

    ; 4x^2 + 4y^2
    ADD SI, DX
    JC OUTSIDE_CIRCLE

    ; 4Z^2/2
    SUB SI, DX
    SHR SI, 1
    SHR DX, 1
    SUB SI, DX

    DEC ITER
    JNZ ITER_LOOP
    JMP DONE_ITER

OUTSIDE_CIRCLE:
    ; draw pixel
    PUSH CX
    MOV AL, ES:[DI]

    MOV AH, BYTE PTR [CURRENT_X]
    AND AH, 3
    MOV CL, AH
    SHL CL, 1
    MOV AH, 6
    SUB AH, CL
    MOV CL, AH

    MOV SI, ITER
    MOV CH, [COLORS + SI]
    AND CH, 3

    SHL CH, CL
    OR AL, CH
    POP CX

    STOSB

    DEC DI

DONE_ITER:
    INC WORD PTR [CURRENT_X]
    MOV AL, BYTE PTR [CURRENT_X]
    AND AL, 3
    CMP AL, 0
    JNZ CHECK_LINE_END
    INC DI

CHECK_LINE_END:
    CMP WORD PTR [CURRENT_X], DRAW_PORT_WIDTH
    JE END_OF_LINE

    ; update a
    ADD BX, DELTA_X

NEXT_LINE:
    CMP CURRENT_Y, DISPLAY_HEIGHT
    JE EXIT_PROGRAM
    JMP PIXEL_LOOP

EXIT_PROGRAM:
    ; wait for keypress
    XOR AH, AH
    INT 16H

    ; change back to text mode
    MOV AX, 3
    INT 10H

    ; terminate program
    INT 20H

END_OF_LINE:
    ; move to start of next line
    ADD DI, (DISPLAY_WIDTH - DRAW_PORT_WIDTH) / 4

    INC CURRENT_Y
    MOV SI, CURRENT_Y
    AND SI, 1
    JNZ ODD_LINE
    MOV SI, CGA_VIDEO_PAGE1
    MOV DI_ODD, DI
    MOV DI, DI_EVEN
    JMP VIDEO_PAGE_DONE

ODD_LINE:
    MOV SI, CGA_VIDEO_PAGE2
    MOV DI_EVEN, DI
    MOV DI, DI_ODD

VIDEO_PAGE_DONE:
    MOV ES, SI

    ; update a and b
    MOV BX, INITIAL_X
    MOV WORD PTR [CURRENT_X], 0
    ADD CX, DELTA_Y 

    ; update endline
    ADD WORD PTR [ENDLINE], DISPLAY_WIDTH

    JMP NEXT_LINE

    ITER           DW 0
    ENDLINE        DW 0
    CURRENT_X      DB 0, 0
    CURRENT_Y      DW 0
    DI_EVEN        DW 0
    DI_ODD         DW 0
    COLORS         DB 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2

CODE ENDS

END START