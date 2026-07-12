; Author: Talin Patel
; Date: 20/05/2026
; Description: Interrupt service routine to periodically scan pio and push key events (on/off) to the fifo buffer
;               Note: the fifo_push logic is in this file instead of fifo.s due to time constraints. Please see the
;               exercise 7 submission which has the code properly organised.
; Last modified: 20/05/2026


                ; ISR
scan		subi sp, sp, 20
		sw s4, 16[sp]
		sw s3, 12[sp]	
		sw s2, 8[sp]
		sw s1, 4[sp]
		sw ra, 0[sp]
		
		li s1, 3		; s1 row counter
		
scan_row	li t0, PIO_BASE
	
		; address the correct output pin for PIO
		li t1, KEYB_ROW
		sll t1, t1, s1
		
		; setup pio
		not t2, t1
		li t3, -1
		sw t3, PIO_CLEAR[t0] 	; clear all pins
		sw t1, PIO_SET[t0]	; set write pin high
		sw t2, PIO_DIR[t0]	; set directions
		
		; read PIO and shift irrelevant bits
		lbu t2, 1[t0]
		srli s2, t2, 4
		
		; disable pio - helpful for delay
		li t1, KEYB_ROW
		sll t1, t1, s1
		sw t1, PIO_CLEAR[t0]
		
		; setup to check each column
		la t0, button_matrix
		slli t1, s1, 2		; row*4 addresses correct word of debounce matrix
		add s3, t0, t1		; add this to matrix base address and save.
		li s4, 3		; index column
		
		; column check loop below.
		; s2 keyboard read
		; s3 matrix row address
		; s4 column index

debounce
		; calculate exact matrix address
		add t0, s3, s4		; addr = column + row
		lbu t1, 0[t0]		; debounce_value = *addr
		
		; mask keyboard read by column
		li t2, 1		
		sll t2, t2, s4		
		and t2, t2, s2
		
		; read high -> increment
		bnez t2, read_high
		beqz t1, next_col	; read 0 & matrix value 0 = no action
		
		
		; decrement - read 0 and matrix value > 0
		subi t1, t1, 1	
		sb t1, 0[t0]
		
		; if just hit 0 then push to fifo event RELEASE
		li s5, 0
		beqz t1, fifo_push
		
		j next_col
		
		; read high so check for increment
read_high	subi t2, t1, KEYB_PRESS	; compare to ff
		beqz t2, next_col	; state already ff -> next_col

		; increment debounce value
		addi t1, t1, 1
		sb t1, 0[t0]
		
		; check for debounce saturated
		subi t2, t1, KEYB_PRESS
		bnez t2, next_col

		; saturated so push to buffer with event PRESS
		li s5, 1
fifo_push	
		; switch address from button lookup table to button mappings
		; gets correct ascii char
		la t2, button_mappings
		la t3, button_matrix
		sub t3, t0, t3
		add t3, t2, t3		
		lb t2, 0[t3]		; t2: char
		beqz s5, tail_next
		li t3, 0xF0
		or t2, t2, t3		; add 0xF0 to t3 to record a press down event		
		
		; calculate next buffer pointer
tail_next	la s0, fifo_variables
	
		lw t3, fifo_tail[s0]	; t3: tail
		addi t0, t3, 1		; t0: next = tail + 1
		la t4, fifo_bottom
		blt t0, t4, full_check	; if (next >= fifo_bottom)
		la t0, fifo_top		; next = top
		
		; check if buffer is full
full_check	lw t4, fifo_head[s0]	; t4: head
		beq t0, t4, next_col	; if (next == head) next_col; - buffer is full
		
fifo_space	sb t2, 0[t0]		; buffer[next] = char
		sw t0, fifo_tail[s0]		; tail = next

next_col	subi s4, s4, 1
		
		bgez s4, debounce
		
		; left the debounce inner loop
		; next row	
		subi s1, s1, 1
		bgez s1, scan_row	

		lw ra, 0[sp]
		lw s1, 4[sp]
		lw s2, 8[sp]
		lw s3, 12[sp]
		lw s4, 16[sp]
		addi sp, sp, 20
		ret

button_matrix	defb 0x00, 0x00, 0x00, 0x00	; * 7 4 1
		defb 0x00, 0x00, 0x00, 0x00	; 0 8 5 2
		defb 0x00, 0x00, 0x00, 0x00	; # 9 6 3
		defb 0x00, 0x00, 0x00, 0x00	;   = - +

button_mappings	defb 0, 1, 2, 3
		defb 4, 5, 6, 7
		defb 8, 9, 10, 11
		defb 12, 13, 14, 15

