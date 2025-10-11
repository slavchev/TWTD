UTILCODE SEGMENT PARA PUBLIC 'CODE'
    GETVM PROC FAR
        PUBLIC GETVM
        PUSH BX
        MOV AH, 0Fh
        INT 10h
        POP BX
        RET
    GETVM ENDP
    GETCH PROC FAR
        PUBLIC GETCH
        MOV AX, 0
        INT 16h
        RET
    GETCH ENDP
UTILCODE ENDS
END
