*
* M A T R I X-like screen
*
* Credits :
* strongly inspired by : NEIL KANDALGAONKAR <neilk@neilk.net>
* https://github.com/neilk/apple-ii-matrix
*
* ROM routines
home equ $FC58
text equ $FB2F
cout equ $FDF0
vtab equ $FC22
getln equ $FD6A
bascalc equ $FBC1
crout equ $FD8E ; print carriage return 
clreop equ $FC42 ; clear from cursor to end of page
clreol equ $FC9C ; clear from cursor to end of line
xtohex equ $F944
rdkey equ $FD0C ; wait for keypress
*
* ROM switches
ALTCHARSET0FF equ $C00E 
ALTCHARSET0N equ $C00F
kbd equ $C000
kbdstrb equ $C010
col80off equ $C00C
col80on equ $C00D
col80 equ $C01F 
*
* page 0
ptr equ $06
basl equ $28
cv equ $25
ch equ $24 
wndlft equ $20
wndwdth equ $21
wndtop equ $22
wndbtm equ $23 
prompt equ $33
*
* program equ
cols equ $27 
nbk equ $04 ; change for formula XXXX 
* * * * * * * * *
* MACROS *
* * * * * * * * *
 DO 0
print MAC ; display a 0 terminated string
 ldx #$00 ; in argument
boucle lda ]1,X
 beq finm
 ora #$80
 jsr cout
 inx
 jmp boucle
finm EOM 
*
getlen MAC ; return string length in x
 ldx #$00
loopgetl lda ]1,x
 beq fgetlen
 inx
 jmp loopgetl
fgetlen EOM

get80 MAC ; 80 col : Carry = 1 
 lda col80 ; 40 col : Carry = 0
 bmi do80
 clc
 bcc do40 ; = jmp 
do80 sec
do40 EOM 
*
printc MAC ; dispay a string center
 jmp mainpc
tmppc hex 00
mainpc getlen ]1 ; of the screen
 txa
 lsr ; / 2
 sta tmppc
 get80
 lda #$14 ; = half line
 bcc pc40
 lda #$28
pc40 sec
 sbc tmppc
 tax 
 lda #" " ; fill with spaces
esp jsr cout
 dex
 bne esp
 print ]1
 EOM
*
docr MAC
 lda #$8D
 jsr cout
 EOM
*
dowait MAC
 pha ; save a
 txa 
 pha ; save x 
 tya 
 pha ; save y
*
 ldy ]2
 ldx ]1
wloop dex
 bne wloop
 dey
 bne wloop
*
 pla
 tya ; restore y
 pla
 tax ; restore x
 pla ; restore a
 EOM

 FIN
*
*
*
 org $4000

* INIT : clear screen (printing 24 empty lines) ; init random
 jsr text
 lda #17
 jsr cout ; 40 Columns
 ldx #$18 ; 24 lines
 lda #$8D ; cariage return character
cls jsr cout ; print empty line
 dex
 bne cls
 jsr home
 printc string1
 docr
 docr
 print string2
 docr
 docr
 print string3
 jsr rdkey ; to get seed
 jsr initrandom ; init random generator
 jsr home 
* 
 jsr initK
 bit kbdstrb ; Clear out any data that is already at KBD
 jsr main
 jsr home
 rts
*
* MAIN 
*
main lda #$00 
 sta Kpos ; init. cursor counter 
loop jsr random
 and #$0F 
 bne dispchar ; 1/16 chance of reset
 jsr resetcur
 jmp cycle
dispchar jsr printcur
cycle inc Kpos
 lda Kpos
 cmp #nbk
 beq main
 bit kbd
 bmi endloop ; keypressed ?
 jmp loop ; no : loop
endloop lda kbd
 cmp #$9B ; yes. escape key ?
 beq endofp ; yes : end program 
 cmp #$A0 ; space char.
 bne pause0
 lda fullspeed 
 eor #$01
 sta fullspeed
 bit kbdstrb
 jmp loop
pause0 bit kbdstrb ; no 
pause bit kbd ; wait for keypressed to go on
 bpl pause
 bit kbdstrb
 jmp loop
endofp bit kbdstrb
 rts
*
* dispay a cursor
* 
setoffset ldx #$00
 lda Kpos
 beq offsetok 
offloop inx
 inx
 inx
 sec ; to avoid "dec" 
 sbc #$01 ; not accepted by Merlin 8 
 bne offloop
offsetok rts 

printcur nop
 jsr setoffset ; set x according to Kpos
 lda k,x ; get horizontal pos.
 sta ch
 inx 
 lda k,x ; get vertical pos. 
 cmp #$18 ; screen bottom ?
 bne okprn
 rts
okprn sta cv ; save vert. pos.
 inc k,x ; +1 for next loop
 inx 
 lda k,x ; get flag print/erase
 bne dochar
 lda #" " ; erase
 jsr poke
 jmp printcure
dochar ldy #$60 ; print a char.
 jsr dorandom
 clc 
 adc #$20 ; car : $60..$80
 ora #$80 ; normal (not inverse)
 jsr poke
printcure rts

*
*
poke pha
 lda cv
 jsr bascalc
 ldy ch
 pla 
 sta (basl),y
 lda fullspeed
 bne pokee
 dowait #$00;#$02
pokee rts
*
* reset a cursor
resetcur nop
 jsr setoffset ; set X according to Kpos
reset1 ldy #cols ; ramdom col : 0..cols
 jsr dorandom 
 sta k,x
 inx 
 lda #$00 ; vertical pos. = 0 
 sta k,x 
 inx
 jsr random ; flag 1 or 0
 and #$01
 sta k,x
 lda fullspeed
 bne resetcure
 dowait #$00;#$08
resetcure rts
*
* reset all cursors 
initK nop
 ldx #$00
initloop lda k,x
 cmp #$FF ; last cursor ?
 beq initKe ; yes : rts
 ldy #cols ; ramdom col : 0..cols
 jsr dorandom 
 sta k,x
 inx 
 lda #$00 ; vertical pos. = 0 
 sta k,x 
 inx
 jsr random ; flag 1 or 0
 and #$01
 sta k,x 
 inx
 jmp initloop
initKe rts

*
* return a value between 0..Y in Acc.
dorandom nop
 sty tempo
 jsr random
l1 cmp tempo
 beq dorandome
 bcc dorandome
 sec
 sbc tempo
 jmp l1
tempo hex 00
dorandome rts

* cursors data
* each cursor has 3 bytes : 
* 1/ horizontal postion
* 2/ vertical position
* 3/ Flag : 1:print char. or 0:erase
k hex 000000
 hex 000000
 hex 000000
 hex 000000
 hex FF ; marker for end of cursors 

Kpos hex 00
*
* DATA
*
string1 asc "M A T R I X"
 hex 00
string2 asc "Press a key to start..."
 hex 00
string3 asc "When started, use the spacebar to toggle speed."
fullspeed hex 00
* 
* Random generator
* 
R1 hex 00
R2 hex 00
R3 hex 00
R4 hex 00
*
random ror R4 ; Bit 25 to carry
 lda R3 ; Shift left 8 bits
 sta R4
 lda R2
 sta R3
 lda R1
 sta R2
 lda R4 ; Get original bits 17-24
 ror ; Now bits 18-25 in ACC
 rol R1 ; R1 holds bits 1-7
 EOR R1 ; Seven bits at once
 ror R4 ; Shift right by one bit
 ror R3
 ror R2
 ror
 sta R1
 rts
*
*Here is a routine to seed the random number generator with a
*reasonable initial value:
*
initrandom lda $4E ; Seed the random number generator
 sta R1 ; based on delay between keypresses
 sta R3
 lda $4F
 sta R2
 sta R4
 rts

