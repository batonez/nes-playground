;;; Size of PRG in units of 16 KiB.
PRG_NPAGE = 1
;;; Size of CHR in units of 8 KiB.
CHR_NPAGE = 1
;;; INES mapper number.
MAPPER = 0
;;; Mirroring (0 = horizontal, 1 = vertical)
MIRRORING = 1

;;; PPU registers.
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

;;; Other IO registers.
OAMDMA    = $4014
APUSTATUS = $4015
JOYPAD1   = $4016
JOYPAD2   = $4017

.segment "INES"
  .byte $4e, $45, $53, $1a
  .byte PRG_NPAGE 
  .byte CHR_NPAGE
  .byte ((MAPPER & $0f) << 4) | (MIRRORING & 1)
  .byte MAPPER & $f0


.segment "VECTOR"
  .addr nmi
  .addr reset
  .addr irq

.segment "CHR0a"
  .incbin "graphics.chr"

.segment "CODE"
nmi:
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI

irq:
  rti

reset:
  sei     ; Disable interrupts
  cld     ; Clear decimal mode
  ldx #$ff
  txs     ; Initialize SP = $FF
  inx
  stx PPUCTRL   ; PPUCTRL = 0
  stx PPUMASK   ; PPUMASK = 0
  stx APUSTATUS   ; PPUSTATUS = 0

;; PPU warmup, wait two frames, plus a third later.
;; http://forums.nesdev.com/viewtopic.php?f=2&t=3958
warmup1:
  bit PPUSTATUS
  bpl warmup1

warmup2:
  bit PPUSTATUS
  bpl warmup2

;; Zero ram.
  txa
zeroram:
  sta $000, x
  sta $100, x
  sta $200, x
  sta $300, x
  sta $400, x
  sta $500, x
  sta $600, x
  sta $700, x
  inx
  bne zeroram

;; Final wait for PPU warmup.
warmup3:
  bit PPUSTATUS
  bpl warmup3

;; Game
; Beep
;  lda #$01    ; enable pulse 1
;  sta $4015
;  lda #$08    ; period
;  sta $4002
;  lda #$02
;  sta $4003
;  lda #$bf    ; volume
;  sta $4000

; Graphics
  ; write a palette
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #$29
  STA PPUDATA
  LDA #$19
  STA PPUDATA
  LDA #$09
  STA PPUDATA
  LDA #$0f
  STA PPUDATA

  ; write sprite data
  LDA #$70
  STA $0200 ; Y-coord of first sprite
  LDA #$05
  STA $0201 ; tile number of first sprite
  LDA #$00
  STA $0202 ; attributes of first sprite
  LDA #$80
  STA $0203 ; X-coord of first sprite

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  jmp forever

