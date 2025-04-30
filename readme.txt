PET Emulator Cartridge For CBM-II B-Series - Steve J. Gray  sjgray@rogers.com
==========================================   www.cbmsteve.ca

STATUS: As of 2025-04-29 - Updated

	* Displays Banks being loaded at top left.
	* Boots to menu.
	* Assembler options for Mode, Bank Range, and Keyboard
        * Add keyboard Select (1-4) and additional keyboard BIN files.
	* Add MAKE.BAT file.
        * Rename some files.
	* New binaries. Example binaries with 3 different modes for $2000 slot.
          (The $4000 and $6000 binaries are common, only the LOADER routine differs)

*** This is in development. Please test if you can and send feedback!


Intro
-----

The original 8432 Emulator was written by N. Kuenne, and can be found on CBUG disk #66.

Sometime in 1987 I found the emulator and enhanced it with the following:

- Add some introductory help text.
- Add prompts for start and end banks.
- Add ability to show directory using "?" as input to keyboard prompt.
- Add prompt for 40-column mode.
- Add DATA for CBM-II CRTC registers to switch screen to 40-column.
- Add standard "80240.PRG" PET program that switches 8032 to 40 column mode.
- Add loop to load files to selected banks. Displays "Loading..." info.


Goals
-----

The goal of this project is to get the "core" of the disk-based "8432" PET Emulator for CBM-II
to run from cartridge, and then enhance it like above. Enhancement ideas:

- Support 40-Column PET. This requires:
	- reprogramming the CRTC controller
	- Using a different PET EditorROM and patching it if required.

- Support multiple CBM-II memory banks
	- Allow loading Emulator into multiple memory banks.

- Compile options for different settings, ie:
	- Manual Start/End banks
	- Auto Start/End banks

- Add startup options
	- Bypass Emulator start with a KEY
	- Jump to Monitor with a KEY

- Relocate menu code at $0F0400 to execute from cartridge space.
	- Will free up this space for other programs.

  NOTE: Not all of these mods may be possible in the cartridge version.


Cartridge Source Code
---------------------

The main file is "PET-EmuCart.asm". This is new code that includes the CBM-II autostart header,
system initialization, and routines to copy blocks of code from cartridge space to BANK RAM memory.
It also includes files/code from the original disk including patched PET ROMs, keyboard support
code, and Emulator code.

The Cartridge will reside from $2000-$7FFF in BANK15 which is all 3 normal cartridge slots
Emulation code can be copied to any 64K RAM BANK, normally BANK1. As well, the Emulation
menu is loaded into BANK15 at $0400-07FF, which is executed to run the emulator.

There is a "Configuration Options" section where you can specify assembly options. Make sure these
are updated before assembling!


Assembling the Source
---------------------

You can assemble a BINary image to burn to ROM, or a PRG file that can be BLOADed.
Make sure to select the right type. Put a ";" at the start of the line for the option
you DO NOT want, and no ";" for the one you DO.

To assemble type: MAKE

When you chose a BIN file you will get a 24K binary. You may need to split it up into 3
separate files for burning to EPROM. I recommend a program called "HxD" to help with this.


Disk Version Files
------------------

These are the files that were included with my enhanced emulator.

NAME                BLKS  DESC
----                ----  ----
"8032EMU-PLUS40"....   6  CBM-II BASIC program/loader

"8032.BANK F.0400"..   4  CBM-II Machine language.
				Loads to BANK 4 @ $0400. Size: 959 bytes.

"8032.CODE".........  81  PET ROMS
				Loads to each bank at $B000: BASIC/EDITOR/EXT EDIT (proxa)/KERNAL. Size: 20K
"8032KB/xxx"........   2  PET Keyboard Translation tables for CBM-II Keyboards.
				Loads to $8800. Size 480 bytes
				Tables:	$8800 ( NORMAL KEYS )
					$8860 ( SHIFTED - KEYS )
					$88C0 ( CTRL - KEYS )
					$8920 ( SHIFT+CTRL - KEYS )
					$8980 ( ESC - KEYS )

"8032.40 COL".......   4  PET "80240 ANYHZ" program to patch PET for 40-col. Added by me.


File: 8032-EMU-PLUS40
---------------------

BASIC Program to load files and start emulator. Modded by me with enhancements.

SYS57952    $E260   - Setup CRTC controller.
POKE55296/7 $D800/1 - CRTC Registers
POKE1807,1  $070F   - ?
POKE209,1   $00D1   - # of keys in buffer = 1
POKE939,49  $03AB   - Put "1" into keyboard buffer [FIX for start BANK!!!]
SYS1024     $0400   - Start Emulator


File: 8032.BANK F.0400
----------------------

6509 binary loaded into BANK15's small RAM space.
Starts up the emulator and controls switching between multiple virtual machines.


File: 8032.CODE
---------------

PET and emulator code

- $8800-8FFF - reserved for Keyboard support code, loaded separately
- $9000-AFFF - reserved for option roms
- $B000-DFFF - BASIC 4
- $E000-E7FF - EDITOR ROM
- $E800-E8FF - IO Area
- $E900-EFFF - Emulator code
- $F000-FFFF - KERNAL


VICE Emulation Testing
----------------------

Cartridge:
	There are 3 binaries which must be loaded to $2000, $4000, $6000.
	This will AutoStart when the VICE is reset.

Softloading:
	Load file:   bload "cbm2pet.prg",p8192
	Do a "POKE 1018,0" to reset the Warmstart Flag at $03FA. 


History
-------

2024-05-28 - Project Start
2025-04-24 - First working binary, tested using my CBM-II ROMCART. Autoload Emulator code to BANK "1". Start by pressing "1".
2025-04-29 - Add configuration options, new keyboard files, added binaries

TODO
----

* Needs to be analyzed to see what ROM code has been patched.
* Investigate support for alternate Editor ROMS.
* Investigate support for 4032 ROMS or 40-col routines.
* Investigate programming the screen for 40/80 automatically per BANK.
* Idea: Mod the BANK15 Menu code to allow loading available BANKS
