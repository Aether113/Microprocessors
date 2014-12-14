#include <xc.h>

/*****************************************************
		Function Prototypes
**************************************************** */
void initChip();

/*************************************************
			Initialize the CHIP
**************************************************/
void initChip(){
	PORTA = 0x00;
	TRISA = 0x00;       //PortA as output
	ADCON1 =0x0F;	    //Turn off ADcon
	CMCON = 0x07;	    //Turn off Comparator
	PORTB = 0x00;
	TRISB = 0x00;       //PortB as output
	PORTC = 0x00;
	TRISC = 0x00;
        T2CON = 0x07;       //bit 0-1: Prescale on 16(highest) bit 3: timer ON
        CCP2CON = 0x0F;     //bit 0-3: 11xx -> PWM mode
        CCPR2L = 0x80;      //duty cycle 128/256 = 50%
}


void main() {
    initChip();
    while(1)    //Endless loop
      {

      }
}


