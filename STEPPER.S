 LST OFF

ZL = $00
ZH = $01


STARTFLG EQU $C9
LOW EQU $F2
HI EQU $F3
AUTOFLG EQU $F8
DIGIT EQU $F9
JUSTIFY EQU $FA ;0 FOR LEFT, $A0 FOR RIGHT
IN EQU $200
COUT EQU $FDED

*

GETLN = $FD6A

RL = $50
RH = $51
COUNT = $52
DEL = $53
DRV = $54
YVAL = $55
STEP = $56

 JSR $FC58
 JSR PRINT
 ASC "DISK DRIVE STEPPER"
 HEX 8D00
 LDA #5
 JSR GETDRV
 LDA #10
 JSR GETDEL
 JSR PRINT
 ASC " USE THE ARROWS TO CHANGE TO STEP"
 HEX 8D
 ASC "DIRECTION"
 HEX 8D
 HEX 8D
 ASC " HIT 'W' FOR NEW WAIT PERIOD OR 'D' FOR NEW DRIVE"
 HEX 8D00
 LDA $C0E9
 LDA DRV
 ORA #$60
 TAX
 LDA $C08A,X
 LDA #$50
 JSR $FCA8
USTEP LDA #">"
 STA $427
 LDA #$00
 STA STEP
STLP LDA STEP
 AND #$03
 ASL
 ORA #$60
 TAX
 LDA $C081,X
 LDA DEL
 JSR WAIT
 LDA $C080,X
 LDA DEL
 JSR WAIT
 INC STEP
 JMP STLP
 RTS

DSTEP LDA #"<"
 STA $427
 LDA #$03
 STA STEP
STLP1 LDA STEP
 AND #$03
 ASL
 ORA #$60
 TAX
 LDA $C081,X
 LDA DEL
 JSR WAIT
 LDA $C080,X
 LDA DEL
 JSR WAIT
 DEC STEP
 JMP STLP1
 RTS

GETDEL STA $25
 STA YVAL
NOGDEL LDA #$01
 STA $24
 LDA YVAL
 JSR $FC24

 JSR PRINT
 ASC "ENTER WAIT PERIOD BETWEEN STEPS (0-255)"
 HEX 8D
 HEX 00
 JSR IDEC
 BCS NOGDEL
 LDA RH
 BNE NOGDEL
 LDX RL
 STX DEL
 JSR PRDEC
 JSR PRINT
 ASC "  STEP DELAY"
 HEX 8D00
 RTS

GETDRV STA YVAL
 STA $25
NOGDRV LDA #$01
 STA $24
 LDA YVAL
 JSR $FC24

 JSR PRINT
 ASC "ENTER DRIVE NUMBER (0 OR 1)"
 HEX 00
 JSR IDEC
 BCS NOGDRV
 LDA RH
 BNE NOGDRV
 LDX RL
 CPX #02
 BCS NOGDRV
 STX DRV
 JSR PRINT
 ASC "DRIVE NUMBER "
 HEX 00
 LDA #$00
 LDX DRV
 JSR PRDEC
 JSR $FD8E
NOKEY RTS
WAIT JSR $FCA8
 LDA $C000
 BPL NOKEY
 BIT $C010
 CMP #$9B
 BEQ DARG
 CMP #"W"
 BEQ DOW
 CMP #"D"
 BEQ DOD
 CMP #$88
 BEQ DOL
 CMP #$95
 BEQ DOR
 RTS
DARG PLA
 PLA
 LDA $C0E8
 RTS
DOW JSR $FC58
 LDA #5
 JMP GETDEL
DOD JSR $FC58
 LDA #5
 JSR GETDRV
 LDA DRV
 ORA #$60
 TAX
 LDA $C08A,X
 RTS
DOL PLA
 PLA
 JMP DSTEP
DOR PLA
 PLA
 JMP USTEP

IDEC LDA #$DC
 STA $33
 LDA #$00
 STA RH
 STA RL
 JSR GETLN
 DEX
 LDY #$00
MLOOP LDA $200,X
 CMP #$A0
 BEQ SPACE
 CMP #$AD
 BEQ NEG
 EOR #$B0
 CMP #$0A
 BCS BADCHAR
 STA COUNT
 CLC
GRRR DEC COUNT
 BMI FN
 LDA RL
 ADC DTABL,Y
 STA RL
 LDA RH
 ADC DTABH,Y
 STA RH
 BCC GRRR
 RTS
FN INY
SPACE DEX
 BPL MLOOP
 CLC
BADCHAR RTS

NEG LDA RL
 CLC
 EOR #$FF
 ADC #$01
 STA RL
 LDA RH
 EOR #$FF
 ADC #$00
 STA RH
 CLC
 RTS


DTABL DFB 1,10,100,1000,10000
DTABH DFB /1,/10,/100,/1000,/10000



PRDEC STA HI
 STX LOW
 LDX #$04
 STX STARTFLG
NXDIGIT LDA #"0"
 STA DIGIT
SUBTRCT LDA LOW
 CMP NUMLOW,X
 LDA HI
 SBC NUMHI,X
 BCC GETDIG
 STA HI
 LDA LOW
 SBC NUMLOW,X
 STA LOW
 INC DIGIT
 BNE SUBTRCT
GETDIG LDA DIGIT
 INX
 DEX
 BEQ PRDDD
 CMP #"0"
 BEQ CHKFLGS
 STA STARTFLG
CHKFLGS BIT STARTFLG
 BMI PRDDD
 LDA JUSTIFY
 BEQ NXTX
PRDDD JSR COUT
 BIT AUTOFLG ;THESE 4 LINES
 BPL NXTX ;ARE FOR AUTO-LINE
 STA IN,Y ;NUMBERING AND CAN
 INY ;BE DELETED.
NXTX DEX
 BPL NXDIGIT
 RTS

NUMLOW DFB 1
 DFB 10
 DFB 100
 DFB 1000
 DFB 10000

NUMHI DFB >1
 DFB >10
 DFB >100
 DFB >1000
 DFB >10000

CHOUT EQU $FDF0

PRINT LDA #$00
 STA ZL
 PLA
 TAY
 PLA
 STA ZH
 JMP PRINT2

LOOP LDA (ZL),Y
 BEQ DONE
 JSR CHOUT
PRINT2 INY
 BNE LOOP
 INC ZH
 BNE LOOP
DONE LDA ZH
 PHA
 TYA
 PHA
 RTS


