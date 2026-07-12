; Author: Talin Patel
; Date: 11/03/2025
; Description: Provides machine mode code to get button values and write led
; values.
; Last modified: 11/03/2025

		; returns a1 button values
get_button	li t0, LED_BASE
		lb a1, 1[t0]
		ret

		; takes a1 4 bit led code
		; takes a2 right/left 1/0
set_colours	li t0, LED_BASE
		add t0, t0, a2 ; add byte offset
		sb a2, 0[t0]
		ret

		; takes a1 as the bit to check for button
		; only returns when button is pressed
poll_button	li t0, LED_BASE
poll_loop	lb t1, 1[t0]
		sub t1, t1, a1
		bnez t1, poll_loop
		ret
