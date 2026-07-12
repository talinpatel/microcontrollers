; code to interface with buzzer
; ecalls

		; takes a0 as frequency in khz
play_note	li t0, PIN_FUNC
		li t1, PIN_FUNC_MASK
		sw t1, 0[t0]		; sets pins 6 and 7 to peripheral use
		
		li t0, BUZZ
		li t1, 1
		sw a0, 0[t0]		; play sound

		li t2, 0xFF
note_delay	subi t2, t2, 1
		bgtz t2, note_delay

		sw t1, 4[t0]		; enable high
		ret
		
stop_note	li t0, BUZZ
		sw zero, 4[t0]		; disable
		ret	
