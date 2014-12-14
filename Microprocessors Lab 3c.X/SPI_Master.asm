;***********************************************************
;						File Header
;***********************************************************

	title "counter"
	list p=18F2550, r=hex, n=0
	#include	<p18F2550.inc>

COUNT1      equ 0x21
DELAY       equ 0x22
COUNT2      equ 0x23
DATA_IN     equ 0x24

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

	ORG		0x020		; When debugging:0x020; when loading: 0x820

START

	clrf 	PORTA 		; Initialize PORTA by clearing output data latches
	movlw 	0x0F 	    ; Value used to initialize data direction
	movwf 	TRISA 		; Set RA<5:0> as inputs  0000 1111

	clrf 	PORTB 		; Initialize PORTB by clearing output data latches
	movlw 	0x03		; Value used to initialize data direction
	movwf 	TRISB 		; RB<7:1> as outputs and RB0 as input for SDI (has to be RB0)

	clrf	PORTC 		; Initialize PORTC by clearing output data latches
	movlw 	0x00        ; Value used to initialize data direction
	movwf 	TRISC       ; RC<7:0> as output, RC7 is SDO

    movlw   0x07        ;Set TMR2 on. 1/16 prescaler.
    movwf   T2CON
    movlw   0xFF        ;Set comperator (255)
    movwf   PR2

    clrf    SSPSTAT     ;only RB<7:6> writeable: sampling @ middle & transmit on rising edge (all 0)
    clrf    SSPCON1
    movlw   0x35        ;Enable MSSP + set clock TRM2/2
    movwf   SSPCON1

    movlw	0x80		;  GIE = 1    enable interrupts
	movwf	INTCON

	bcf		UCON,3		; to be sure to disable USB module
	bsf		UCFG,3		; disable internal USB transceiver
    clrf    COUNT1
    clrf    COUNT2

    bcf 	PIR1,SSPIF	;clear SPI interrupt flag
	bsf 	PIE1,SSPIE	; enable SPI interrupt enable bit
	bsf  	IPR1,SSPIP  ; high priority
    bsf     RCON,IPEN

    main
    btf
    call    send_data
    call    check_data
    goto    main

send_data
    movlw   b'11010111'
    movff   WREG, SSPBUF
    return

check_data
    clrf    PORTB
    bcf     PIR1,TMR2IF
    BTFSC	PIR1,SSPIF
    call    allesaan
    nop
    return

allesaan
    movlw   b'11111111'
    movff   WREG,PORTB
    
inter_high
    nop
    RETFIE

inter_low
    nop
    retfie

END
