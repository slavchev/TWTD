CURPOS_FRAME STRUC
    CURPOS_SAVEBP      DW ?
    CURPOS_SAVERET     DD ?
    CURPOS_Y           DW ?
    CURPOS_X           DW ?
CURPOS_FRAME ENDS

READC_FRAME STRUC
    READC_SAVEBP      DW ?
    READC_SAVERET     DD ?
    READC_KEYCODE     DD ?
READC_FRAME ENDS

SETPAL_FRAME STRUC
    SETPAL_SAVEBP      DW ?
    SETPAL_SAVERET     DD ?
    SETPAL_PALETTE     DW ?
SETPAL_FRAME ENDS

VMPROC_FRAME STRUC
    VMPROC_SAVEBP      DW ?
    VMPROC_SAVERET     DD ?
    VMPROC_VIDEOMODE   DW ?
VMPROC_FRAME ENDS

SETBOX_FRAME STRUC
    SETBOX_SAVEBP      DW ? ;saved caller's bp
                       DW ? ;caller's ip
                       DW ? ;caller's cs reg
    SETBOX_COLOR       DW ?
    SETBOX_Y2          DW ?
    SETBOX_X2          DW ?
    SETBOX_Y1          DW ?
    SETBOX_X1          DW ?
SETBOX_FRAME ENDS


PRTSTR_FRAME STRUC
    PRTSTR_SAVEBP      DW ?
    PRTSTR_SAVERET     DD ?
    PRTSTR_LENGTH      DW ?
    PRTSTR_STR         DW ?
PRTSTR_FRAME ENDS


ASMUTIL SEGMENT 'CODE'
    ASSUME CS:ASMUTIL, DS:ASMUTIL
    PRTSTR PROC FAR
        PUBLIC PRTSTR
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI
        MOV BX, [BP].PRTSTR_LENGTH
        MOV BX, [BX]
        XCHG BH, BL
        MOV DI, BX
        MOV SI, [BP].PRTSTR_STR
        MOV AH, 3
        MOV BH, 0
        INT 10h
    PRINT_LOOP:
        CMP DI, 0
        JZ PRINT_DONE
        MOV AH, 2
        MOV BH, 0
        INT 10h
        MOV AH, 0Ah
        LODSB
        MOV BH, 0
        MOV BL, 07h
        MOV CX, 1
        INT 10h
        INC DL
        DEC DI
        JMP PRINT_LOOP
    PRINT_DONE:
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        POP BP
        RET 4
    PRTSTR ENDP


    CURPOS PROC FAR
        PUBLIC CURPOS
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        PUSH DX
        MOV AH, 2         ; Set cursor position function
        MOV BX, [BP].CURPOS_Y   ; Row
        MOV BX, [BX]
        MOV DH, BH
        MOV BX, [BP].CURPOS_X      ; Column
        MOV BX, [BX]
        MOV DL, BH
        MOV BH, 0           ; Page 0
        INT 10H             ; BIOS video interrupt
        POP DX
        POP BX
        POP AX
        POP BP
        RET 4
    CURPOS ENDP

    GETVM PROC FAR
        PUBLIC GETVM
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH DI
        MOV AH, 0Fh
        INT 10H
        XCHG AH, AL                     ;fix endianness
        MOV DI, [BP].VMPROC_VIDEOMODE
        MOV [DI], AX
        POP DI
        POP AX
        POP BP
        RET 2
    GETVM ENDP

    SETVM PROC FAR
        PUBLIC SETVM
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        MOV BX, [BP].VMPROC_VIDEOMODE
        MOV AX, [BX]                    ;fix...
        XCHG AH, AL                     ;endianness
        INT 10h
        POP BX
        POP AX
        POP BP
        RET 2
    SETVM ENDP

    SETPAL PROC FAR
        PUBLIC SETPAL
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH BX
        MOV AX, 0B00H
        MOV BX, [BP].SETPAL_PALETTE
        MOV BX, [BX]
        XCHG BH, BL
        INT 10h
        POP BX
        POP AX
        POP BP
        RET 2
    SETPAL ENDP

    READC PROC FAR
        PUBLIC READC
        PUSH BP
        MOV BP, SP
        PUSH AX
        PUSH DI
        MOV AX, 0
        INT 16h
        XCHG AH, AL                     ;fix endianness
        MOV DI, [BP].READC_KEYCODE
        MOV [DI], AX
        POP DI
        POP AX
        POP BP
        RET 2
    READC ENDP

    SETBOX PROC FAR
        PUBLIC SETBOX
        PUSH BP
        MOV BP, SP
        ; save registers
        PUSH SI
        PUSH DI
        PUSH DX
        PUSH BX
        PUSH CX
        PUSH AX
        MOV AX, 0B800h
        MOV ES, AX
        ; determine byte position for start
        ; get y coordinate
        MOV BX, [BP].SETBOX_Y1      ; get starting y-coordinate
        MOV AX, [BX]
        XCHG AH, AL                 ;fix endianness
        MOV AH, AL      ; replicate for odd/even rank
        AND AX, 01FEh   ; just one bit gets moved
        SAL AX, 1       ; times 4
        SAL AX, 1       ; times 8
        SAL AX, 1       ; times 16
        MOV DI, AX      ; addresd gets 16 times y-coordinate
        AND DI, 7FFh    ; not the odd/even bit
        SAL AX, 1       ; times 32
        SAL AX, 1       ; times 64
        ADD DI, AX      ; address gets 80 times y-coordinate
        ; add in x contribution
        MOV BX, [BP].SETBOX_X1  ; get x-coordinate
        MOV AX, [BX]
        XCHG AH, AL             ;fix endianness
        SAR AX, 1   ; divide
        SAR AX, 1   ; by 4
        ADD DI, AX  ; beginning offset
        ; count for outer loop
        MOV BX, [BP].SETBOX_Y2; ending y-coordinate
        MOV CX, [BX]
        XCHG CH, CL                 ;fix endianness
        MOV BX, [BP].SETBOX_Y1  ; minus starting y-coordinate
        MOV AX, [BX]
        XCHG AH, AL             ;fix endianness
        SUB CX, AX ; minus starting y-coordinate
        INC CX     ; plus one
        ; count for inner loop
        MOV BX, [BP].SETBOX_X2  ; ending x-coordinate
        MOV AX, [BX]
        XCHG AH, AL             ;fix endianness
        MOV SI, AX
        SAR SI, 1   ; divide
        SAR SI, 1   ; by 4
        MOV BX, [BP].SETBOX_X1 ; starting x-coordinate
        MOV AX, [BX]
        XCHG AH, AL            ;fix endianness
        SAR AX, 1   ; divide
        SAR AX, 1   ; by 4
        SUB SI, AX  ; take the difference
        ; get the color
        MOV BX, [BP].SETBOX_COLOR       ; get the color
        MOV BX, [BX]
        XCHG BH, BL
        ;AND BX, 3           ; just between 0 and 3
        AND BX, 7           ; just between 0 and 7
        MOV DL, CS:[CBYTES+BX]  ; look up for color pattern
        ; determine mask for start and ending bytes
        MOV BX, [BP].SETBOX_X1          ; starting byte
        MOV BX, [BX]
        XCHG BH, BL            ;fix endianness
        AND BX, 3           ; just the pixel position
        SAL BX, 1           ; times 2
        SAL BX, 1           ; times 4
        PUSH BX
        MOV BX, [BP].SETBOX_X2          ; ending byte
        MOV AX, [BX]        
        XCHG AH, AL            ;fix endianness
        POP BX
        AND AX, 3           ; just the pixel position
        ADD BX, AX          ; 4*starting + ending
        SAL BX, 1           ; 8*starting + 2*ending
        MOV BX, CS:[XTABLE+BX]  ; look up the masks
        ; set up the masked color bytes
        MOV DH, DL  ; color for left byte
        MOV AH, DL  ; color for middle byte
        AND DX, BX  ; mask left and right color bytes
        CLD ; forward
    SBOXLOOP:
        PUSH CX ; save count of outer loop
        PUSH DI ; save initial byte position
        MOV CX, SI
        ; check for only one byte
        MOV AL, BH      ; get the mask
        JCXZ SBOXLOOP2  ; if ending byte coincides
        ; color leftmost byte of the scan line
        NOT AL              ; reverse the mask for clearing
        AND AL, ES:[DI]     ; get byte from memory and clear pixels
        OR AL, DH           ; put color in place
        STOSB               ; put byte in place
        ; check for just two bytes
        DEC CX          ; count the byte
        JCXZ SBOXLOOP1  ; done?
        ; color middle bytes of the scan line
        MOV AL, AH  ; color for middle bytes
        REP STOSB   ; put middle bytes in place
        ; handle rightmost byte of the scan line
        ; come here if two or more bytes
    SBOXLOOP1:
        MOV AL, 0FFH    ; set full mask
        ; in any case come here to adjust masks
    SBOXLOOP2:
        AND AL, BL  ; bring in right part of masked
        AND DL, AL  ; clear left part of color if needed
        ; color the byte
        NOT AL          ; reverse the mask for clearing
        AND AL, ES:[DI] ; get byte from memory and clear pixels
        OR AL, DL       ; put pixels in the byte
        STOSB           ; put byte back in video READC_FRAME
        ; compute next scan line
        POP DI          ; restore address of the left side of box
        TEST DI, 2000H  ; odd or even line?
        JZ SBOXLOOP3    ; skip if even
        ADD DI, 80      ; add 80 bytes per line
    SBOXLOOP3:
        XOR DI, 2000H   ; changes banks in any case
        POP CX          ; restore count for outer loop
        LOOP SBOXLOOP   ; next scan line
        ; restore registers
        POP AX
        POP CX
        POP BX
        POP DX
        POP DI
        POP SI
        POP BP
        RET 10
    SETBOX ENDP

    XTABLE  DW 0FFC0H, 0FFF0H, 0FFFCH, 0FFFFH
            DW 03FC0H, 03FF0H, 03FFCH, 03FFFH
            DW 00FC0H, 00FF0H, 00FFCH, 00FFFH
            DW 003C0H, 003F0H, 003FCH, 003FFH
    CBYTES  DB 00000000b    ; Color 0: 00 00 00 00 (background/black)
            DB 01010101b    ; Color 1: 01 01 01 01 (cyan)
            DB 10101010b    ; Color 2: 10 10 10 10 (magenta)
            DB 11111111b    ; Color 3: 11 11 11 11 (white)
            DB 01100110b    ; Color 4: mixed cyan and magenta
            DB 10111011b    ; Color 5: mixed magenta and white
            DB 01110111b    ; Color 6: mixed cyan and white
            DB 10001000b    ; Color 7: mixed magenta and black

ASMUTIL ENDS
END
