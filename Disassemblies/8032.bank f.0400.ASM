*=$0400
;
;================================================================================
;Commodore 8432 PET Emulator for B-Series
;Original program by N. Keunne, 1984
;
;This is the Menu code for BANK 15
;Disassembled by Steve J. Gray 2025, for porting to CBM-II cartridge
;================================================================================
;
L_0400:
0400: 4C 2B 06        JMP Jump1
0403: 4C 17 06        JMP Jump2
;
L_0406:
0406: 4C 36 04        JMP Jump3
;
L_0409:
0409: 78              SEI
040A: A2 F8           LDX #$F8
040C: 9A              TXS
040D: 20 12 04        JSR SUB_0412
0410: F0 48           BEQ L_045A
;
SUB_0412:
0412: A0 04           LDY #$04
0414: A9 A1           LDA #$A1
0416: 8D F9 01        STA STACK_1F9
0419: 8C FA 01        STY STACK_1FA
041C: A9 49           LDA #$49
041E: 8D FB 01        STA STACK_1FB
0421: 8C FC 01        STY STACK_1FC
0424: A9 5C           LDA #$5C
0426: 8D FD 01        STA STACK_1FD
0429: 8C FE 01        STY STACK_1FE
042C: A0 FF           LDY #$FF
042E: 84 74           STY ZP_74                    ;Pointer $74
0430: C8              INY
0431: 84 73           STY ZP_73                    ;Pointer $73
0433: 84 75           STY $75
;
0435: 60              RTS
;
Jump3:
0436: AE 0F 07        LDX STOR070F
0439: A9 80           LDA #$80
043B: 9D 10 07        STA STOR0710,X
043E: D0 C0           BNE RAM0400
;
L_0440:
0440: A0 03           LDY #$03
0442: B1 73           LDA (ZP_73),Y                ;Pointer $73
0444: 29 10           AND #$10
0446: F0 0E           BEQ L_0456
0448: D0 BC           BNE L_0406
044A: 98              TYA
044B: A6 01           LDX INDREG                   ;IndReg
044D: 8E 0F 07        STX STOR070F
0450: 9D 00 07        STA STOR0700,X
0453: A2 F8           LDX #$F8
0455: 9A              TXS
;
L_0456:
0456: 58              CLI
0457: 4C A7 07        JMP L_07A7
;
L_045A:
045A: 18              CLC
045B: 90 3A           BCC L_0497
045D: 98              TYA
045E: A6 01           LDX INDREG                   ;IndReg
0460: 8E 0F 07        STX STOR070F
0463: 9D 00 07        STA STOR0700,X
0466: A2 F8           LDX #$F8
0468: 9A              TXS
0469: 90 D5           BCC L_0440
046B: A9 04           LDA #$04
046D: 48              PHA
046E: A9 80           LDA #$80
0470: 48              PHA
0471: A0 05           LDY #$05
;
L_0473:
0473: B1 73           LDA (ZP_73),Y                ;Pointer $73
0475: 48              PHA
0476: 88              DEY
0477: 10 FA           BPL L_0473
0479: 68              PLA
047A: A8              TAY
047B: 68              PLA
047C: AA              TAX
047D: 68              PLA
047E: 28              PLP
;
047F: 60              RTS
0480: EA              NOP
0481: 08              PHP
0482: 78              SEI
0483: 48              PHA
0484: 8A              TXA
0485: 48              PHA
0486: 98              TYA
0487: 48              PHA
0488: AD 0F 07        LDA STOR070F
048B: 85 01           STA INDREG                   ;IndReg
048D: A0 00           LDY #$00
;
L_048F:
048F: 68              PLA
0490: 91 73           STA (ZP_73),Y                ;Pointer $73
0492: C8              INY
0493: C0 04           CPY #$04
0495: 90 F8           BCC L_048F
;
L_0497:
0497: AC 0F 07        LDY STOR070F
049A: BE 00 07        LDX STOR0700,Y
049D: 9A              TXS
049E: 98              TYA
049F: 4C F6 FF        JMP KERNALFFF6               ;KERNAL-FFF6
04A2: 8E 0F 07        STX STOR070F
04A5: 98              TYA
04A6: A4 01           LDY INDREG                   ;IndReg
04A8: 8C 1F 07        STY STOR071F
04AB: 99 00 07        STA STOR0700,Y
04AE: A0 05           LDY #$05
;
L_04B0:
04B0: B1 73           LDA (ZP_73),Y                ;Pointer $73
04B2: 99 20 07        STA STOR0720,Y
04B5: 88              DEY
04B6: 10 F8           BPL L_04B0
04B8: 86 01           STX INDREG                   ;IndReg
04BA: A0 03           LDY #$03
;
L_04BC:
04BC: B9 20 07        LDA STOR0720,Y
04BF: 91 73           STA (ZP_73),Y                ;Pointer $73
04C1: 88              DEY
04C2: 10 F8           BPL L_04BC
04C4: B0 D1           BCS L_0497
04C6: BC 00 07        LDY STOR0700,X
04C9: C8              INY
04CA: AD 1F 07        LDA STOR071F
04CD: 91 74           STA (ZP_74),Y                ;Pointer $74
04CF: 88              DEY
04D0: A9 FE           LDA #$FE
04D2: 91 74           STA (ZP_74),Y                ;Pointer $74
04D4: 88              DEY
04D5: A9 02           LDA #$02
04D7: 91 74           STA (ZP_74),Y                ;Pointer $74
04D9: 88              DEY
04DA: AD 25 07        LDA $0725
04DD: 91 74           STA (ZP_74),Y                ;Pointer $74
04DF: 88              DEY
04E0: AD 24 07        LDA $0724
04E3: 91 74           STA (ZP_74),Y                ;Pointer $74
04E5: 88              DEY
04E6: A9 FE           LDA #$FE
04E8: 91 74           STA (ZP_74),Y                ;Pointer $74
04EA: 88              DEY
04EB: A9 71           LDA #$71
04ED: 91 74           STA (ZP_74),Y                ;Pointer $74
04EF: 88              DEY
04F0: 88              DEY
04F1: 98              TYA
04F2: 9D 00 07        STA STOR0700,X
04F5: 38              SEC
04F6: B0 9F           BCS L_0497
;
L_04F8:
04F8: !BYTE $00,$00,$00,$00,$00,$00,$00,$00       ;Zeros
 
;
SUB_0500:
0500: 20 10 05        JSR SUB_0510
0503: 8A              TXA
0504: C9 0A           CMP #$0A
0506: 90 02           BCC L_050A
0508: 69 86           ADC #$86
;
L_050A:
050A: 69 30           ADC #$30
;
LOOP_050C:
050C: 20 D2 FF        JSR CHROUT                   ;KERNAL Print a Character
050F: C8              INY
;
SUB_0510:
0510: B9 80 06        LDA BANNER,Y
0513: D0 F7           BNE LOOP_050C
;
0515: 60              RTS
;
SUB_0516:
0516: 86 01           STX INDREG                   ;IndReg
0518: A0 1F           LDY #$1F
;
L_051A:
051A: B1 73           LDA (ZP_73),Y                ;Pointer $73
051C: 99 20 07        STA STOR0720,Y
051F: 88              DEY
0520: D0 F8           BNE L_051A
0522: A0 04           LDY #$04
;
L_0524:
0524: B9 2B 07        LDA STOR072B,Y
0527: D9 7B 06        CMP STOR067B,Y
052A: D0 03           BNE L_052F
052C: 88              DEY
052D: D0 F5           BNE L_0524
;
L_052F:
;
052F: 60              RTS
;
MenuKey:
0530: 20 CF FF        JSR CHRIN                    ;KERNAL Character Input
;
L_0533:
0533: C9 40           CMP #$40
0535: 90 02           BCC L_0539
0537: E9 08           SBC #$08
;
L_0539:
0539: E9 2F           SBC #$2F
053B: C9 10           CMP #$10
053D: B0 11           BCS L_0550
;
053F: 60              RTS
;
SUB_0540:
0540: 20 30 05        JSR MenuKey
0543: 0A              ASL
0544: 0A              ASL
0545: 0A              ASL
0546: 0A              ASL
0547: 85 71           STA $71
0549: 20 30 05        JSR MenuKey
054C: 05 71           ORA $71
;
054E: 60              RTS
054F: EA              NOP
;
L_0550:
0550: A2 F8           LDX #$F8
0552: 9A              TXS
0553: 58              CLI
0554: 20 12 04        JSR SUB_0412
0557: 20 10 05        JSR SUB_0510
055A: AA              TAX
;
L_055B:
055B: A0 24           LDY #$24
055D: 20 00 05        JSR SUB_0500
0560: 20 16 05        JSR SUB_0516
0563: F0 0A           BEQ L_056F
0565: A0 30           LDY #$30
0567: 20 10 05        JSR SUB_0510
056A: 9D 10 07        STA STOR0710,X
056D: F0 12           BEQ L_0581
;
L_056F:
056F: BD 10 07        LDA STOR0710,X
0572: 10 05           BPL L_0579
0574: A9 12           LDA #$12
;
L_0576:
0576: 20 D2 FF        JSR CHROUT                   ;KERNAL Print a Character
;
L_0579:
0579: B9 30 07        LDA STOR0730,Y
057C: C8              INY
057D: C0 11           CPY #$11
057F: 90 F5           BCC L_0576
;
L_0581:
0581: E8              INX
0582: E0 0F           CPX #$0F
0584: 90 D5           BCC L_055B
0586: A0 35           LDY #$35
0588: 20 10 05        JSR SUB_0510
;
WaitKey:
058B: 20 E4 FF        JSR GETKEYBUF                ;KERNAL Get a key from buffer
058E: F0 FB           BEQ WaitKey
0590: A0 00           LDY #$00
0592: C9 23           CMP #$23
0594: F0 32           BEQ L_05C8
0596: C9 57           CMP #$57
0598: F0 2C           BEQ L_05C6
059A: C9 58           CMP #$58
059C: D0 03           BNE L_05A1
059E: 6C FC FF        JMP ($FFFC)
;
L_05A1:
05A1: 20 33 05        JSR L_0533
05A4: C9 0F           CMP #$0F
05A6: 90 05           BCC L_05AD
05A8: 00              BRK
05A9: EA              NOP
;
L_05AA:
05AA: 4C 50 05        JMP L_0550
;
L_05AD:
05AD: AA              TAX
05AE: 20 16 05        JSR SUB_0516
05B1: D0 F7           BNE L_05AA
05B3: BD 10 07        LDA STOR0710,X
05B6: 10 41           BPL L_05F9
05B8: A0 5C           LDY #$5C
05BA: 20 00 05        JSR SUB_0500
05BD: 5E 10 07        LSR STOR0710,X
05C0: 8E 0F 07        STX STOR070F
05C3: 4C 09 04        JMP L_0409
;
L_05C6:
05C6: A0 02           LDY #$02
;
L_05C8:
05C8: 20 D2 FF        JSR CHROUT                   ;KERNAL Print a Character
05CB: 20 30 05        JSR MenuKey
05CE: AA              TAX
05CF: 84 71           STY $71
05D1: 20 16 05        JSR SUB_0516
05D4: D0 D4           BNE L_05AA
05D6: 20 CF FF        JSR CHRIN                    ;KERNAL Character Input
05D9: C9 20           CMP #$20
05DB: D0 0E           BNE L_05EB
05DD: 20 40 05        JSR SUB_0540
05E0: 8D 29 07        STA STOR0729
05E3: 20 40 05        JSR SUB_0540
05E6: 8D 28 07        STA STOR0728
05E9: 90 0E           BCC L_05F9
;
L_05EB:
05EB: A4 71           LDY $71
05ED: B9 28 07        LDA STOR0728,Y
05F0: 8D 28 07        STA STOR0728
05F3: B9 29 07        LDA STOR0729,Y
05F6: 8D 29 07        STA STOR0729
;
L_05F9:
05F9: A0 5C           LDY #$5C
05FB: 20 00 05        JSR SUB_0500
05FE: A0 FA           LDY #$FA
0600: 38              SEC
0601: AD 28 07        LDA STOR0728
0604: E9 01           SBC #$01
0606: 91 74           STA (ZP_74),Y                ;Pointer $74
0608: C8              INY
0609: AD 29 07        LDA STOR0729
060C: E9 00           SBC #$00
060E: 91 74           STA (ZP_74),Y                ;Pointer $74
0610: 8A              TXA
0611: 5E 10 07        LSR STOR0710,X
0614: 4C F6 FF        JMP KERNALFFF6               ;KERNAL-FFF6
;
Jump2:
0617: A2 F8           LDX #$F8
0619: 9A              TXS
061A: 58              CLI
061B: AE 0F 07        LDX STOR070F
061E: 20 12 04        JSR SUB_0412
0621: 20 16 05        JSR SUB_0516
0624: F0 D3           BEQ L_05F9
0626: 4C 00 04        JMP RAM0400                  ;Free RAM start
0629: AA              TAX
062A: AA              TAX
;
Jump1:
062B: 78              SEI
062C: A9 50           LDA #$50
062E: 8D 00 03        STA IRQVEC_LO                ;IRQ vector LO (FBE9)
0631: A9 06           LDA #$06
0633: 8D 01 03        STA IRQVEC_HI                ;IRQ vector HI (FBE9)
0636: A2 F7           LDX #$F7
0638: 9A              TXS
0639: A9 05           LDA #$05
063B: 8D F8 01        STA STACK_1F8
063E: A9 00           LDA #$00
0640: 85 7A           STA ZP_7A                    ;Zero Page $7A
0642: 85 7B           STA ZP_7B                    ;Zero Page $7B
0644: A9 6F           LDA #$6F
0646: 85 7F           STA ZP_7F                    ;Zero Page $7F
0648: A9 02           LDA #$02
064A: 85 80           STA ZP_80                    ;Zero Page $80
064C: 58              CLI
064D: 4C 50 05        JMP L_0550
0650: AD F8 01        LDA STACK_1F8
0653: C9 04           CMP #$04
0655: F0 03           BEQ L_065A
0657: 4C E9 FB        JMP IRQROUTINE               ;ROM IRQ Routine
;
L_065A:
065A: A9 06           LDA #$06
065C: 48              PHA
065D: A9 67           LDA #$67
065F: 48              PHA
0660: 08              PHP
0661: 48              PHA
0662: 48              PHA
0663: 48              PHA
0664: 4C E9 FB        JMP IRQROUTINE               ;ROM IRQ Routine
0667: 20 40 07        JSR L_0740
066A: 4C A5 FC        JMP IRQFINISH                ;ROM IRQ Finish up
;
L_066D:
066D: !BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA       ;Filler
;
STOR067B:
0675: !BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA           ;Filler
 
;
L_067C:
067C: !BYTE $CE,$CB,$38,$34                       ;ID N. Kuenne '84
 
;
BANNER:
0680: !TEXT $93," *** ",$C2,"-SERIES 8032 "       ;Menu Banner
0694: !TEXT $C5,"MULATOR *** ",$0D,$00            ;Menu Banner
 
06A3: 00              BRK
;
L_06A4:
06A4: !TEXT $0D,$C2,"ANK ",$00                    ;text- Bank
 
;
L_06AB:
06AB: !TEXT " = ",$00                             ;text - "="
 
06AF: 00              BRK
;
L_06B0:
06B0: !TEXT "FREE",$00                            ;text "FREE"
 
;
L_06B5:
06B5: !TEXT $0D,$C2,"ANK ",$C6," = ",$C2,"-SERIES M" ;text-B-Series Monitor
06C9: !TEXT "ONITOR",$0D,$0D,$C2,"ANK ? ",$00     ;text-B-Series Monitor
 
06D9: 00              BRK
06DA: 00              BRK
06DB: 00              BRK
;
L_06DC:
06DC: !TEXT $93,$0D,"### ",$C2,"ANK ",$00         ;text- Bank
 
;
L_06E8:
06E8: !TEXT " ###",$0D,"PRESS ",$D3,$C8,$C9,$C6,$D4,"+",$C3,$C5,$0D ;text-Press SHIFT+CE
06FC: !TEXT $00                                   ;text-Press SHIFT+CE
 
;
L_06FD:
;
STOR0700:
06FD: !BYTE $00,$00,$00,$00,$00,$00,$00,$00       ;zeros
0705: !BYTE $00,$00,$00,$00,$00,$00,$00,$00       ;zeros
;
STOR070F:
;
STOR0710:
070D: !BYTE $00,$00,$00,$00,$00,$00,$00,$00       ;zeros
0715: !BYTE $00,$00,$00,$00,$00,$00,$00,$00       ;zeros
;
STOR071F:
;
STOR0720:
071D: !BYTE $00,$00,$00,$00,$00                   ;zeros
 
;
0722: 40              RTI
;
0723: 40              RTI
0724: 00              BRK
0725: 00              BRK
;
0726: 40              RTI
;
0727: 40              RTI
;
STOR0728:
0728: 00              BRK
;
STOR0729:
0729: 00              BRK
;
072A: 40              RTI
;
STOR072B:
;
072B: 40              RTI
072C: 00              BRK
072D: 00              BRK
;
072E: 40              RTI
;
072F: 40              RTI
;
STOR0730:
0730: 00              BRK
0731: 00              BRK
;
0732: 40              RTI
;
0733: 40              RTI
0734: 00              BRK
0735: 00              BRK
;
0736: 40              RTI
;
0737: 40              RTI
0738: 00              BRK
0739: 00              BRK
;
073A: 40              RTI
;
073B: 40              RTI
073C: 00              BRK
073D: 00              BRK
;
073E: 40              RTI
;
073F: 40              RTI
;
L_0740:
0740: A5 01           LDA INDREG                   ;IndReg
0742: 48              PHA
0743: AD 0F 07        LDA STOR070F
0746: 85 01           STA INDREG                   ;IndReg
0748: A5 D1           LDA KEYBUFIDX                ;KeyBufIndex
074A: F0 51           BEQ L_079D
074C: A9 00           LDA #$00
074E: 85 D1           STA KEYBUFIDX                ;KeyBufIndex
0750: AD 99 03        LDA $0399
0753: C9 1B           CMP #$1B
0755: D0 04           BNE L_075B
0757: A9 04           LDA #$04
0759: D0 0E           BNE L_0769
;
L_075B:
075B: A5 E0           LDA KBMOD                    ;ModKey
075D: 29 32           AND #$32
075F: 49 32           EOR #$32
0761: 4A              LSR
0762: 4A              LSR
0763: 4A              LSR
0764: 4A              LSR
0765: A0 98           LDY #$98
0767: 91 7A           STA (ZP_7A),Y                ;Zero Page $7A
;
L_0769:
0769: A8              TAY
076A: B9 AF 07        LDA $07AF,Y
076D: 85 7C           STA $7C
076F: B9 B4 07        LDA $07B4,Y
0772: 85 7D           STA $7D
0774: A4 E1           LDY KBNORM                   ;NorKey
0776: B1 7C           LDA ($7C),Y
0778: D0 06           BNE L_0780
077A: A4 7C           LDY $7C
077C: C0 80           CPY #$80
077E: F0 DB           BEQ L_075B
;
L_0780:
0780: 48              PHA
0781: A0 9E           LDY #$9E
0783: B1 7A           LDA (ZP_7A),Y                ;Zero Page $7A
0785: 85 76           STA $76
0787: A0 E3           LDY #$E3
0789: B1 7A           LDA (ZP_7A),Y                ;Zero Page $7A
078B: C5 76           CMP $76
078D: 68              PLA
078E: 90 0D           BCC L_079D
0790: A4 76           LDY $76
0792: 91 7F           STA (ZP_7F),Y                ;Zero Page $7F
0794: 8D 99 03        STA $0399
0797: C8              INY
0798: 98              TYA
0799: A0 9E           LDY #$9E
079B: 91 7A           STA (ZP_7A),Y                ;Zero Page $7A
;
L_079D:
079D: A0 98           LDY #$98
079F: A5 E0           LDA KBMOD                    ;ModKey
07A1: 91 7A           STA (ZP_7A),Y                ;Zero Page $7A
07A3: 68              PLA
07A4: 85 01           STA INDREG                   ;IndReg
;
07A6: 60              RTS
;
L_07A7:
07A7: 20 40 07        JSR L_0740
07AA: 78              SEI
07AB: 18              CLC
07AC: 4C 97 04        JMP L_0497
07AF: 00              BRK
;
07B0: 60              RTS
07B1: C0 20           CPY #$20
07B3: 80              ???
07B4: 88              DEY
07B5: 88              DEY
07B6: 88              DEY
07B7: 89              ???
07B8: 89              ???
07B9: FF              ???
07BA: FF              ???
07BB: FF              ???
07BC: FF              ???
07BD: FF              ???
07BE: FF              ???
