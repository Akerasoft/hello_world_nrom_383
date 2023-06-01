.segment "HEADER"

; NES^Z
.byte $4e, $45, $53, $1a
; 48kB - PRG ROM (first 0x4000 to 0x401F unused, but 0x4020 to 0xFFFF is code and data)
.byte 3         
; 8kB  - CHR ROM
.byte 1

; RAM mirroring - vertical
; SRAM disabled
; mapper 474 (lower 4-bits)
.byte %10100001

; mapper 474 (middle 4-bits)
; NES 2.0 header
; NES is the console
.byte %11011000

; mapper 474 (higher 4-bits)
; submapper 0
.byte %00000001

; larger CHR/PRG rom - zero because not larger
.byte %00000000

; extra PRG RAM not used so 0
.byte %00000000

; CHR RAM not used so 0
.byte %00000000

; CPU Timing - NTSC NES
.byte %00000000

; Extended Console Type - not used zero
.byte %00000000

; Not using Miscellaneous ROMS - not used zero
.byte %00000000

; Default Expansion Device - not used zero
.byte %00000000
