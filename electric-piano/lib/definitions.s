; Author: Talin Patel
; Date: 10/03/2026
; Description: General definitions for 227 code
; Last modified: 10/03/2026

		; os definitions
MPP_MASK	equ 0x0000_1800
OS_STACK	equ 0x0000_F000
;INTERRUPT_EN	equ 0b1000 ; bit 3?
MPIE_MASK	equ 0b1000_0000
MEIE		equ 0b1000_0000_0000 ;Machine External Interrupt Enable
MSIE		equ 0b0000_0000_1000
MTIE		equ 0b0000_1000_0000

                ; ecalls
TERMINATE	equ 0
WRITE_CHAR	equ 1
LCD_RESET	equ 2
TIMER_CSET	equ 3
TIMER_CREAD	equ 4
TIMER_RESET	equ 5
STOPCLOCK_SETUP equ 6
TIMER_CCLEAR	equ 7
GET_BUTTON	equ 8
POLL_BUTTON	equ 9
FIFO_POP	equ 10
PLAY_NOTE	equ 11
STOP_NOTE	equ 12
ECALL_COUNT	equ 13
                
		; lcd bit patterns
CODE_WRITE	equ 0b0010 ; write data
CODE_READ	equ 0b0001 ; read data
EN_BIT		equ 0b0100
BACKLIGHT	equ 0b1000
NEWLINE		equ 0b1100_0000
LCD_BASE	equ 0x0001_0100
LCD_CONTROL	equ 1
LCD_DATA	equ 0
LCD_IDLE	equ 0b1000_0000

                ; timer
TIMER_BASE	equ 0x0001_0200
TIMER_EN	equ 1
COUNTER		equ 0x00
MOD		equ 0x04	; r/w modulus -1
C_STATUS	equ 0x0C	; r/w status bits
C_CLEAR		equ 0x10	; 1 clears corresponding status bits
C_SET		equ 0x14	; 1 sets corresponding status bits
TIMER_IN_CLEAR	equ 0b1_0000	; interrupt clear bit

MOD_SECOND	equ 0x000F_4240	; 1x10^6
MOD_SCAN	equ 0x0000_2000 ; TODO fix this but the scan takes such a longass time that i think this needs to be low. check every 500us to keep 8ms rolling state
TIMER_SETUP	equ 0b1_0010	; not one shot so continuous timer
TIMER_SCANNER	equ 0b1_1010	
STICKY_MASK	equ 0x8000_0000
STICKY_SET	equ 0b0001_0000
DELAY_SETUP	equ 0b1_0111	; one shot for delay
	
		; led
LED_BASE	equ 0x0001_0000
TOP_LEFT	equ 0b0001
TOP_RIGHT	equ 0b0010
BOTTOM_LEFT	equ 0b0100
BOTTOM_RIGHT	equ 0b1000
		
		; bcd + ascii
BCD_MASK	equ 0b1111
ASCII_NUM	equ '0'

		; interrupt controller
INTERRUPT_BASE	equ 0x0001_0400
IN_ENABLES	equ 0x4
IN_REQUESTS	equ 0x8
IN_MODE		equ 0xC
IN_EDGE_CLEAR	equ 0x10
IN_EDGE_SET	equ 0x14
IN_BUTTON	equ 0b1000_00
IN_TIMER	equ 0b1000_0


		; pio
PIO_BASE	equ 0x0001_0300
PIO_DIR		equ 0x4
PIO_CLEAR	equ 0x8
PIO_SET		equ 0xC

		;keyboard
KEYB_ROW	equ 0b0001_0000_0000
KEYB_INMASK	equ 0xf0
KEYB_PRESS	equ 0x1
FIFO_SIZE	equ 16	; will be 1 larger
CHAR_MASK	equ 0xF0 ; lowest nibble only
PRESSED_CONST	equ 0xF0
		
		;buzzer
PIN_FUNC	equ 0x0001_0708
PIN_FUNC_MASK	equ 0x0000_00C0
BUZZ		equ 0x0002_0000

