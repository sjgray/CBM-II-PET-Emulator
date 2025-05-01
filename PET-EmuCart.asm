; --------------------------------------------------------
; Commodore PET Emulator Cartridge for CBM-II
; --------------------------------------------------------
; Conversion to cartridge by Steve J. Gray
; Started: 2024-04-05
; Updated: 2025-04-30
;
; Based on 8432 Emulator by N. Kuenne, from CBUG library.
; Parts of the emulator have been translated to English
; by Steve J. Gray circa 1987.

;---------------------------------------------------------
; Configuration Options
;---------------------------------------------------------

Banner = 1	; 0=No, 1=Yes 	- Display Banner?
NoMenu = 1	; 0=No, 1=Yes	- Exit without starting Emulator?

Mode = 3	; 0=Load to NONE		(future option - do not use!!!)
		; 1=Load to PROGRAM space 	(usually BANK 1)
		; 2=Load to RANGE 		(specified below)
		; 3=Load to ALL RAM BANKS
		; 4=Load to EXPANSION (smart)	(If available, otherwise works like Mode 1)

BankStart = 5	; Start BANK	- Which Bank RANGE to Load? 
BankEnd   = 14	; End   BANK

Keyboard  = 1   ; 1=Normal	- Keyboard translation matrix
		; 2=?
		; 3=DIN
		; 4=Alternate


; --------------------------------------------------------
; Defines
; --------------------------------------------------------

ExeReg = $00		; 6509 Register: BANK where code runs
IndReg = $01    	; 6509 Register: BANK for data: LDA(ZP),Y and STA(ZP),Y

SrcZP    = $64		; Pointer to Source
DstZP    = $66		; Pointer to Destination

SrcBank  = $02		; Source Bank (usually 15)
SrcStart = $03		; Source Start Page
SrcPages = $04		; Source Pages to copy
DstBank  = $05		; Destination Bank (any free memory bank)
DstStart = $06		; Destination Start Page
RangeS   = $07		; Range Start
RangeE   = $08		; Range End

TopSBank = $41		; ( 65) Top System Memory (2/4 depending on BASIC ROM) ## Only valid if BASIC initialized ##
BotMBank = $035A	; (858) Bottom of Memory  (normally 1 for B-series, ie: BASIC Program BANK)
TopMBank = $0357        ; (855) Top ACTUAL memory bank; 2 to E depending on RAM installed

ResetVect= $03F8	; Point to BASIC ROM
WarmFlag = $03FA	; Set to $A5 at COLD boot

SCREEN   = $D000  	; Screen RAM in BANK 15
BASIC	 = $8000	; BASIC start/initialization
PRINT    = $FFD2	; KERNAL Print character routine

; --------------------------------------------------------
; Output: "filename",format
; Format: CBM   = PRG file with load address - for BLOAD
;         PLAIN = BIN file with code only    - for ROM cart
; --------------------------------------------------------

!TO "cbm2pet.bin",plain
;!TO "cbm2pet.prg",cbm

; --------------------------------------------------------
; Start of binary
; --------------------------------------------------------
; CBM-II carts are mapped to $2000-$7FFF, and usually start
; at $2000, $4000, or $6000.
; The emulator takes about 22K so we will need to use the
; entire Cartridge space.
; Our boot code starts at $2000 and can be a max of 8 pages!
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
		!PET "pet emulator @$2000"	; App Description
		!BYTE 34,0			; End of description

; --------------------------------------------------------
; Cartridge Loader Code
; --------------------------------------------------------
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
	jsr $E004		; Initialize Screen

;	-- Set Reset vector to BASIC start @ $8000

	lda #<BASIC		; BASIC Start  LO
	sta ResetVect		; Reset Vector LO
	lda #>BASIC		; BASIC Start  HI
	sta ResetVect+1		; Reset Vector HI

;	-- Set Flags for WarmStart/ColdStart

	lda #$A5		; Byte to indicate COLDSTART completed
        sta WarmFlag		; WarmStart Flag
	lda #$5A		; Byte to indicate WARMSTART valid
	sta WarmFlag+1		; WarmStart Valid

;	-- Detect BASIC ROM 128/256 here since BASIC is not initialized yet

	LDX #2			; Assume BASIC 128
	LDA $8001		; Read BASIC ROM.  $8001 will contain $27 or $89
	CMP #$27		; Is it?
	BEQ SetBAS		; Yes, skip ahead
	LDX #4			; No, must be BASIC 256
SetBAS	STX TopSBank		; Set Top System BANK

	!IF Banner=1 {
		jsr PrintMsg	; Display banner
	}

; --------------------------------------------------------
; Load Menu
; --------------------------------------------------------

	LDA #"M"		; M=Menu
	STA SCREEN		; put on screen
	LDA #15			; Source and Destination is BANK 15
	STA SrcBank		; Set Source from Cartridge
	STA DstBank		; Set Destination to RAM
	JSR CopyMenu

; --------------------------------------------------------
; Handle MODE options to copy Emulator 
; --------------------------------------------------------
; Mode 0 = do not load banks (manual load via menu - TODO!)
 
	!IF Mode=0 {
		JMP WarmStart
	}

; --------------------------------------------------------
; Mode 1 = Load to BASIC program space (BANK 1)

	!IF Mode=1 {
		LDA BotMBank		; First RAM Bank (B-series=1, P=series=0)
		STA DstBank		; Set destination BANK
		ADC #48			; Convert to number
		STA SCREEN+1		; Display it
		JSR CopyPET		; Copy PET Code (Keyboard/BASIC/EDIT/KERNAL/Emulator)
	}

; --------------------------------------------------------
; Mode 2 = Load RANGE (specified below)

	!IF Mode=2 {
		LDA #BankStart		; Start BANK
		STA DstBank		; Write it for copy
RangeLoop:
		LDA DstBank		; Load for ADC
		ADC #48			; Convert to number
		STA SCREEN+1		; Display it
		JSR CopyPET		; Copy PET Code (Keyboard/BASIC/EDIT/KERNAL/Emulator)		
		LDA DstBank		; Load for compare
		CMP #BankEnd		; Compare to End BANK
		BEQ WarmStart		; Yes, we are done
		INC DstBank		; Next BANK
		BNE RangeLoop		; Loop back for more
	}

; --------------------------------------------------------
; Mode 3 = Load ALL RAM BANKS

	!IF Mode=3 {
		LDA TopMBank		; Last RAM BANK
		STA RangeE		; Set as Range End
		LDA BotMBank		; First RAM BANK
		STA DstBank		; Start at First BANK

RLoop		LDA DstBank		; Get it so we can convert to number
		ADC #48			; Convert to number
		STA SCREEN+1		; Display it

		JSR CopyPET		; Copy PET Code (Keyboard/BASIC/EDIT/KERNAL/Emulator)		
		LDA DstBank		; Load for compare
		CMP RangeE		; Compare to Range End BANK
		BEQ WarmStart		; Yes, we are done
		INC DstBank		; Next BANK
		BNE RLoop		; Loop back for more
	}


; --------------------------------------------------------
; Mode 4 = Smart Mode.
; If BASIC128 or BASIC256 with matching RAM use BANK1
; If BASIC128 with 256K RAM use BANKs 3 and above
; If Expansion RAM then fill all available BANKs.
;
; TopSBank $41   = Top SYSTEM memory bank: 2 or 4 depending on BASIC ROM (128K or 256K)
; TopMBank $0357 = Top ACTUAL memory bank; 2 to E depending on RAM installed
; BotMBank $035A = Bottom of Memory (normally 1 for B-series, ie: BASIC Program BANK)


	!IF Mode=4 {
		LDA BotMBank		; Bottom Bank (Usually 1)
		STA RangeS		; Default start
		STA RangeE		; Default end
		LDA TopSBank		; Get TOP BASIC
		CMP TopMBank		; Get TOP Memory
		BEQ DoRange		; Equal so no extra Memory

		LDX TopSBank		; Not equal, so must be RAM above
		INX			; Use next free BANK
		STX RangeS		; Set as End Range

DoRange		LDA RangeS		; Get Start Range
		STA DstBank		; Set as Destination
		CLC			; Clear Carry

RRLoop		LDA DstBank		; Get it so we can convert to number
		ADC #48			; Convert to number
		STA SCREEN+1		; Display it

		JSR CopyPET		; Copy PET Code (Keyboard/BASIC/EDIT/KERNAL/Emulator)		
		LDA DstBank		; Load for compare
		CMP RangeE		; Compare to Range End BANK
		BEQ WarmStart		; Yes, we are done
		INC DstBank		; Next BANK
		BNE RRLoop		; Loop back for more
	}


; --------------------------------------------------------
; Start The Emulator / WarmStart
; --------------------------------------------------------

WarmStart:

	!IF NoMenu=1 {
		JMP (ResetVect)	; Start BASIC
	} else {
		JMP $0400	; Start the Emulator!
	}
	BRK

; --------------------------------------------------------
; Setup Menu Code $0400-07FF   (4 pages to BANK15)
; --------------------------------------------------------
; This is the core of the emulation. It is always copied.

CopyMenu:
	LDA #>MENUCODE		; Point to Menu code
	STA SrcStart		; Set Source Page
	LDA #4			; This is low-mem RAM and number of pages to copy
	STA DstStart		; Set Destination $0400
	STA SrcPages		; Set 4 pages to copy
	JSR CopyBlock		; Copy It!
	RTS

; --------------------------------------------------------
; Setup PET Code  (88 pages to specified BANK)
; --------------------------------------------------------
; Sets up Keyboard, BASIC, EDIT, KERNAL, and Emulator code in specified BANK

CopyPET:
	LDA #>KEYCODE		; Point to Keyboard code ($8800-8FFF)
	STA SrcStart		; Set Source Page
	LDA #$88		; 88 pages to copy
	STA DstStart		; Destination = $8800
	LDA #8
	STA SrcPages		; Copy 8 pages
	JSR CopyBlock		; Copy it!

	LDA #>PETCODE		; Setup for PET code ($B000-FFFF)
	STA SrcStart		; Set Source Page
	LDA #$B0		; Set Destination Page
	STA DstStart		; Destination = $B000
	LDA #80			; B to F = 5*16
	STA SrcPages		; Copy 80 pages
	JSR CopyBlock		; Copy it!
	RTS

; --------------------------------------------------------
; Copy a block of Memory from Source to Destination
; --------------------------------------------------------
; INPUT: SrcStart, DstStart, and SrcPages.
; USES : SrcZP, DstZP as pointers
; Copies entire Pages. Data must be aligned to PAGE Boundary!
; Only SrcPages is modified.

CopyBlock:
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


; --------------------------------------------------------
; Print Banner Message
; --------------------------------------------------------

!IF Banner=1 {

PrintMsg
	LDY #0

BLoop	LDA BMsg,Y
	BEQ BExit
	JSR PRINT
	INY
	BNE BLoop
BExit   RTS
}

	!BYTE 0,0,0,0,0,0,0,0

BMsg	!BYTE 13,13
	!PET "pet emulator for cbm-ii.",13
	!PET "original 8432 emulator by n kuenne.",13
	!PET "adapted to cartridge by steve j. gray 20250430.",13,13

	!IF NoMenu=1 { !PET "sys1024 to start",13 }

	!BYTE 0

; ========================================================
; Emulator Files/Code
; ========================================================
; We have 24K total cartridge ROM $2000-7FFF (96 pages)
; $2000 - The Loader code above here (Max 4 pages)
; $2400 - Emulator code ( 4 pages) to Bank 15
; $2800 - Keyboard code ( 8 pages) to any RAM Bank
; $3000 - PET+Em   code (80 pages) to any RAM Bank

; --------------------------------------------------------
; File: "8032.BANK F.0400"
; Load address removed. Loads to BANK15: $0400-07FF
; CBM-II code for menu.
; --------------------------------------------------------

*=$2400
MENUCODE:
		!BIN "cbm2.f0400.bin"		

; --------------------------------------------------------
; File: "8032kb*"
; Load address removed. Loads to BANK 1-14 at $8800-$8FFF
; --------------------------------------------------------

*=$2800
KEYCODE:
		!IF Keyboard=1 { !BIN "8032kb1.bin" }
		!IF Keyboard=2 { !BIN "8032kb2.bin" }
		!IF Keyboard=3 { !BIN "8032kbd.bin" }
		!IF Keyboard=4 { !BIN "8032kbalt.bin" }

; --------------------------------------------------------
; File: "8032code"
; Load address removed. Loads to BANK 1-14 at $B000-$FFFF
; --------------------------------------------------------

*=$3000
PETCODE:
		!BIN "8032code.bin"
