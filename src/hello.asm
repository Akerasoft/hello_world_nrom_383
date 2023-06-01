; As a sample of NROM-368 this is (C) Copyright 2023 Akerasoft.  Based on work by Someone else.  I cannot remember who right now.

.include "ppu.inc"
.include "apu.inc"

.include "nesheader.asm"
.include "hello_chr.asm"

.segment "ROM383DEAD"
.byte 0

.segment "STARTUP"
.segment "CODE"

    jmp start

szHelloString:
.byte $48  ; H
.byte $65  ; e
.byte $6C  ; l
.byte $6C  ; l
.byte $6F  ; o
.byte $2C  ; , (comma)
.byte $20  ; space
.byte $57  ; W
.byte $6F  ; o
.byte $72  ; r
.byte $6C  ; l
.byte $64  ; d
.byte $21  ; !
.byte 0    ; null terminator

szCopyrightString:
.byte $A9  ; copyright
.byte $32  ; 2
.byte $30  ; 0
.byte $32  ; 2
.byte $33  ; 3
.byte $20  ; space
.byte $41  ; A
.byte $6B  ; k
.byte $65  ; e
.byte $72  ; r
.byte $61  ; a
.byte $73  ; s
.byte $6F  ; o
.byte $66  ; f
.byte $74  ; t
.byte $20  ; space
.byte $1   ; lowercase alpha
.byte $13  ; lowercase sigma
.byte 0    ; null terminator

DEFMASK = %00001000 ; background enabled

HELLO_X = 7
HELLO_Y = 12
HELLO_NT_ADDR = NAMETABLE_A + 32*HELLO_Y + HELLO_X

COPYRIGHT_X = 1
COPYRIGHT_Y = 14
COPYRIGHT_NT_ADDR = NAMETABLE_A + 32*COPYRIGHT_Y + COPYRIGHT_X


.macro WAIT_VBLANK
:  bit PPUSTATUS
   bpl :-
.endmacro

start:
    sei
    cld
    ldx #$40
    stx APU_FRAMECTR ; disable IRQ
    ldx #$FF         ; x = 0xFF
    txs              ; initialize stack pointer to 0xFF
    inx              ; make x = 0
    stx PPUCTRL
    stx PPUMASK
    stx APU_MODCTRL

    WAIT_VBLANK ; wait for first frame

    ; clear NES memory
    txa         ; copy zero from x to a
@clr_ram:
    sta $000, x
    sta $100, x
    sta $200, x
    sta $300, x
    sta $400, x
    sta $500, x
    sta $600, x
    sta $700, x
    inx          ; x goes from 0x00 to 0xFF
    bne @clr_ram ; if x overflowed from 0xFF to 0x00 go to next line

    WAIT_VBLANK ; wait for second frame

    ; write to palette
    lda #>BG_COLOR
    sta PPUADDR
    lda #<BG_COLOR
    sta PPUADDR
    lda #BLACK
    sta PPUDATA    ; black background color
    sta PPUDATA    ; palette 0, color = black
    lda #(GREEN | DARK)
    sta PPUDATA    ; color 1 = dark green
    lda #(GREEN | NEUTRAL)
    sta PPUDATA    ; color 2 = neutral green
    lda #(GREEN | LIGHT)
    sta PPUDATA    ; color 3 = light green

    ; call print HELLO_NT_ADDR
    ; place character tiles
    lda #>HELLO_NT_ADDR
    sta PPUADDR
    lda #<HELLO_NT_ADDR
    sta PPUADDR
    lda #>szHelloString
    sta $1
    lda #<szHelloString
    sta $0
    jsr print

    lda #>COPYRIGHT_NT_ADDR
    sta PPUADDR
    lda #<COPYRIGHT_NT_ADDR
    sta PPUADDR
    lda #>szCopyrightString
    sta $1
    lda #<szCopyrightString
    sta $0
    jsr print

@setpal:
    ; set all table A tiles to palette 0
    lda #>ATTRTABLE_A
    sta PPUADDR
    lda #<ATTRTABLE_A
    sta PPUADDR
    lda #0
    ldx #64
@attr_loop:
    sta PPUDATA
    dex
    bne @attr_loop

    ; set scroll position to 0,0
    lda #0
    sta PPUSCROLL ; x = 0
    sta PPUSCROLL ; y = 0
    ; enable display
    lda #DEFMASK
    sta PPUMASK

@game_loop:
    WAIT_VBLANK
    ; do something
    jmp @game_loop



; -----------------
; Print routine
; -----------------
print:
; place character tiles
    ldx #0
@string_loop:
    lda ($0,x)
    beq @exit_print
    sta PPUDATA
    lda #0
    inc $0
    adc $1
    jmp @string_loop

@exit_print:
    rts

; ---------------------------
; System V-Blank Interrupt
; ---------------------------

nmi:
    pha ; push a

    ; refresh scroll position to 0,0
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    ; keep default PPU config
    sta PPUCTRL
    lda #DEFMASK
    sta PPUMASK

    pla ; pull a (aka pop a)

    rti ; exit interrupt

; ---------------------------
; IRQ
; ---------------------------

irq:
    rti ; exit interrupt


.segment "VECTORS"
.word nmi              ; $fffa vblank nmi
.word start            ; $fffc reset
.word irq              ; fffe irq / brk
