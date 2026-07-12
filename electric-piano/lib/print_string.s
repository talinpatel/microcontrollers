; Author: Talin Patel
; Date: 09/03/2026
; Description: Provides useful string printing and storing functions.
; Last modified: 09/03/2026

		; takes a2 as string pointer
		; write_char checks for eol so no check here
print_string	subi sp, sp, 8
		sw ra, 0[sp]
		sw s1, 4[sp]
		mv s1, a2
		
write_loop	
		lw a2, 0[s1]
		beqz a2, write_end
			
		li a7, WRITE_CHAR
		ecall
		
		addi s1, s1, 4
		j write_loop
		
write_end	lw s1, 4[sp]
		lw ra, 0[sp]
		addi sp, sp, 8
		ret

		; takes a hex value and prints to lcd
		; takes a1 as hex value
time_print	subi sp, sp, 16
		sw s3, 12[sp]
		sw s2, 8[sp]
		sw s1, 4[sp]
		sw ra, 0[sp]
		
		mv s3, a1
		; reset display
		li a7, LCD_RESET
		ecall
		
		; convert to decimal
		li t0, 7		; 8 digits counter
		mv t1, s3		; copy of number
		li t2, 10		; division by 10
		
		; get remainder from division in t3
divide_loop	rem t3, t1, t2
		
		; stack remainder
		subi sp, sp, 4
		sw t3, 0[sp]
		
		; actually divide
		div t1, t1, t2
		
		; check counter and loop back
		subi t0, t0, 1
		bgez t0, divide_loop
		
		; now we pop off the stack and print
		li s1, 7		; 8 digits counter
		li s2, ASCII_NUM	; add 48
	
		; pop off stack	
print_stack	lw t1, 0[sp]
		addi sp, sp, 4
		
		; add ascii then print
		addi a2, t1, ASCII_NUM
		li a7, WRITE_CHAR
		ecall
		
		; check done
		subi s1, s1, 1
		bgez s1, print_stack
		
		; done so return
		lw s3, 12[sp]
		lw s2, 8[sp]
		lw s1, 4[sp]
		lw ra, 0[sp]
		addi sp, sp, 16
		ret
		
