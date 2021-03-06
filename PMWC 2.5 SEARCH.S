
 LST OFF

 ORG $DB00
 OBJ $8500


*     SEARCH 2.0
* BY DAVID GALLOWAY
*
SRCHL = $81
SRCHH = $82
CROUT = $FD8E
PRBYTE = $FDDA
END = $C0
LOW = $D0



 CLD

 LDA #LOW
 STA SRCHL
 LDA #/LOW
 STA SRCHH

 LDY #$00
 LDX #$00

CMPARE LDA (SRCHL),Y
 CMP DATA
 BEQ MATCH

INCR INC SRCHL
 BNE CMPARE
 INC SRCHH
 LDA SRCHH
 CMP #END
 BNE CMPARE
 RTS

VRFYLP LDA (SRCHL),Y
 AND MASK,X
 CMP DATA,X
 BNE ZERO
MATCH INY
 NOP
 INX
 CPX LNGTH
 BNE VRFYLP
 LDA SRCHH
 JSR PRBYTE
 LDA SRCHL
 JSR PRBYTE
 LDA #":"
 JSR $FDF0

ZERO LDY #$00
 LDX #$00
 JMP INCR

LNGTH = $DBFF
DATA = $DC00
MASK = $DD00
