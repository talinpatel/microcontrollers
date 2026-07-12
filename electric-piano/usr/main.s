; Author: Talin Patel
; Date: 20/05/2026
; Description: Electronic organ program. This lets users switch between a major and minor scale to play on the keyboard
               ; Keys can be pressed down and sound will be played until released
               ; The scale is selected using the keyboard then displayed
               ; A hardware module was implemented to allow the keyboard buzzer to be used
               ; This has a control register with volume and en, and a data register in which you enter a note 1 to 12,
               ; from C to C.
               ; The hardware module uses a lookup table to get the correct frequency for a square wave.


main		li a7, LCD_RESET
		ecall				
				
		la a2, welcome_string
		call print_string

input_wait	li a7, FIFO_POP
		ecall
		bltz a5, input_wait

		; remove bits set from press down
		subi t0, a5, CHAR_MASK
                bltz t0, input_wait
              
                ; load the correct string
		la a2, minor_string
		la s1, minor_table
		
		li t1, 13               ; "D"
		bne t0, t1, print_scale
		
		la a2, major_string
		la s1, major_table
			
print_scale	li a7, LCD_RESET
		ecall
		call print_string			


note_loop	li a7, FIFO_POP
		ecall
		bltz a5, note_loop	; nothing from buffer
		
		; check play vs stop
		li t0, 15
		bleu a5, t0, stop
                
                ; reset key
		subi t1, a5, CHAR_MASK
		beq t0, t1, main
		
		subi a5, a5, PRESSED_CONST
		; play note - a0 argument
		li a7, PLAY_NOTE
		
		add t0, s1, a5		; note = table base + offset
		lb a0, 0[t0]
		
		ecall
		j note_loop
		
		; stop note
stop		li a7, STOP_NOTE
		ecall			; stop
		j note_loop
		
clear_display	li a7, LCD_RESET
		ecall
		j note_loop

welcome_string	defw "F to reset. Currently major. Minor: D"

major_string	defw "Playing: major"
minor_string	defw "Playing: minor"

major_table	defb 0, 2, 4, 5
		defb 7, 9, 11, 12
		defb 0, 0, 0, 0
		defb 0, 0, 0, 0

minor_table	defb 0, 2, 3, 5
		defb 7, 8, 10, 12
		defb 0, 0, 0, 0
		defb 0, 0, 0, 0
