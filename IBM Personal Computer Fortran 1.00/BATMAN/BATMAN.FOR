$STORAGE:2
        PROGRAM GREET
        INTEGER ORGVM, VM
        INTEGER WIDTH, HEIGHT
        REAL XMIN, XMAX, YMIN, YMAX
        COMMON /RESOLU/ WIDTH, HEIGHT, XMIN, XMAX, YMIN, YMAX

        REAL X, AX, STEP, DX
        REAL VAL, YTOP, YBOT, Y, INSIDE, T
        REAL FACT1, FACT2, FACT3
        REAL TEMP1
        INTEGER YELLOW

        WIDTH = 320
        HEIGHT = 200
        XMIN = -7.0
        XMAX = 7.0
        YMIN = -5.0
        YMAX = 5.0
        STEP = 0.007
        YELLOW = 3
        FACT1 = (3.0*SQRT(33.0) - 7.0)/112.0
        FACT2 = 6.0*SQRT(10.0)/7.0
        FACT3 = 3.0*SQRT(10.0)/7.0

        CALL GETVM(ORGVM)
        CALL SETVM(4)
        CALL SELPAL(256)

        X = XMIN
100     CONTINUE
        IF (X .GT. XMAX) GOTO 200

        AX = ABS(X)
        IF (AX .LE. 7.0) THEN
            TEMP1 = X/7.0
            VAL = 1.0 - TEMP1*TEMP1
            IF (VAL .GE. 0.0 .AND. AX .GT. 3.0) THEN
                YTOP = 3.0 * SQRT(VAL)
                YBOT = -YTOP
                IF (YTOP .GT. YMIN .AND. YTOP .LT. YMAX) THEN
                    CALL PLOTPT(X, YTOP, YELLOW)
                ENDIF
                IF (YBOT .GT. YMIN .AND. YBOT .LT. YMAX) THEN
                    CALL PLOTPT(X, YBOT, YELLOW)
                ENDIF
            ENDIF
        ENDIF

        TEMP1 = ABS(ABS(X) - 2.0) - 1.0
        INSIDE = 1.0 - TEMP1 * TEMP1
        IF (INSIDE .GE. 0.0) THEN
            Y = ABS(X/2.0) - FACT1*X*X - 3.0 + SQRT(INSIDE)
            IF (Y .GT. YMIN .AND. Y .LT. YMAX) THEN
                CALL PLOTPT(X, Y, YELLOW)
            ENDIF
        ENDIF

        IF (AX .GT. 0.75 .AND. AX .LT. 1.0) THEN
            Y = 9.0 - 8.0*AX
            IF (Y .GT. YMIN .AND. Y .LT. YMAX) THEN
                CALL PLOTPT(X, Y, YELLOW)
            ENDIF
        ENDIF
      
        IF (AX .GT. 0.5 .AND. AX .LT. 0.75) THEN
            Y = 3.0*AX + 0.75
            IF (Y .GT. YMIN .AND. Y .LT. YMAX) THEN
                CALL PLOTPT(X, Y, YELLOW)
            ENDIF
        ENDIF

        IF (AX .LT. 0.5) THEN
            Y = 2.25
            CALL PLOTPT(X, Y, YELLOW)
        ENDIF

        IF (AX .GT. 1.0) THEN
            T = 4.0 - (AX - 1.0) * (AX - 1.0)
            IF (T .GE. 0.0) THEN
                Y = FACT2 + (1.5 - 0.5*AX) - FACT3*SQRT(T)
                IF (Y .GT. YMIN .AND. Y .LT. YMAX) THEN
                    CALL PLOTPT(X, Y, YELLOW)
                ENDIF
            ENDIF
        ENDIF

        X = X + STEP
        GOTO 100
200     CONTINUE

        CALL READC(B)
        VM = MOD(ORGVM, 256)
        CALL SETVM(VM)
        END

        SUBROUTINE PLOTPT(X, Y, COLOR)
        REAL X, Y
        INTEGER COLOR

        INTEGER WIDTH, HEIGHT
        REAL XMIN, XMAX, YMIN, YMAX
        COMMON /RESOLU/ WIDTH, HEIGHT, XMIN, XMAX, YMIN, YMAX

        INTEGER SX, SY
        REAL T

        IF (X .LT. XMIN .OR. X .GT. XMAX) RETURN
        IF (Y .LT. YMIN .OR. Y .GT. YMAX) RETURN

        T = (X - XMIN) / (XMAX - XMIN)
        SX = INT(T * (WIDTH - 1) + 0.5)
        
        T = (Y - YMIN) / (YMAX - YMIN)
        SY = HEIGHT - 1 - INT(T * (HEIGHT - 1) + 0.5)
        
        IF  ((SX .GE. 0) .AND. (SX .LT. WIDTH)
     &  .AND. (SY .GE. 0) .AND. (SY .LT. HEIGHT)) THEN
            CALL DRAWPX(SX, SY, COLOR)
        ENDIF
        END
