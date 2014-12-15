;***********************************************************
;						File Header
;***********************************************************

; Author: Jens Vangindertael & Max Helskens

	title "FSM"
	list p=18F2550, r=hex, n=0
	#include	<p18F2550.inc>

NEW         equ 0x21
OLD         equ 0x22
SHIFTHIGH   equ 0x23
SHIFTLOW    equ 0x24
FLAG        equ 0x25


;***********************************************************
; 					    Reset Vector
;***********************************************************

	ORG		0x000			; Reset Vector
							; When debugging:0x000; when loading: 0x800
	GOTO	START


;***********************************************************
; 					    Interrupt Vector
;***********************************************************

	ORG     0x008       ; Interrupt Vector  HIGH priority
	GOTO	inter_high	; When debugging:0x008; when loading: 0x808
    ORG     0x018       ; Interrupt Vector  HIGH priority
	GOTO	inter_low	; When debugging:0x008; when loading: 0x808

;***********************************************************
;				 Program Code Starts Here
;***********************************************************
    ORG		0x020			; When debugging:0x020; when loading: 0x820

START

    ;Configure PORTS
    clrf 	PORTA 		; clear output data latches
	movlw 	0x3F 		; initialize data direction
	movwf 	TRISA       ; RA<5:0> inputs  0011 1111

    clrf	PORTB 		; clear output data latches
	movlw 	0x00 		; RB<7:1> as outputs, RB0 is SDI
	movwf 	TRISB

    clrf	PORTC 		; clear output data latches
	movlw 	0x00	    ;
	movwf 	TRISC

    movlw 	0x00 		; Configure A/D for digital inputs 0000 1111
	movwf 	ADCON1

    movlw 	0x07 		; Configure comparators for digital input
	movwf 	CMCON

    ;Disable USB
	bcf		UCON,3		; disable USB module
	bsf		UCFG,3		; disable internal USB transceiver

    ;Timer(s) configuration
    CLRF    T0CON
    CLRF    T1CON
    BSF		INTCON, GIE		; Global Interrupt Enable
    BSF     INTCON, PEIE    ; Peripheral interrupts enabled
    BSF     INTCON, TMR0IE  ; Timer 0 interrupt enabled
	BSF		PIE1,  TMR1IE   ; Timer 1 interrupt enabled
    BSF     PIE2,  TMR3IE   ; Timer 3 interrupt enabled

    BSF     T0CON, TMR0ON   ; Timer 0 ON
	BSF		T1CON, TMR1ON	; Timer 1 ON
    BCF     T3CON, TMR3ON   ; Timer 3 ON

    BSF     T0CON, T0PS1    ; Prescaler tmr0 @ 1:16
    BSF     T0CON, T0PS0    ; 12Mhz/(256*256*16) = 11Hz (good enough)
    BCF     T1CON, T1CKPS1  ; Prescaler tmr1 @ 1:2
    BSF     T1CON, T1CKPS0  ; 12Mhz/(256*256*2) = 91Hz (around 100Hz)
                            ; Nog aanpassen zodat exact 100Hz
	CLRF	RCON			; Interrupt priority --> All high

    ;Initialisation

    movlw   0x15            ; predetermined values to let
    movwf   SHIFTHIGH       ; timer1 interrupt at exactly 100 Hz
    movlw   0xA0            ; 12Mhz/(2*60000) = 100Hz so we have to
    movwf   SHIFTLOW        ; shift timer1 5536 up = 0X15A0 (see TMR1_init)

    clrf    WREG

MAIN

    BTFSC   FLAG,0          ;Timer0 overflowed flag set
    CALL    Update_SW
    GOTO    Stepper_FSM

Update_SW                   ; Move PORTA values to NEW

    ;MOVFF   NEW, OLD        ; Move current state to OLD
    ;CLRF    NEW             ; Clear NEW
    ;BTFSC   PORTA,0         ; Check PORTA,0 --> If set write to NEW,0
    ;BSF     NEW,0
    ;BTFSC   PORTA,1         ; Check PORTA,1 --> If set write to NEW,1
    ;BSF     NEW,1
    ;BTFSC   PORTA,2         ; etc...
    ;BSF     NEW,2
    ;BTFSC   PORTA,3
    ;BSF     NEW,3
    ;BCF     FLAG, 0
    MOVLW    b'00000111'
    MOVFF    WREG, NEW
    RETURN

Stepper_FSM

    BTFSS   NEW,0         ; ON/OFF = OFF goto main
    goto    MAIN
    BTFSS   NEW,1           ; MANUAL/AUTO
    goto    MANUAL
    goto    AUTO

MANUAL

AUTO
    BCF     FLAG,1


FSM






inter_high

    clrf    FLAG
    btfsc   INTCON, TMR0IF
    bsf     FLAG,0          ;Timer0 overflowed --> Switch_FSM
    btfsc   PIR1, TMR1IF
    bsf     FLAG,1          ;Timer1 overflowed --> Stepper_FSM
    movff   SHIFTHIGH, TMR1H;Shift TMR1H
    movff   SHIFTLOW, TMR1L ;Shift TMR1L

    BCF     INTCON, TMR0IF  ;clear IF
    BCF     PIR1,   TMR1IF  ;clear IF

    RETFIE

inter_low
    nop
    retfie

END