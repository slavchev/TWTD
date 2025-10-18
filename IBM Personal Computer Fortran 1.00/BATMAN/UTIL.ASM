READC_FRAME STRUC
    READC_SAVEBP      DW ?
    READC_SAVERET     DD ?
    READC_KEYCODE     DD ?
READC_FRAME ENDS

SELPAL_FRAME STRUC
    SELPAL_SAVEBP      DW ?
    SELPAL_SAVERET     DD ?
    SELPAL_PALETTE     DD ?
SELPAL_FRAME ENDS

VMPROC_FRAME STRUC
    VMPROC_SAVEBP      DW ?
    VMPROC_SAVERET     DD ?
    VMPROC_VIDEOMODE   DD ?
VMPROC_FRAME ENDS

PUTPIX_FRAME STRUC
    PUTPIX_SAVEBP      DW ?
    PUTPIX_SAVERET     DD ?
    PUTPIX_COLOR       DD ?
    PUTPIX_Y           DD ?
    PUTPIX_X           DD ?
PUTPIX_FRAME ENDS

ASMUTIL SEGMENT 'CODE'
    ASSUME CS:ASMUTIL
    GETVM PROC FAR
        PUBLIC GETVM
        PUBLIC READC
        PUSH BP
        MOV BP, SP
        PUSH BX
        MOV AH, 0Fh
        INT 10h
        LES BX, [BP].VMPROC_VIDEOMODE
        MOV ES:[BX], AX
        POP BX
        POP BP
        RET 4
    GETVM ENDP

    SETVM PROC FAR
        PUBLIC SETVM
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        LES BX, [BP].VMPROC_VIDEOMODE
        MOV AX, ES:[BX]
        INT 10h
        POP BX
        POP AX
        POP BP
        RET 4
    SETVM ENDP

    SELPAL PROC FAR
        PUBLIC SELPAL
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        MOV AX, 0B00H
        LES BX, [BP].SELPAL_PALETTE
        MOV BX, ES:[BX]
        INT 10h
        POP BX
        POP AX
        POP BP
        RET 4
    SELPAL ENDP

    DRAWPX PROC FAR
        PUBLIC DRAWPX
        PUSH BP
        MOV BP, SP
        PUSH ES
        PUSH DI
        PUSH AX
        PUSH BX
        PUSH CX        

        XOR DI, DI
        LES BX, [BP].PUTPIX_Y
        MOV AX, ES:[BX]
        SHR AX, 1
        RCR DI, 1

        XCHG AH, AL
        ADD DI, AX
        SHR AX, 1
        SHR AX, 1
        ADD DI, AX

        LES BX, [BP].PUTPIX_X
        MOV CX, ES:[BX]
        ADD DI, CX
        AND CL, 3
        SHR DI, 1
        SHR DI, 1

        LES BX, [BP].PUTPIX_COLOR
        MOV AX, ES:[BX]
        XCHG AH, AL
        MOV AL, 03FH

        SHL CL, 1
        ROR AL, CL
        INC CL
        INC CL
        ROR AH, CL

        MOV BX, 0B800H
        MOV ES, BX
        AND AL, ES:[DI]
        OR AL, AH 
        STOSB

        POP CX
        POP BX
        POP AX
        POP DI
        POP ES
        POP BP
        RET 12
    DRAWPX ENDP

    READC PROC FAR
        PUBLIC READC
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        MOV AX, 0
        INT 16h
        LES BX, [BP].READC_KEYCODE
        MOV ES:[BX], AX
        POP BX
        POP AX
        POP BP
        RET 4
    READC ENDP

ASMUTIL ENDS
END
