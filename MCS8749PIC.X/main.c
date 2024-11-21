/*
    MCS8749PIC 8749 manipulator
    Target: PIC16F18313 on MCS8749
    Compiler: MPLAB XC8 2.50
    Author: Tetsuya Suzuki
    2024/11/11 MIT license

    [CAUTION] MPLAB SNAP can write but cannot rewrite
 */

#include <xc.h>

// CONFIG1
#pragma config FEXTOSC = OFF    // External Oscillator not enabled
#pragma config RSTOSC = HFINT32    // HFINTOSC with 2x PLL
#pragma config CLKOUTEN = OFF    // CLKOUT function is disabled
#pragma config CSWEN = ON    // Writing to NOSC and NDIV is allowed
#pragma config FCMEN = ON    // Fail-Safe Clock Monitor is enabled

// CONFIG2
#pragma config MCLRE = OFF    // MCLR internally disabled
#pragma config PWRTE = OFF    // PWRT disabled
#pragma config WDTE = OFF    // WDT disabled; SWDTEN is ignored
#pragma config LPBOREN = OFF    // ULPBOR disabled
#pragma config BOREN = OFF      // Brown-out Reset disabled
#pragma config BORV = LOW    // Brown-out voltage (Vbor) set to 2.45V
#pragma config PPS1WAY = ON    // The PPSLOCK bit can be cleared and set only once
#pragma config STVREN = ON    // Stack Overflow or Underflow will cause a Reset
#pragma config DEBUG = OFF    // Background debugger disabled

// CONFIG3
#pragma config WRT = OFF    // Write protection off
#pragma config LVP = OFF    // Low Voltage Programming Disabled

// CONFIG4
#pragma config CP = OFF    // User NVM code protection disabled
#pragma config CPD = OFF    // Data NVM code protection disabled

#define _XTAL_FREQ 24000000 // for __delay_ms @24MHz
#define SS_INTERVAL 250 // SS mode interval 250msec
#define PRESS_LONG 31000 // Long press 1sec
#define PRESS_CHAT 1550 // Chattering 50msec

void __interrupt() ISR(void){
    unsigned int count;
    
    if(INTE == 0 || INTF == 0) //  External interrupt only
        return;

    // External interrupt
    INTF = 0; // Flag clear

    // Read TMR1
    count = TMR1; // Get count
    if(TMR1IF == 1) // Check overflow
        count = 0xffff; // Max count
    
    // Debounce
    if(count < PRESS_CHAT) // Chattering
        return; // Not care
    
    // TMR1 reset
    TMR1ON = 0; // TMR1 stop
    TMR1 = 0; // TMR1 clear
    TMR1IF = 0; // Flag clear
    
    // Switch pressed
    if(INTEDG == 0){
        INTEDG = 1; // Rising edge
        TMR1ON = 1; // TMR1 start
        return;
    }
 
    // Switch released
    if(count > PRESS_LONG){  // Long press -> Reset
        LATA2 = 0; // Reset
        __delay_ms(10); // Reset time
        LC1G4POL = 1; // Run mode
        LATA2 = 1; // Release reset
    } else
    // Normal press -> Mode change
    LC1G4POL = !LC1G4POL; // Mode change

    // Switch released common
    INTEDG = 0; // Falling edge
    TMR1ON = 1; // TMR1 start
}

void main(void) {
    // System clock
    OSCFRQbits.HFFRQ = 5; // 24MHz

    // RA0 setup for XTAL1
    ANSA0 = 0; // Disable analog function
    TRISA0 = 0; // Set as output
    RA0PPS = 0x08;   //RA0->CWG1:CWG1A;

    // RA1 setup for XTAL2
    ANSA1 = 0; // Disable analog function
    TRISA1 = 0; // Set as output
    RA1PPS = 0x09;   //RA1->CWG1:CWG1B;

    // RA2 setup for RESET
    ANSA2 = 0; // Disable analog function
    LATA2 = 0; // Reset
    TRISA2 = 0; // Set as output

    // RA3 setup for read SW
    WPUA3 = 1; // Week pull up
    INTPPS = 0x03;   //RA3->EXT_INT:INT

    // RA4 setup for read ALE
    ANSA4 = 0; // Disable analog function
    WPUA4 = 1; // Week pull up
    TRISA4 = 1; // Set as input
    CLCIN0PPS = 0x04;   //RA4->CLC1:CLCIN0;

    // RA5 setup for SS
    ANSA5 = 0; // Disable analog function
    LATA5 = 1; // Run mode
    TRISA5 = 0; // Set as output
    RA5PPS = 0x04;   //RA5->CLC1:CLC1OUT;    

    //NCO1 Initialize
    NCO1CON = 0x00; // N1EN disabled; N1POL active_hi; N1PFM FDC_mode
    NCO1CLK = 0x01; // N1CKS FOSC; N1PWS 1_clk
    NCO1ACC = 0;
    NCO1INC = 524288; // 6MHz
    N1EN = 1; // Enable the NCO module

    // CWG1 Initialize
	CWG1CLKCON = 0x00; // CWG1CS FOSC
	CWG1DAT = 0x09; // DAT NCO1
	CWG1CON0 = 0x84; // CWG1EN enabled; CWG1MODE Half bridge mode

    // CLC1 Initialize
    CLC1POL = 0x0E; // LC1G2POL inverted; LC1G3POL inverted; LC1G4POL inverted
    CLC1SEL0 = 0x00; // LC1D1S CLCIN0 (CLCIN0PPS)
    CLC1SEL1 = 0x00; // LC1D2S CLCIN0 (CLCIN0PPS)
    CLC1SEL2 = 0x00; // LC1D3S CLCIN0 (CLCIN0PPS)
    CLC1SEL3 = 0x00; // LC1D4S CLCIN0 (CLCIN0PPS)
    CLC1GLS0 = 0x00; // LC1G1DxN disabled; LC1G1DxT disabled
    CLC1GLS1 = 0x00; // LC1G2DxN disabled; LC1G2DxT disabled
    CLC1GLS2 = 0x02; // LC1G3D1T enabled; other disabled
    CLC1GLS3 = 0x00; // LC1G4DxN disabled; LC1G4DxT disabled
    CLC1CON = 0x87; // LC1EN enabled; MODE 1-input transparent latch with S and R

    // Power on SS mode
    if(RA3 == 0)
        LC1G4POL = 0; // SS mode

    while(RA3 == 0); // Wait for off
    
    // TMR1 initialize
    T1CON = 0b11000000;
    TMR1ON = 0;
    
    // External interrupt initialize
    INTF = 0; // Clear the interrupt flag   
    INTE = 1; // RA3 Interrupt enable

    // Enable interrupt
    GIE = 1;
    
    // Start
    __delay_ms(10); // Reset time
    LATA2 = 1; // Release reset

    // 250mS interval in SS mode, No effect in normal mode
    while(1){
        __delay_ms(SS_INTERVAL); // SS mode interval 250msec
        LC1G1POL = 1; // Clock H
        LC1G1POL = 0; // Clock L
    }
}
