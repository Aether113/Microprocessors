#include <xc.h>

/*****************************************************
		Function Prototypes
**************************************************** */
void initChip();
void interrupt high_ISR();   //high priority interrupt routine
void interrupt low_priority low_ISR();  //low priority interrupt routine, not used in this example
void initTimer();
int  counter = 0;  //gloable variable



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
	INTCON = 0xC0;	// Turn Off global interrupt
        PIE1bits.ADIE = 1;
}

void initTimer(){
    T0CON =0x47;        //Timer0 Control Register
               		//bit7 "0": Disable Timer
               		//bit6 "1": 8-bit timer
               		//bit5 "0": Internal clock
               		//bit4 "0": not important in Timer mode
               		//bit3 "0": Timer0 prescale is assigned
               		//bit2-0 "111": Prescale 1:256
    /*********************************************************
	     Calculate Timer
             F = Fosc/(4*Prescale*number of counting)
	**********************************************************/


    TMR0L = 0x00;    //Initialize the tmier value


    /*Interrupt settings for Timer0*/
    INTCON= 0x20;   /*Interrupt Control Register
               		//bit7 "0": Global interrupt Enable
               		//bit6 "0": Peripheral Interrupt Enable
               		//bit5 "1": Enables the TMR0 overflow interrupt
               		//bit4 "0": diables the INT0 external interrupt
               		//bit3 "0": Disables the RB port change interrupt
               		//bit2 "0": TMR0 Overflow Interrupt Flag bit
                    //bit1 "0": INT0 External Interrupt Flag bit
                    //bit0 "0": RB Port Change Interrupt Flag bit
                     */


    INTCONbits.GIE = 1;    //Enable interrupt
}



/*********************************************************
	Interrupt Handler
**********************************************************/

void interrupt high_ISR()
{
	if(INTCONbits.TMR0IF == 1)
     {
         counter = counter + 1;
         TMR0L = 0x00;    //reload the value to the Timer0
         INTCONbits.TMR0IF=0;     //CLEAR interrupt flag when you are done!!!
     }
}
/*
 *
 */
void main() {
    initChip();
    initTimer();
    while(1)    //Endless loop
      {

        PORTB = counter ;    //Give value to PORTB

      }
}


