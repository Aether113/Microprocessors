;***********************************************************
;						File Header
;***********************************************************

	title "FSM"
	list p=18F2550, r=hex, n=0
	#include	<p18F2550.inc>

COUNT1  equ 0x21
DELAY  equ 0x22
COUNT2 equ 0x23

;***********************************************************
; 					    Reset Vector
;***********************************************************

	ORG		0x800			; Reset Vector
							; When debugging:0x000; when loading: 0x800
	GOTO	START


;***********************************************************
; 					    Interrupt Vector
;***********************************************************



	ORG     0x808       ; Interrupt Vector  HIGH priority
	GOTO	inter_high	; When debugging:0x008; when loading: 0x808
    ORG     0x818       ; Interrupt Vector  HIGH priority
	GOTO	inter_low	; When debugging:0x008; when loading: 0x808



;***********************************************************
;				 Program Code Starts Here
;***********************************************************

	ORG		0x820			; When debugging:0x020; when loading: 0x820

START

	clrf 	PORTA 		; Initialize PORTA by clearing output data latches
	movlw 	0x21	; Value used to initialize data direction
	movwf 	TRISA 		; Set RA<5:0> as inputs  0011 1111
	movlw 	0x0F        ; Configure A/D for digital inputs 0000 1111
	movwf 	ADCON1 		;
    movlw 	0x07 		; Configure comparators for digital input
	movwf 	CMCON
	clrf 	PORTB 		; Initialize PORTB by clearing output data latches
	movlw 	0x00 		; Value used to initialize data direction
	movwf 	TRISB 		; Set PORTB as output
	clrf	PORTC 		; Initialize PORTC by clearing output data latches
	movlw 	0x00        ; Value used to initialize data direction
	movwf 	TRISC

	bcf		UCON,3		; to be sure to disable USB module
	bsf		UCFG,3		; disable internal USB transceiver
    clrf    COUNT1
    movlw   0x00
    movwf   COUNT1
    movlw   0x00
    movwf   COUNT2

main
    btfsc   PORTA,0         ; check RA2, if = 1 --> END, if = 0 -> nop
    goto    main
    nop

    btfsc   PORTA,3         ; check RA2, if = 1 --> RING, if = 0 -> nop
    goto    RING
    nop

    btfsc   PORTA,5         ;check RA3, if it's equal '1' continue
    goto    UP_COUNTER
    goto    DOWN_COUNTER

UP_COUNTER
    incf    COUNT1,1
    movf    COUNT1,0
    movwf   PORTB
    call    delay100
    goto    main


DOWN_COUNTER
    decf    COUNT1,1
    movf    COUNT1,0
    movwf   PORTB
    call    delay100
    goto    main

RING
    incf    COUNT2,1
    btfsc   COUNT2,3
    call    CLEAR
    call    CHECK1
    call    delay100
    goto    main

CLEAR
    movlw   0x00
    movwf   COUNT2
    return

CHECK1
    btfsc   COUNT2,0
    goto    CHECK2      ;1 -> mogelijke waarden: 2,4,6,8
    goto    CHECK3      ;0 -> mogelijke waarden: 1,3,5,7
CHECK2
    btfsc   COUNT2,1
    goto    CHECK4      ;1 -> mogelijke waarden: 4,8
    goto    CHECK5      ;0 -> mogelijke waarden: 2,6
CHECK3
    btfsc   COUNT2,1
    goto    CHECK6      ;1 -> mogelijke waarden: 3,7
    goto    CHECK7      ;0 -> mogelijke waarden: 1,5
CHECK4
    btfsc   COUNT2,2
    goto    RETURN8
    goto    RETURN4
CHECK5
    btfsc   COUNT2,2
    goto    RETURN6
    goto    RETURN2
CHECK6
    btfsc   COUNT2,2
    goto    RETURN7
    goto    RETURN3
CHECK7
    btfsc   COUNT2,2
    goto    RETURN5
    goto    RETURN1
RETURN1
    movlw   0x01
    movwf   PORTB
    return
RETURN2
    movlw   0x02
    movwf   PORTB
    return
RETURN3
    movlw   0x04
    movwf   PORTB
    return
RETURN4
    movlw   0x08
    movwf   PORTB
    return
RETURN5
    movlw   0x10
    movwf   PORTB
    return
RETURN6
    movlw   0x20
    movwf   PORTB
    return
RETURN7
    movlw   0x40
    movwf   PORTB
    return
RETURN8
    movlw   0x80
    movwf   PORTB
    return

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

inter_high
    nop
    RETFIE
inter_low
    nop
    retfie

END








