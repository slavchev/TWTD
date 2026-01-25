DGROUP GROUP AP500
INCLUDE $APMAC.ASM
NAME AP500
AP500 SEGMENT PUBLIC 'DGROUP'

      ASSUME CS:DGROUP,DS:$SQ
      $PAPL
$AP500 PROC FAR
      JMP    $BEGIN
$CTL DB      0
$LBUF EQU    2058
$BUF DB      $LBUF DUP(?)
      DB     ?
$PTR EQU     WORD PTR $BUF
$NB EQU      WORD PTR $BUF+2
$NELM EQU    WORD PTR $BUF+4
$TYPE EQU    BYTE PTR $BUF+6
$RANK EQU    BYTE PTR $BUF+7
$CR EQU      WORD PTR $BUF+8
$LCB EQU     62
$LTCB EQU    1*$LCB
$LDB EQU     4
$LTDB EQU    1*$LDB

$DAT DB      $LTDB DUP(0)
$DATE LABEL  NEAR
$SHV DB      $LTCB DUP(0)
$SHVE LABEL  NEAR
$SVPT EQU    WORD PTR [BX]
$STPT EQU    WORD PTR [BX+2]
$SVAL EQU    WORD PTR [BX+4]
$SAVBX DW    0
$SAVP3 DW    0
$ONA EQU     BYTE PTR [SI+8]

MATRIX  DW    400 DUP(0)
MATRIX_SIZE  DB 0

DET_WORK  DW    1024 DUP(0)
DET_MSIZE DW    0
DET_RESULT DW   4 DUP(0)
DET_SIGN  DW    1
DET_PREVP DW    1, 0, 0, 0
DET_CURK  DW    0
DET_CURI  DW    0
DET_CURJ  DW    0
DET_KLIMIT DW   0
DET_PIVOT DW    4 DUP(0)
DET_TEMP  DW    4 DUP(0)

ERRMSG   DB    75, 76, 81, 133, 62, 133, 83, 62, 73, 70, 65, 133, 70, 75, 77, 82, 81, 133, 65, 62, 81, 62
ERRMSG_LEN EQU  22

DET_NUMBUF DB   24 DUP(0)
DET_NUMLEN DW   0

$BEGIN: $SAVE
      MOV    $P4,500
      $SVSN
EW:   $SVWA
       INT 3

      LEA    BX,$DAT
      MOV    $CTL,0
E000: MOV    $IFLOT+2,0
E01: CMP     CS:$SVPT,0
      JE     E02
      JMP    E2

E02: $SVSC
    MOV    AX,$IFLOT
    CMP    AX,0
    JNE    E1
E03: TEST   $CTL,1
    JNZ    E030
    ADD    BX,$LDB
    CMP    BX,OFFSET $DATE
    JNE    E01
    MOV    $CTL,1
    JMP    E000
E030: ADD  BX,$LCB
    CMP    BX,OFFSET $SHVE
    JNE    E01
    JMP    EW

E1: MOV    $P3,AX
    MOV    SI,AX
    MOV    SI,[SI]
    MOV    CS:$STPT,SI
    CMP    $ONA,64
    JE     EQ1
    CMP    $ONA,65
    JNE    E02
    TEST   $CTL,1
    JNZ    E02
    JMP    SHORT EQ0
EQ1: TEST  $CTL,1
    JZ     E02
EQ0: $SVSH
    CMP    $IFLOT,2
    JNE    E03
    MOV    AX,$P3
    MOV    CS:$SVPT,AX
    TEST   $CTL,1
    JZ     E03
    MOV    $IFLOT,15
    $SVSA
    JMP    E03

E2: MOV   AX,CS:$SVPT
     MOV  $P3,AX
     MOV  CS:$SAVP3,AX
     MOV  CS:$SAVBX,BX
     $SVSH
     CMP  $IFLOT,2
     JE   E20

E3:  $SVRT
     MOV  CS:$SVPT,0
     JMP  E02

E20: TEST $CTL,1
     JZ   E20DAT
     JMP  E20A
E20DAT:
     $SVPR
     CMP  $IFLOT,-9
     JNE  E20DAT2
     JMP  E3
E20DAT2:
     CMP  $IFLOT,0
     JG   E20DAT3
     JMP  E20B
E20DAT3:
     CALL EAUX
     JNC  E20DAT4
     JMP  E20B
E20DAT4:
     CMP  $RANK,2
     JNE  DATZERO
     MOV  AX,WORD PTR $BUF+8
     CMP  AX,WORD PTR $BUF+10
     JNE  DATZERO
     CMP  AX,20
     JA   DATZERO
     MOV  CS:MATRIX_SIZE,AL
     MOV  CX,$NELM
     PUSH DS
     PUSH CS
     POP  DS
     LEA  SI,$BUF+12
     LEA  DI,MATRIX
DCOPY:
     MOV  AX,[SI]
     MOV  [DI],AX
     ADD  SI,2
     ADD  DI,2
     LOOP DCOPY
     POP  DS
     JMP  E20B
DATZERO:
     MOV  CS:MATRIX_SIZE,0
     MOV  $NB,10
     MOV  $NELM,1
     MOV  $TYPE,1
     MOV  $RANK,0
     MOV  $CR,0
     $SVPW
     MOV  $IFLOT,10
     $SVWR
E20B: JMP E03
E20A:
       $SVPR
     CMP  $IFLOT,-9
     JNE  E20A2
     JMP  E3
E20A2:
     CMP  $IFLOT,0
     JLE  EREAD
     CALL EAUX
     JNC  EQ2
     JMP  ER2
EREAD:
     MOV   BX,CS:$SAVBX
     MOV   AX,CS:$SVAL
     JMP   EFN4
EQ2:

     INC  $NB
     AND $NB,-2
     CMP  $TYPE, 0
     JNE  EQ2_CHKINT
     CMP  $CR, 0080H
     JE   EQ2_CHK1
     JMP  EQ2_INCR
EQ2_CHKINT:
     CMP  $CR, 1
     JE   EQ2_CHK1
     JMP  EQ2_INCR

EQ2_CHK1:
     CMP  CS:MATRIX_SIZE, 0
     JNE  EQ2_CALC
     JMP  EQ2_NODATA

EQ2_CALC:
     CALL CALCDET

     MOV  AX,CS:$SAVP3
     MOV  $P3,AX
     MOV  $NB,26
     MOV  $TYPE,1
     MOV  $RANK,1
     MOV  $NELM,8
     MOV  WORD PTR $BUF+8, 8
     XOR  AH, AH
     MOV  AL, BYTE PTR CS:DET_RESULT
     MOV  WORD PTR $BUF+10, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+1
     MOV  WORD PTR $BUF+12, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+2
     MOV  WORD PTR $BUF+14, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+3
     MOV  WORD PTR $BUF+16, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+4
     MOV  WORD PTR $BUF+18, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+5
     MOV  WORD PTR $BUF+20, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+6
     MOV  WORD PTR $BUF+22, AX
     MOV  AL, BYTE PTR CS:DET_RESULT+7
     MOV  WORD PTR $BUF+24, AX
     PUSH CS
     POP  $P1
     LEA  AX,$BUF
     MOV  $P2,AX
     $SVPW
     MOV  $IFLOT,26
     $SVWR
     JMP  EW

EQ2_NODATA:
     MOV  AX,CS:$SAVP3
     MOV  $P3,AX
     MOV  $NB,32
     MOV  $TYPE,3
     MOV  $RANK,1
     MOV  $NELM,ERRMSG_LEN
     MOV  WORD PTR $BUF+8, ERRMSG_LEN
     PUSH DS
     PUSH CS
     POP  DS
     LEA  SI, ERRMSG
     LEA  DI, $BUF+10
     MOV  CX, ERRMSG_LEN
EQ2_CPYMSG:
     MOV  AL, [SI]
     MOV  [DI], AL
     INC  SI
     INC  DI
     LOOP EQ2_CPYMSG
     POP  DS
     PUSH CS
     POP  $P1
     LEA  AX,$BUF
     MOV  $P2,AX
     $SVPW
     MOV  $IFLOT,32
     $SVWR
     JMP  EW

EQ2_INCR:
     MOV BX,CS:$SAVBX
     MOV AX, $CR
     INC AL
     MOV CS:$SVAL, AX
     JMP EFN4

ER2: MOV  AL,45
EFN4:
     PUSH  AX
     MOV   AX,CS:$SAVP3
     MOV   $P3,AX
     POP   AX
     XOR  AH,AH
     MOV  $NB,10
     MOV  $TYPE,1

       CMP       AL,1
       JA        EFN5
       MOV       $TYPE,0
       ROR       AL,1
EFN5: MOV        $RANK,0
       MOV       $NELM,1
       MOV       $CR,AX
       PUSH      CS
       POP       $P1
       PUSH      AX
       LEA       AX,$BUF
       MOV       $P2,AX
       POP       AX
       $SVPW
       MOV       $IFLOT,10
       $SVWR
       JMP       EW
$AP500 ENDP
EAUX PROC        NEAR
       PUSH      CS
       POP       $P1
       LEA       AX,$BUF
       MOV       $P2,AX
       CMP       $IFLOT,$LBUF
       JA        EAU1
       $SVRD
       CLC
       RET
EAU1: $SVRL
       STC
       RET
EAUX ENDP

CALCDET PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    BP

        FINIT

        XOR     CH, CH
        MOV     CL, CS:MATRIX_SIZE
        MOV     CS:DET_MSIZE, CX

        LEA     SI, MATRIX
        LEA     DI, DET_WORK
        MOV     AX, CX
        MUL     CX
        MOV     CX, AX
CALCCOPYLP:
        MOV     AX, CS:[SI]
        CWD
        MOV     CS:[DI], AX
        MOV     CS:[DI+2], DX
        MOV     CS:[DI+4], DX
        MOV     CS:[DI+6], DX
        ADD     SI, 2
        ADD     DI, 8
        LOOP    CALCCOPYLP

        MOV     WORD PTR CS:DET_SIGN, 1
        MOV     WORD PTR CS:DET_PREVP, 1
        MOV     WORD PTR CS:DET_PREVP+2, 0
        MOV     WORD PTR CS:DET_PREVP+4, 0
        MOV     WORD PTR CS:DET_PREVP+6, 0

        MOV     CX, CS:DET_MSIZE

        CMP     CX, 1
        JNE     CALCNOT1X1
        MOV     AX, WORD PTR CS:DET_WORK
        MOV     WORD PTR CS:DET_RESULT, AX
        MOV     AX, WORD PTR CS:DET_WORK+2
        MOV     WORD PTR CS:DET_RESULT+2, AX
        MOV     AX, WORD PTR CS:DET_WORK+4
        MOV     WORD PTR CS:DET_RESULT+4, AX
        MOV     AX, WORD PTR CS:DET_WORK+6
        MOV     WORD PTR CS:DET_RESULT+6, AX
        JMP     CALCDONE

CALCNOT1X1:
        CALL    BAREISS

CALCDONE:
        POP     BP
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
CALCDET ENDP

BAREISS PROC    NEAR
        MOV     AX, CS:DET_MSIZE
        DEC     AX
        MOV     CS:DET_KLIMIT, AX
        MOV     WORD PTR CS:DET_CURK, 0

BARKLOOP:
        MOV     AX, CS:DET_CURK
        CMP     AX, CS:DET_KLIMIT
        JL      BARCONT1
        JMP     BARDONE
BARCONT1:

        CALL    FINDPIV
        JNC     BARCONT2
        JMP     BARZERO
BARCONT2:

        MOV     AX, CS:DET_CURK
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURK
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI]
        MOV     CS:DET_PIVOT, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+2]
        MOV     CS:DET_PIVOT+2, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+4]
        MOV     CS:DET_PIVOT+4, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+6]
        MOV     CS:DET_PIVOT+6, AX

        MOV     AX, CS:DET_CURK
        INC     AX
        MOV     CS:DET_CURI, AX

BARILOOP:
        MOV     AX, CS:DET_CURI
        CMP     AX, CS:DET_MSIZE
        JL      BARCONT3
        JMP     BARNEXK
BARCONT3:

        MOV     AX, CS:DET_CURK
        INC     AX
        MOV     CS:DET_CURJ, AX

BARJLOOP:
        MOV     AX, CS:DET_CURJ
        CMP     AX, CS:DET_MSIZE
        JL      BARCONT4
        JMP     BARNEXTI
BARCONT4:

        MOV     AX, CS:DET_CURI
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURJ
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     DI, AX

        MOV     AX, CS:DET_CURI
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURK
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX

        PUSH    SI

        FILD    QWORD PTR CS:DET_PIVOT
        FILD    QWORD PTR CS:DET_WORK[DI]
        FMULP   ST(1), ST

        POP     SI
        FILD    QWORD PTR CS:DET_WORK[SI]
        MOV     AX, CS:DET_CURK
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURJ
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX
        FILD    QWORD PTR CS:DET_WORK[SI]
        FMULP   ST(1), ST

        FSUBP   ST(1), ST

        FILD    QWORD PTR CS:DET_PREVP
        FDIVP   ST(1), ST

        FISTP   QWORD PTR CS:DET_WORK[DI]

        INC     WORD PTR CS:DET_CURJ
        JMP     BARJLOOP

BARNEXTI:
        INC     WORD PTR CS:DET_CURI
        JMP     BARILOOP

BARNEXK:
        MOV     AX, CS:DET_PIVOT
        MOV     CS:DET_PREVP, AX
        MOV     AX, CS:DET_PIVOT+2
        MOV     CS:DET_PREVP+2, AX
        MOV     AX, CS:DET_PIVOT+4
        MOV     CS:DET_PREVP+4, AX
        MOV     AX, CS:DET_PIVOT+6
        MOV     CS:DET_PREVP+6, AX

        INC     WORD PTR CS:DET_CURK
        JMP     BARKLOOP

BARDONE:
        MOV     AX, CS:DET_MSIZE
        DEC     AX
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        MOV     BX, CS:DET_MSIZE
        DEC     BX
        ADD     AX, BX
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX

        MOV     AX, WORD PTR CS:DET_WORK[SI]
        MOV     CS:DET_RESULT, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+2]
        MOV     CS:DET_RESULT+2, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+4]
        MOV     CS:DET_RESULT+4, AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+6]
        MOV     CS:DET_RESULT+6, AX

        CMP     WORD PTR CS:DET_SIGN, 0
        JGE     BARRET
        NOT     WORD PTR CS:DET_RESULT
        NOT     WORD PTR CS:DET_RESULT+2
        NOT     WORD PTR CS:DET_RESULT+4
        NOT     WORD PTR CS:DET_RESULT+6
        ADD     WORD PTR CS:DET_RESULT, 1
        ADC     WORD PTR CS:DET_RESULT+2, 0
        ADC     WORD PTR CS:DET_RESULT+4, 0
        ADC     WORD PTR CS:DET_RESULT+6, 0

BARRET:
        RET

BARZERO:
        XOR     AX, AX
        MOV     CS:DET_RESULT, AX
        MOV     CS:DET_RESULT+2, AX
        MOV     CS:DET_RESULT+4, AX
        MOV     CS:DET_RESULT+6, AX
        RET
BAREISS ENDP

FINDPIV PROC    NEAR
        PUSH    BX
        PUSH    CX
        PUSH    SI
        PUSH    DI

        MOV     AX, CS:DET_CURK
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURK
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX

        MOV     AX, WORD PTR CS:DET_WORK[SI]
        OR      AX, WORD PTR CS:DET_WORK[SI+2]
        OR      AX, WORD PTR CS:DET_WORK[SI+4]
        OR      AX, WORD PTR CS:DET_WORK[SI+6]
        JZ      PIVSRCH0
        JMP     PIVOK
PIVSRCH0:
        MOV     CX, CS:DET_CURK
        INC     CX

PIVSRCH:
        CMP     CX, CS:DET_MSIZE
        JL      PIVSRCH1
        JMP     PIVFAIL
PIVSRCH1:

        MOV     AX, CX
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        ADD     AX, CS:DET_CURK
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     DI, AX

        MOV     AX, WORD PTR CS:DET_WORK[DI]
        OR      AX, WORD PTR CS:DET_WORK[DI+2]
        OR      AX, WORD PTR CS:DET_WORK[DI+4]
        OR      AX, WORD PTR CS:DET_WORK[DI+6]
        JNZ     PIVSWAP

        INC     CX
        JMP     PIVSRCH

PIVSWAP:
        NEG     WORD PTR CS:DET_SIGN

        PUSH    CX
        MOV     AX, CX
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     DI, AX

        MOV     AX, CS:DET_CURK
        MOV     BX, CS:DET_MSIZE
        MUL     BX
        SHL     AX, 1
        SHL     AX, 1
        SHL     AX, 1
        MOV     SI, AX
        POP     CX

        PUSH    CX
        MOV     CX, CS:DET_MSIZE
SWAPLP:
        MOV     AX, WORD PTR CS:DET_WORK[SI]
        XCHG    AX, WORD PTR CS:DET_WORK[DI]
        MOV     WORD PTR CS:DET_WORK[SI], AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+2]
        XCHG    AX, WORD PTR CS:DET_WORK[DI+2]
        MOV     WORD PTR CS:DET_WORK[SI+2], AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+4]
        XCHG    AX, WORD PTR CS:DET_WORK[DI+4]
        MOV     WORD PTR CS:DET_WORK[SI+4], AX
        MOV     AX, WORD PTR CS:DET_WORK[SI+6]
        XCHG    AX, WORD PTR CS:DET_WORK[DI+6]
        MOV     WORD PTR CS:DET_WORK[SI+6], AX
        ADD     SI, 8
        ADD     DI, 8
        LOOP    SWAPLP
        POP     CX

PIVOK:
        CLC
        JMP     SHORT PIVRET

PIVFAIL:
        STC

PIVRET:
        POP     DI
        POP     SI
        POP     CX
        POP     BX
        RET
FINDPIV ENDP

DET_TOSTR PROC  NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI

        MOV     AX, CS:DET_RESULT
        MOV     CS:DET_TEMP, AX
        MOV     AX, CS:DET_RESULT+2
        MOV     CS:DET_TEMP+2, AX
        MOV     AX, CS:DET_RESULT+4
        MOV     CS:DET_TEMP+4, AX
        MOV     AX, CS:DET_RESULT+6
        MOV     CS:DET_TEMP+6, AX

        LEA     DI, DET_NUMBUF
        ADD     DI, 23
        MOV     BYTE PTR CS:[DI], 0
        DEC     DI
        XOR     CX, CX

        TEST    WORD PTR CS:DET_TEMP+6, 8000H
        JZ      DTS_POS

        NOT     WORD PTR CS:DET_TEMP
        NOT     WORD PTR CS:DET_TEMP+2
        NOT     WORD PTR CS:DET_TEMP+4
        NOT     WORD PTR CS:DET_TEMP+6
        ADD     WORD PTR CS:DET_TEMP, 1
        ADC     WORD PTR CS:DET_TEMP+2, 0
        ADC     WORD PTR CS:DET_TEMP+4, 0
        ADC     WORD PTR CS:DET_TEMP+6, 0
        MOV     SI, 1
        JMP     SHORT DTS_LOOP

DTS_POS:
        XOR     SI, SI

DTS_LOOP:
        MOV     BX, 10

        XOR     DX, DX
        MOV     AX, CS:DET_TEMP+6
        DIV     BX
        MOV     CS:DET_TEMP+6, AX

        MOV     AX, CS:DET_TEMP+4
        DIV     BX
        MOV     CS:DET_TEMP+4, AX

        MOV     AX, CS:DET_TEMP+2
        DIV     BX
        MOV     CS:DET_TEMP+2, AX

        MOV     AX, CS:DET_TEMP
        DIV     BX
        MOV     CS:DET_TEMP, AX

        ADD     DL, '0'
        MOV     CS:[DI], DL
        DEC     DI
        INC     CX

        MOV     AX, CS:DET_TEMP
        OR      AX, CS:DET_TEMP+2
        OR      AX, CS:DET_TEMP+4
        OR      AX, CS:DET_TEMP+6
        JNZ     DTS_LOOP

        OR      SI, SI
        JZ      DTS_DONE
        MOV     BYTE PTR CS:[DI], '-'
        DEC     DI
        INC     CX

DTS_DONE:
        MOV     CS:DET_NUMLEN, CX

        INC     DI
        LEA     SI, DET_NUMBUF
        PUSH    CX
        LEA     BX, DET_NUMBUF
DTS_COPY:
        MOV     AL, CS:[DI]
        MOV     CS:[BX], AL
        INC     DI
        INC     BX
        LOOP    DTS_COPY
        POP     CX

        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
DET_TOSTR ENDP


AP500 ENDS
       END
