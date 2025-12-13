        IDENTIFICATION DIVISION.
        PROGRAM-ID. REPORT.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
            SELECT DATA-FILE ASSIGN TO DISK
                ORGANIZATION IS LINE SEQUENTIAL.
        DATA DIVISION.
        FILE SECTION.
        FD  DATA-FILE
            LABEL RECORDS ARE STANDARD
            VALUE OF FILE-ID IS "DATA.TXT".
        01  DATA-RECORD.
            05  DATA-LINE PIC X(60).
        WORKING-STORAGE SECTION.
        77  EOF-FLAG PIC X VALUE "N".

        77  KEYCODE PIC 9(5) COMP-0 VALUE 0.
        77  CHARCODE PIC 9(5).

        77  VMODE PIC 9(5) COMP-0 VALUE 0.
        77  VIDEO-MODE PIC 9(5).
        77  START-VIDEO-MODE PIC 9(5).

        77  TMP PIC 9(5).
        77  STR-LENGTH PIC 9(2) VALUE 0.
        01  LANG-TEMP PIC X(10).
        77  LANG-SUBSTR PIC XX.

        77  TOP-LEFT-X      PIC 9(5) COMP-0 VALUE 0.
        77  TOP-LEFT-Y      PIC 9(5) COMP-0 VALUE 0.
        77  BOTTOM-RIGHT-X  PIC 9(5) COMP-0 VALUE 0.
        77  BOTTOM-RIGHT-Y  PIC 9(5) COMP-0 VALUE 170.
        77  BOX-COLOR       PIC 9(5) COMP-0 VALUE 1.

        77  CURSOR-POS-X      PIC 9(2) COMP-0 VALUE 0.
        77  CURSOR-POS-Y      PIC 9(2) COMP-0 VALUE 0.

        77  CGA-PALETTE PIC 9(3) COMP-0 VALUE 257.

        01 JOBS-PER-QUARTER.
            02 LANGUAGE PIC X(10).
            02 YEAR PIC 9(4).
            02 QUARTER PIC 9.
            02 JOBS PIC 9(5).

        01  TOTAL-JOBS-TABLE.
            02  TOTAL-JOBS-ITEM OCCURS 5 TIMES
                    INDEXED BY IDX.
                03 LANGUAGE PIC X(10).
                03 JOBS PIC 9(5).
        77  IDX-NUM PIC 9(5).
        77  MAX-TOTAL-JOBS PIC 9(5) VALUE 0.
        77  TOTAL-JOBS-COUNT PIC 99 VALUE 0.

        01  REPORT-YEAR PIC 9(4) VALUE 2024.

        01  PRINTED-STRING.
            02 PRINTED-STRING-DATA         PIC X(10).
            02 PRINTED-STRING-HEAD
                REDEFINES PRINTED-STRING-DATA PIC 9(1) COMP-0.
        77  PRINTED-STRING-LENGTH      PIC 9(2) COMP-0.

        PROCEDURE DIVISION.
        REPORT-START.
            PERFORM READ-REPORT-DATA.
            IF TOTAL-JOBS-COUNT EQUAL 0
                DISPLAY "NO DATA FOR YEAR " REPORT-YEAR
            ELSE
                PERFORM PRINT-TOTAL-JOBS-TABLE
                PERFORM READ-CHAR
                PERFORM SAVE-VIDEO-MODE
                PERFORM CHANGE-VIDEO-MODE
                PERFORM SET-PALETTE
                PERFORM DRAW-REPORT
                PERFORM READ-CHAR
                PERFORM RESTORE-VIDEO-MODE.
            STOP RUN.

        DRAW-REPORT.
            PERFORM PRINT-REPORT-YEAR.
            PERFORM FIND-MAX-JOBS.
            SET IDX TO 1.
            PERFORM DRAW-REPORT-BAR-AND-FOOTER
                UNTIL IDX > TOTAL-JOBS-COUNT.

        DRAW-REPORT-BAR-AND-FOOTER.
            SET IDX-NUM TO IDX.
            PERFORM DRAW-REPORT-BAR.
            PERFORM PRINT-BAR-FOOTER.
            SET IDX UP BY 1.

        DRAW-REPORT-BAR.
            MOVE IDX-NUM TO BOX-COLOR.
            COMPUTE TOP-LEFT-X =
                (IDX-NUM - 1) * (320 / TOTAL-JOBS-COUNT) + 10.
            COMPUTE BOTTOM-RIGHT-X =
                IDX-NUM * (320 / TOTAL-JOBS-COUNT) - 10.
            COMPUTE TOP-LEFT-Y =
                BOTTOM-RIGHT-Y -
                    (150
                        *
                    JOBS OF TOTAL-JOBS-ITEM(IDX)
                        /
                    MAX-TOTAL-JOBS).
            CALL "SETBOX" USING TOP-LEFT-X, TOP-LEFT-Y,
                BOTTOM-RIGHT-X, BOTTOM-RIGHT-Y, BOX-COLOR.

        PRINT-STRING.
            CALL "PRTSTR" USING 
                PRINTED-STRING-HEAD, PRINTED-STRING-LENGTH.

        PRINT-REPORT-YEAR.
            MOVE 18 TO CURSOR-POS-X.
            MOVE 1 TO CURSOR-POS-Y.
            CALL "CURPOS" USING
                CURSOR-POS-X, CURSOR-POS-Y.
            MOVE REPORT-YEAR TO PRINTED-STRING-DATA.
            MOVE 4 TO PRINTED-STRING-LENGTH.
            PERFORM PRINT-STRING.

        PRINT-BAR-FOOTER.
            MOVE 0 TO STR-LENGTH.
            INSPECT LANGUAGE OF TOTAL-JOBS-ITEM(IDX)
                TALLYING STR-LENGTH
                FOR CHARACTERS BEFORE INITIAL SPACE.
            COMPUTE CURSOR-POS-X =
                (IDX-NUM - 1) * (40 / TOTAL-JOBS-COUNT)
                +
                (40 / TOTAL-JOBS-COUNT - STR-LENGTH) / 2.
            MOVE 22 TO CURSOR-POS-Y.
            CALL "CURPOS" USING
                CURSOR-POS-X, CURSOR-POS-Y.
            MOVE LANGUAGE OF TOTAL-JOBS-ITEM(IDX) TO
                PRINTED-STRING-DATA.
            MOVE STR-LENGTH TO PRINTED-STRING-LENGTH.
            PERFORM PRINT-STRING.

        CHANGE-VIDEO-MODE.
            MOVE 4 TO VIDEO-MODE.
            PERFORM SET-VIDEO-MODE.

        SAVE-VIDEO-MODE.
            PERFORM GET-VIDEO-MODE.
            MOVE VIDEO-MODE TO START-VIDEO-MODE.

        RESTORE-VIDEO-MODE.
            DIVIDE START-VIDEO-MODE BY 256 GIVING TMP.
            MULTIPLY TMP BY 256 GIVING TMP.
            SUBTRACT TMP FROM START-VIDEO-MODE GIVING VIDEO-MODE.
            PERFORM SET-VIDEO-MODE.

        SET-VIDEO-MODE.
            MOVE VIDEO-MODE TO VMODE.
            CALL "SETVM" USING VMODE.
 
        GET-VIDEO-MODE.
            CALL "GETVM" USING VMODE.
            MOVE VMODE TO VIDEO-MODE.

        SET-PALETTE.
            CALL "SETPAL" USING CGA-PALETTE.

        READ-CHAR.
            CALL "READC" USING KEYCODE.
            MOVE KEYCODE TO CHARCODE.

        READ-REPORT-DATA.
            OPEN INPUT DATA-FILE.
            READ DATA-FILE AT END MOVE "Y" TO EOF-FLAG.
            PERFORM READ-REPORT-DATA-LINE UNTIL EOF-FLAG EQUAL "Y".
            CLOSE DATA-FILE.

        READ-REPORT-DATA-LINE.
            INSPECT DATA-LINE REPLACING FIRST SPACE BY ",".
            UNSTRING DATA-LINE
                DELIMITED BY ","
                INTO LANGUAGE OF JOBS-PER-QUARTER,
                    YEAR OF JOBS-PER-QUARTER,
                    QUARTER OF JOBS-PER-QUARTER,
                    JOBS OF JOBS-PER-QUARTER.
            IF YEAR OF JOBS-PER-QUARTER EQUAL REPORT-YEAR
                PERFORM UPDATE-TOTAL-JOBS-TABLE.
            READ DATA-FILE AT END MOVE "Y" TO EOF-FLAG.

        UPDATE-TOTAL-JOBS-TABLE.
            SET IDX TO 1.
            SEARCH TOTAL-JOBS-ITEM
                AT END
                    ADD 1 TO TOTAL-JOBS-COUNT
                    SET IDX TO TOTAL-JOBS-COUNT
                    MOVE LANGUAGE OF JOBS-PER-QUARTER
                        TO LANGUAGE OF TOTAL-JOBS-ITEM(IDX)
                    MOVE JOBS OF JOBS-PER-QUARTER
                        TO JOBS OF TOTAL-JOBS-ITEM(IDX)
                WHEN LANGUAGE OF JOBS-PER-QUARTER
                        EQUAL LANGUAGE OF TOTAL-JOBS-ITEM(IDX)
                    ADD JOBS OF JOBS-PER-QUARTER
                        TO JOBS OF TOTAL-JOBS-ITEM(IDX).

        PRINT-TOTAL-JOBS-TABLE.
            SET IDX TO 1.
            PERFORM PRINT-TOTAL-JOBS-TABLE-ROW
                UNTIL IDX > TOTAL-JOBS-COUNT.

        PRINT-TOTAL-JOBS-TABLE-ROW.
            DISPLAY "Language: " 
                LANGUAGE OF TOTAL-JOBS-ITEM(IDX)
                " Total Jobs: "
                JOBS OF TOTAL-JOBS-ITEM(IDX).
            SET IDX UP BY 1.

        FIND-MAX-JOBS.
            MOVE 0 TO MAX-TOTAL-JOBS.
            SET IDX TO 1.
            PERFORM CHECK-MAX-JOBS
                UNTIL IDX > TOTAL-JOBS-COUNT.

        CHECK-MAX-JOBS.
            IF JOBS OF TOTAL-JOBS-ITEM(IDX) GREATER THAN MAX-TOTAL-JOBS
                MOVE JOBS OF TOTAL-JOBS-ITEM(IDX) TO MAX-TOTAL-JOBS.
            SET IDX UP BY 1.
