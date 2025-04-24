; --------------------------------------------------------
; Commodore PET Emulator Cartridge for CBM-II
; --------------------------------------------------------
; Conversion to cartridge by Steve J. Gray
; Started: 2024-04-05
; Updated: 2025-04-24
; Based on 8432 Emulator by N. Kuenne, from CBUG library.
; Parts of the emulator have been translated to English
; by Steve J. Gray circa 1987.
;
; The 8432 emulator has a small BASIC program that loads
; code into one or more 64K RAM BANKs. This code contains
; CBM PET ROMs which are patched, plus additional code
; support for CBM-II keyboard entry (and maybe more?).
;
; --------------------------------------------------------
; Plan:
;
; * Check available RAM and ROM (128/256K etc).
;   - If 128K+BASIC128 or 256K+BASIC256 use BANK1.
;   - If Extra BANKS use First available (ie:3 or 5)
; * Check keyboard for bypass key
;   - Hold <CBM> to bypass Cart
;   - Hold <SHIFT> to Enter BANK to use
; * Look into modding MENU to load additional PET instances

; --------------------------------------------------------
; Defines
; --------------------------------------------------------

ExeReg = $00		; 6509 Register: BANK where code runs
IndReg = $01    	; 6509 Register: BANK for data: LDA(ZP),Y and STA(ZP),Y


SrcZP    = $64		; Pointer to Source
DstZP    = $66		; Pointer to Destination

SrcBank  = $02
SrcStart = $03
SrcPages = $04
DstBank  = $05
DstStart = $06

ResetVect= $03F8
WarmFlag = $03FA	; Set to $A5


Screen   = $D000  	; Screen RAM

; --------------------------------------------------------
; Output: "filename",format
; Format: CBM = Add load address - for BLOAD cmd.
;         PLAIN = code only      - for burning to ROM.
; --------------------------------------------------------

!TO "v09.prg",plain
; --------------------------------------------------------
; Start of binary
; --------------------------------------------------------
; CBM-II carts are mapped to $2000-$7FFF, and usually start
; at $2000, $4000, or $6000.
; The emulator takes about 22K so we will need to use the
; entire Cartridge space.
; Our boot code starts at $2000 and can be a max of 4 pages!
; The emulator occupies $2400-$7FFF.

*=$2000

; --------------------------------------------------------
; Auto-Start 
; --------------------------------------------------------
; This is the autostart header.

InitC:		JMP ColdStart	;Cold Start
InitW:		JMP WarmStart	;Warm Start

        	!BYTE $43, $C2, $CD, $32	; "CBM2" (2=$2000)

; --------------------------------------------------------
; Proposed Multi-slot manager extension.  I am planning on
; writing an autostart menu system that will go at $1000,
; which when started by the normal system autostart will
; search for autostart headers in the normal cartridge
; space and display a menu and allow for selection.
; This extension is simply a quoted description string that
; can be displayed in the menu for app identification.
;  --------------------------------------------------------

		!BYTE 34			; Quote to signify description string
		!PET "8432 PET Emulator @$2000"	; App Description
		!BYTE 34,0			; End of description

; --------------------------------------------------------
; Cartridge Loader Code
; --------------------------------------------------------
; Code borrowed from Michal Pleban's IEC cart startup
; labels converted to absolute addresses for now...
;
; A normal system initialization is needed so that io chips
; and system memory are set up for proper operation such as
; keyboard input.

ColdStart:
 	sei
        cld
        jsr $F9FB		; Restart routine
        lda #$F0
        sta $00C1		; PgmKeyBuf+1
        jsr $E004		; Initialize Screen
        jsr $FA88		; Find Top of RAM
        jsr $FBA2		; Set Page 3 Vectors
        jsr $E004
	lda #$A5
        ;sta WarmFlag		; WarmStart Flag

WarmStart:
	LDA #15			; Source and Destination is BANK 15
	STA SrcBank		; Set Source from Cartridge
	STA DstBank		; Set Destination to RAM
	JSR CopyMenu

	LDA #1			; Destination BANK (Src still 15) *** TODO: To be configurable!
	STA DstBank
	JSR CopyPET		; Copy PET Code (Keyboard/BASIC/EDIT/KERNAL/Emulator)

	LDA #15
	STA IndReg
	JMP $0400		; Start the Emulator!
	BRK

;------ Setup Menu/Emulator Code $0400-07FF
; (4 pages to BANK15)

CopyMenu:
	LDA #>MENUCODE
	STA SrcStart
	LDA #4			; This is low-mem RAM
	STA DstStart		; Destination $0400
	STA SrcPages		; Copy 4 pages
	JSR CopyRange		; Copy It!
	RTS

;------	Copy PET Code (Keyboard, BASIC, EDIT, KERNAL, and Emulator code
; (88 pages to specified BANK)

CopyPET:
	LDA #>KEYCODE		; Setup for Keyboard code ($8800-8FFF)
	STA SrcStart
	LDA #$88
	STA DstStart		; Destination= $8800
	LDA #8
	STA SrcPages		; Copy 8 pages
	JSR CopyRange		; Copy it!

	LDA #>PETCODE		; Setup for PET code ($B000-FFFF)
	STA SrcStart
	LDA #$B0
	STA DstStart		; Destination = $B000
	LDA #80			; B to F = 5*16
	STA SrcPages		; Copy 80 blocks
	JSR CopyRange		; Copy it!
	RTS

; --------------------------------------------------------
; Copy a block of RAM from Source to Destination
; --------------------------------------------------------
; INPUT: SrcStart, DstStart, and SrcPages.
; USES : SrcZP, DstZP as pointers
; Copies entire Pages. Data must be aligned to PAGE Boundary!
; Only SrcPages is modified.

CopyRange:
	LDA SrcStart		; Source Start Page
	STA SrcZP+1		; Setup Source Pointer
	LDA DstStart		; Destination Start Page
	STA DstZP+1		; Setup Destination Pointer

	LDA #0
	STA SrcZP		; Set Source LO byte
	STA DstZP		; Set Destination LO byte
	TAY			; Zero the index counter
       
CopyLoop:
	LDX SrcBank		; Source BANK
	STX IndReg		; Set 6509 Indirection Register
	LDA (SrcZP),Y		; Read it
	LDX DstBank		; Destination BANK
	STX IndReg		; Set 6509 Indirection Register
	STA (DstZP),Y		; Write it	
	INY			; Next byte in page
	BNE CopyLoop		; Not 0 so loop back
	INC SrcZP+1		; Next Source Page
	INC DstZP+1		; Next Destination Page
	DEC SrcPages		; Are we done?
	BNE CopyLoop		; No, loop back
	RTS

	!BYTE 0,0,0,0,0,0,0,0

	!PET "8432 emulator cartridge for cbm-ii by N. Kuenne",13
	!PET "This cartridge loader (c)2025 steve j. gray",13
	!BYTE 0

; ========================================================
; Emulator Files/Code
; ========================================================
; We have 24K total cartridge ROM $2000-7FFF (96 pages)
; $2000 - The Loader code above here (Max 4 pages)
; $2400 - Emulator code ( 4 pages) to Bank 15
; $2800 - Keyboard code ( 8 pages) to any Bank
; $3000 - PET+Em   code (80 pages) to any Bank

; --------------------------------------------------------
; File: "8032.BANK F.0400"
; Load address removed. Loads to BANK15: $0400-07FF
; CBM-II code for menu.
; --------------------------------------------------------

*=$2400
MENUCODE:
		!BIN "cbm2.f0400.bin"		

; --------------------------------------------------------
; File: "8032kb/1"
; Load address removed. Loads to BANK 1-14 at $8800-$8FFF
; --------------------------------------------------------

*=$2800
KEYCODE:
		!BIN "8032kb1.bin"

; --------------------------------------------------------
; File: "8032.code"
; Load address removed. Loads to BANK 1-14 at $B000-$FFFF
; --------------------------------------------------------

*=$3000
PETCODE:
		!BIN "8032.code.bin"
