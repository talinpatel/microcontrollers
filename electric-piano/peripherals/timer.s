; Author: Talin Patel
; Date: 09/03/2026
; Description: Provides an interface to the timer peripheral
; Last modified: 09/03/2026				

		; takes bits to set in a1
timer_cset	li t0, TIMER_BASE
		sw a1, C_SET[t0]
		ret

		; takes bits to set in a1
timer_cclear	li t0, TIMER_BASE
		sw a1, C_CLEAR[t0]
		ret

		; returns status bits in a0
timer_cread	li t0, TIMER_BASE
		lw a1, C_STATUS[t0]
		ret
	
		; sets up the timer to act as a seconds stopclock
stopclock_setup	; set mod value
		li t0, TIMER_BASE
		li a1, MOD_SECOND
		sw a1, MOD[t0]
		
		; reset time
		sw zero, COUNTER[t0]
		
		; clear sticky and enable modulus, don't enable yet
		li t1, TIMER_SETUP
		sw t1, C_SET[t0]
		
		ret

		; handy reset function
timer_reset	li t0, TIMER_BASE
		sw zero, COUNTER[t0]
		ret

		; takes a0 as delay time
timer_delay	li t0, TIMER_BASE
		
		; save control + status + mod
		lw t3, COUNTER[t0]
		lw t4, MOD[t0]
		lw t5, C_STATUS[t0]
		
		; disable timer
		li t1, TIMER_EN
		sw t1, C_CLEAR[t0]
		
		; store mod
		subi a1, a1, 1
		sw a1, MOD[t0]
		
		; reset time
		sw zero, COUNTER[t0]
		
		; clear sticky, enable modulus, enable one shot, enable
		li t1, DELAY_SETUP
		sw t1, C_SET[t0]
		
		; wait until done
delay_check	lw t1, COUNTER[t0]
		li t3, STICKY_MASK
		and t2, t1, t3
		beqz t2, delay_check
		
		; restore status, mod then control (possibly enable)
		sw t3, COUNTER[t0]
		sw t4, MOD[t0]
		sw t5, C_STATUS[t0]
		
		ret
