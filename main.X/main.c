#include <xc.h>

void initChip(){
	PORTA = 0x00;
	TRISA = 0x00;       //PortA as output
	ADCON1 =0x0F;	    //Turn off ADcon
	CMCON = 0x07;	    //Turn off Comparator
	PORTB = 0x00;
	TRISB = 0x00;       //PortB as output
	PORTC = 0x00;
	TRISC = 0x00;
	INTCON = 0xC0;	// Turn Off global interrupt
        PIE1bits.ADIE = 1;
}


void main()
    {
        initChip();
        while(1)
        {
            PORTBbits.RB0 = 1;
            PORTBbits.RB1 = 1;
        }
    }