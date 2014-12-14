#include <xc.h>

/*****************************************************
		Function Prototypes
**************************************************** */
//void initChip();
void interrupt high_ISR();   //high priority interrupt routine
void interrupt low_priority low_ISR();  //low priority interrupt routine, not used in this example


/*****************************************************
		Global variables
**************************************************** */



/*************************************************
			Initialize the CHIP
**************************************************/
void initChip(){
        INTCONbits.GIE = 0;	// Turn Off global interrupt

        PORTA = 0x00;
	TRISA = 0xFF;       //PortA as input
	PORTB = 0x00;
	TRISB = 0x00;       //PortB as output
	PORTC = 0x00;
	TRISC = 0x00;

        ADCON0 = 0x01;     //7-6 unimplemented
                           //5-2 channel
                           //0 GO/DONE (in progress/idle)
                           //0 On bit (enable/disable)


	ADCON1 = 0x0E;		//7-6 unimplemented
                                //5 Voltage ref config bit
                                //4 Voltage ref config bit
                                //3-0 A/D configure bits

        ADCON2 = 0x3D;		//left justified,t clock select Fosc/64 and 20 TAD
                                //0011 1110
	CMCON = 0x07;	    //Turn off Comparator


        PIR1bits.ADIF=0;	//Clear A/D Converter Interrupt Flag bit
        PIE1bits.ADIE=1;	//set A/D Converter Interrupt Enable bit

        INTCONbits.GIE = 1;	// Turn On global interrupt
	INTCONbits.PEIE = 1;// Turn on periphereal interupts
	ADCON0bits.GO_DONE = 1; //start conversion

}


/*********************************************************
	Interrupt Handler
**********************************************************/

void interrupt high_ISR()
{
	if(PIR1bits.ADIF ==1){

		PORTB = ADRESH;
		ADCON0bits.GO_DONE = 1; //start conversion again
		PIR1bits.ADIF=0;	//Clear A/D Converter Interrupt Flag bit

	}
}


void main() {
    initChip();

   while(1)    //Endless loop
      {

       // PORTB = analogValue ;    //Give value to PORTB

      }


}