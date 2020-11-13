            .cdecls C,LIST,"msp430g2553.h"  ; Include device header file

            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

            .text                           ; Assemble into program memory.
			.global	_main

_main:
RESET:
	mov.w   #__STACK_END,SP         ; Initialize stackpointer
	mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

	bis.b	#BIT0|BIT6,&P1DIR		; make P1.0 & P1.6 outputs
	bic.b	#BIT0|BIT6,&P1OUT		; make P1.0 & P1.6 low

	mov.w	#62499,&TA0CCR0			; count up to 62499

	; SETTINGS FOR TIMER A0
	; - SMCLK
	; - /1
	; - up mode
	bis.w	#TASSEL_2|ID_0|MC_1,&TA0CTL

	mov.w	#25000,&TA1CCR0			; count up to 25000

	; SETTINGS FOR TIMER A1
	; - SMCLK
	; - /1
	; - up mode
	bis.w	#TASSEL_2|ID_0|MC_1,&TA1CTL

mainloop:
	bit.w	#TAIFG,&TA0CTL			; check if timer has finished counting
	jz		TA1_CCR0		; if counting hasn't finished
	bic.w	#TAIFG,&TA0CTL			; clear interrupt
	xor.b	#BIT6,&P1OUT			; toggle green LED
TA1_CCR0:
	bit.w	#TAIFG,&TA1CTL			; check if timer has finished counting
	jz		mainloop		; if counting hasn't finished
	bic.w	#TAIFG,&TA1CTL			; clear interrupt
	xor.b	#BIT0,&P1OUT			; toggle red LED
	jmp 	mainloop

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .end
