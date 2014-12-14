;***********************************************************
;						File Header
;***********************************************************

; Author: Jens Vangindertael & Max Helskens

	title "FSM"
	list p=18F2550, r=hex, n=0
	#include	<p18F2550.inc>

NEW    equ 0x21
OLD    equ 0x22


;***********************************************************
; 					    Reset Vector
;***********************************************************

	ORG		0x000			; Reset Vector
							; When debugging:0x000; when loading: 0x800
	GOTO	START


;***********************************************************
; 					    Interrupt Vector
;***********************************************************

	ORG     0x008	; Interrupt Vector  HIGH priority
	GOTO	inter_high	; When debugging:0x008; when loading: 0x808
    ORG     0x018	; Interrupt Vector  HIGH priority
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
    BSF     T0CON, TMR0ON   ; Timer 0 ON
	BSF		T1CON, TMR1ON	; Timer 1 ON
	CLRF	RCON			; Interrupt priority --> All high

    ;Initialisation

    clrf    WREG

    

MAIN

    CALL FSM
    GOTO MAIN

FSM

    goto FSM

inter_high
    ADDLW   0x01
    BCF     INTCON, TMR0IF  ;clear IF
    BCF     PIR1,   TMR1IF  ;clear IF
    RETFIE

inter_low
    nop
    retfie



    END