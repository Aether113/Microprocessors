/* 
 * File:   main.c
 *
 * Created on February 9, 2010, 10:53 AM
 */

#include <stdio.h>
#include <stdlib.h>
#include <p33Fxxxx.h>

_FOSCSEL(FNOSC_PRIPLL);
_FOSC(FCKSM_CSDCMD & OSCIOFNC_OFF & POSCMD_XT);
_FWDT(FWDTEN_OFF);

/*
 * 
 */
void delay(void) {
    long i = 524280;
    while(i--)
        ;
}

int main(int argc, char** argv) {
    int counter;

    /* set LEDs (D3-D10/RA0-RA7) drive state low */
    LATA = 0xFF00;
    /* set LED pins (D3-D10/RA0-RA7) as outputs */
    TRISA = 0xFF00;

    while(1) {
        LATA = 0x00;
        delay();

        LATA = 0xFF;
        delay();
    }
    return (EXIT_SUCCESS);
}
