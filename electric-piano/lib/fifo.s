; fifo_pop function. Fifo push function is inlined in the PIO logic.
; FIFO now stores events, not just keys.
; lowest byte is char, upper byte is on/off
fifo_variables
		struct
fifo_tail	word
		defw fifo_top
fifo_head	word
		defw fifo_top


fifo_top				
defs FIFO_SIZE

fifo_bottom

		; NOTE: is an ecall after writing to user space
		; from machine mode caused issues

		; get_char function
		; returns a5 as value in buffer
fifo_pop	la s1, fifo_variables
		lw t1, fifo_head[s1]	; t1 head location
		
		lw t2, fifo_tail[s1]		; t2 is tail location
		
		bne t1, t2, not_empty	; if (tail==head) then empty
		li a5, -1
		ret		

not_empty	addi t1, t1, 1		; next = head + 1
		la t2, fifo_bottom
		ble t1, t2, fifo_get	; if (next > fifo_bottom) next = fifo_top
		la t1, fifo_top

fifo_get	lbu a5, 0[t1]		; val = *next
		sw t1, fifo_head[s1]		; head = next
		
		ret
			
