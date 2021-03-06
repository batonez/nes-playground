.segment "HEADER"
.byte "NES", 26, 2, 1, 0, 0

.segment "CODE"
irq_handler:
  RTI

nmi_handler:
  RTI

reset_handler:
;  SEI
;  CLD
;  LDX #$00
;  STX $2000
;  STX $2001

;vblankwait:
;  BIT $2002
;  BPL vblankwait

  LDX $2002
  LDX #$3f
  STX $2006
  LDX #$00
  STX $2006
  LDA #$29
  STA $2007
  LDA #%00011110
  STA $2001
forever:
  JMP forever

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

;.segment "CHARS"
;.res 8192
;.segment "STARTUP"

