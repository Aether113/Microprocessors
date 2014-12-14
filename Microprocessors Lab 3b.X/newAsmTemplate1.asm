;***********************************************************
;						File Header
;***********************************************************

	title "FSM"
	list p=18F2550, r=hex, n=0
	#include	<p18F2550.inc>


COUNT  equ 0x21
DELAY  equ 0x22
DataIn  equ 0x26


;***********************************************************
; 					    Reset Vector
;***********************************************************

	ORG		0x800			; Reset Vector
							; When debugging:0x000; when loading: 0x800
	GOTO	START


;***********************************************************
; 					    Interrupt Vector
;***********************************************************



	ORG     0x808	; Interrupt Vector  HIGH priority
	GOTO	inter_high	; When debugging:0x008; when loading: 0x808
    ORG     0x818	; Interrupt Vector  HIGH priority
	GOTO	inter_low	; When debugging:0x018; when loading: 0x818



;***********************************************************
;				 Program Code Starts Here
;***********************************************************

	ORG		0x820			; When debugging:0x020; when loading: 0x820

START
    ;Configure PORTS
	clrf 	PORTA 		; Initialize PORTA by clearing output data latches
	movlw 	0xFF 		; Value used to initialize data direction
	movwf 	TRISA 		; Set RA<5:0> as inputs  0011 1111

    clrf	PORTB 		; Initialize PORTB by clearing output data latches
	movlw 	0x01 		; Set RB<7:1> as outputs, RB0 is SDI
	movwf 	TRISB

    clrf	 PORTC 		; Initialize PORTC by clearing output data latches
	movlw 	0x00	    ; Value used to initialize data direction. RB7: SDO
	movwf 	TRISC

	movlw 	0x0F 			; Configure A/D for digital inputs 0000 1111
	movwf 	ADCON1          ;

    movlw 	0x07 			; Configure comparators for digital input
	movwf 	CMCON

    ;Configure TMR2
    movlw   b'00000010'     ; Set TMR2 with 1/16 prescaler. Needs to be initialised on B2
    movwf	T2CON
	movlw	0xFF            ; Set comparator to max value
	movwf	PR2
    bsf		T2CON,TMR2ON    ;Initialise timer

    ;set register SSPSTAT&SSPCON1
    clrf    SSPSTAT        ;B7: Sample middle B6: High flanks
    clrf    SSPCON1
    movlw   b'00100011'      ;B7: No collision B6:No Overflow B5: Enable Serial Port
                            ;B4: Idle Low B3-0:set clock TMR2/2
    movwf   SSPCON1

    ;Disable USB
	bcf		UCON,3		; to be sure to disable USB module
	bsf		UCFG,3		; disable internal USB transceiver

main
    btfsc   PORTA,0         ; check RA2, if = 1 --> END, if = 0 -> nop
    goto    main
    nop

    btfsc   PORTA,5         ;check RA3, if it's equal '1' continue
    goto    UP_COUNTER
    goto    DOWN_COUNTER

UP_COUNTER
    incf    COUNT,1
    movf    COUNT,0
    movwf   SSPBUF
    call    check_transmit
    call    delay100
    goto    main


DOWN_COUNTER
    decf    COUNT,1
    movf    COUNT,0
    movwf   SSPBUF
    call    check_transmit
    call    delay100
    goto    main

delay100
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    return

delay
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    call delay1
    return

delay1
    movlw 0xFF   ;WREG = 255

LOOP
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz WREG
    goto LOOP
    return

check_transmit
    movf    SSPSTAT,w
    btfss   WREG,0         ;if 1, transmit completed
    goto    check_transmit      ;continue waiting
    clrf	PORTB 		; Initialize PORTB by clearing output data latches
	movlw 	0x00 		; Set RB<7:0> as outputs
	movwf 	TRISB
    movff   SSPBUF,PORTB       ;Write received data from buffer to DataIn
    clrf	PORTB 		; Initialize PORTB by clearing output data latches
	movlw 	0x01 		; Set RB<7:1> as outputs, RB0 is SDI
	movwf 	TRISB
    return


inter_high
    nop
    RETFIE
inter_low
    nop
    retfie

END