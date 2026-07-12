; Author: Talin Patel
; Date: 05/03/2026
; Description: Provides an interface to the LCD display.
; Last modified: 05/03/2026
; Definitions loaded by OS file

		; delay takes a0 as delay num
delay		subi a0, a0, 1
		bgtz a0, delay
		ret

		; only returns when lcd is idle with void return
lcd_idle	subi sp, sp, 4
		sw ra, 0[sp]
		
		; do a read
		; load base address into t1
                li t1, LCD_BASE

                ; control 0001
                li t2, CODE_READ
                sb t2, LCD_CONTROL[t1]

                ; enable 
                ori t2, t2, EN_BIT
                sb t2, LCD_CONTROL[t1]

                ; delay to stretch pulse width
                li a0, 600
                call delay

                ; read LCD status byte
                lb t3, LCD_DATA[t1]

                ; disable
                xori t2, t2, EN_BIT
                sb t2, LCD_CONTROL[t1]	

		; check bit 7 of status byte
		andi t0, t3, LCD_IDLE
		
		; added delay to separate enable pulses
		li a0, 0xF
		call delay
		
		; repeat if busy
		bnez t0, lcd_idle
		
		; return
		lw ra, 0[sp]
		addi sp, sp, 4
		ret
		
		; takes param a1 control pattern
		; takes param a2 data pattern
		; writes given data to lcd display
lcd_write
		; check lcd is idle
		subi sp, sp, 4
		sw ra, 0[sp]
		call lcd_idle
		
		; load base address into t1
		li t1, LCD_BASE
		
		; set control
		sb a1, LCD_CONTROL[t1]

		; set data
		sb a2, LCD_DATA[t1]
		
		; enable
		ori a1, a1, EN_BIT
		sb a1, LCD_CONTROL[t1]
		
		; delay to stretch pulse width
		li a0, 600
		call delay
		
		; disable
		xori a1, a1, EN_BIT
		sb a1, LCD_CONTROL[t1]
		
		; return
		lw ra, 0[sp]
		addi sp, sp, 4
		ret

		; set cursor and blink off but display on
init_display	subi sp, sp, 4
		sw ra, 0[sp]
		
		mv a1, zero
		li a2, 0xC
		call lcd_write
		
		lw ra, 0[sp]
		addi sp, sp, 4
		ret
	
		; reset LCD
lcd_reset	subi sp, sp, 4
		sw ra, 0[sp]
		
		; reset 0000_0000_0001
		mv a1, zero
		li a2, 1
		call lcd_write
		
		call init_display

		lw ra, 0[sp]
		addi sp, sp, 4
		ret

		; writes individual character to display
		; takes param a2 as value of char
write_char	
		subi sp, sp, 8
		sw ra, 0[sp]
		sw s1, 4[sp]
		
		mv s1, a2
		
		; do a read

                ; load base address into t1
                li t1, LCD_BASE
                
                ; control 0001
                li t2, CODE_READ
                sb t2, LCD_CONTROL[t1]
                
                ; enable
                ori t2, t2, EN_BIT
                sb t2, LCD_CONTROL[t1]
                
                ; delay to stretch pulse width
                li a0, 600
                call delay
                
                ; read LCD status byte
                lb a0, LCD_DATA[t1]

                ; disable
                xori t2, t2, EN_BIT
                sb t2, LCD_CONTROL[t1]
		
		; check if newline needed
		subi a0, a0, 0x10
		bnez a0, eol_ok
		
		; newline
		mv a1, zero
		li a2, NEWLINE
		call lcd_write

		; set control
eol_ok		li a1, 0b0010
		
		mv a2, s1
		; a2 has required bits so call write now
		call lcd_write
		
		
		; return
		lw s1, 4[sp]
		lw ra, 0[sp]
		addi sp, sp, 8
		ret
