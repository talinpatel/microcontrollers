; Author: Talin Patel
; Date: 05/03/2026
; Description: Provides OS code and ecall handling for RISC-V lab board
; Last modified: 20/05/2026

		INCLUDE ../lib/definitions.s
;======================================================================
;================================OS CODE===============================
;======================================================================
		j initialisation

		; methods for peripherals
		INCLUDE ../peripherals/lcd.s
		INCLUDE ../peripherals/timer.s
		INCLUDE ../peripherals/led_buttons.s
		INCLUDE ../peripherals/pio.s
		INCLUDE ../lib/fifo.s
		INCLUDE ../peripherals/buzzer.s
		; note: fifo should not be an ecall but after speaking to
		; Anthony, was told to put this in an ecall to sort a bug.

terminate	j .

initialisation	li sp, OS_STACK		; initialise sp
		li t0, MPP_MASK		; Load MPP mask
		csrc MSTATUS, t0	; Clear MPP bits in status
		la t0, mhandler
		csrw MTVEC, t0

		; machine external interrupt enable
		; MIE in mstatus is not set
		; so interrupts are not enabled yet
		li t0, MEIE
		csrs MIE, t0
		
		; timer setup
		li t0, TIMER_BASE
		li t1, MOD_SCAN
		sw t1, MOD[t0]
		
		; clear timer interrupt bit
		li t1, TIMER_IN_CLEAR
		sw t1, C_CLEAR[t0]
		
		; setup timer for scanning
		li t1, TIMER_SCANNER
		sw t1, C_STATUS[t0]
		
		; timer en
		li t1, TIMER_EN
		sw t1, C_SET[t0]
		
                ; interrupt controller: timer enable
                li t0, IN_TIMER
                li t1, INTERRUPT_BASE
                sw t0, IN_ENABLES[t1]
                sw t0, IN_EDGE_CLEAR[t1]

		csrw MSCRATCH, sp	; use mscratch as machine sp
		la sp, user_stack	; Change sp to user space
		la ra, user_code	; Point at user code start
		csrw MEPC, ra		; user code as code that 'trapped'
		
		; risc-v interrupt enable - MPIE
		; MPIE -> MIE on mret
		li t0, MPIE_MASK
		csrs MSTATUS, t0	
		
		mret
	
		; it's a trap!
mhandler	csrrw sp, MSCRATCH, sp	; Save user sp, get machine sp
		
		; saving registers
		subi sp, sp, 72
                sw s4, 68[sp]
                sw s3, 64[sp]
                sw s2, 60[sp]
		sw a4, 56[sp]
		sw a3, 52[sp]
		sw a2, 48[sp]
		sw a1, 44[sp]
		sw a0, 40[sp]
		sw t6, 36[sp]
		sw t5, 32[sp]
		sw t4, 28[sp]
		sw t3, 24[sp]
		sw t2, 20[sp]
		sw t1, 16[sp]
		sw t0, 12[sp]
		sw s1, 8[sp]
		sw s0, 4[sp]
		sw ra, 0[sp]

		; don't forget to fix blt issues
		
		csrr t0, MCAUSE		; why are we here		
		bltz t0, interrupts	; it's an interrupt

		; it's an ecall
exceptions	li t1, 8
		beq t0, t1, ecall_handler
		
		; no idea -> terminate
		j terminate
		
		; return sequence
mreturn		
		lw ra, 0[sp]
		lw s0, 4[sp]
		lw s1, 8[sp]
		lw t0, 12[sp]
		lw t1, 16[sp]
		lw t2, 20[sp]
		lw t3, 24[sp]
		lw t4, 28[sp]
		lw t5, 32[sp]
		lw t6, 36[sp]
		lw a0, 40[sp]
		lw a1, 44[sp]
		lw a2, 48[sp]
		lw a3, 52[sp]
		lw a4, 56[sp]
                lw s2, 60[sp]
                lw s3, 64[sp]
                lw s4, 68[sp]
		addi sp, sp, 72
		
		; switch stack to user space
		csrrw sp, MSCRATCH, sp
		mret
		
		; it's an interrupt
interrupts	andi t0, t0, 0xF ; clear upper bits
		li t1, 3
		beq t0, t1, itrpt_software
		li t1, 7
		beq t0, t1, itrpt_timer
		li t1, 11
		beq t0, t1, itrpt_external


itrpt_software	j mreturn

		; NOT to be confused with peripheral timer
itrpt_timer	j mreturn

itrpt_external	; clear interrupt source
		li t0, MEIE
		csrc MIP, t0
		
		li t0, INTERRUPT_BASE

		; lookup via interupt controller
		; looking at requests
		; was it the button?
		lw t1, IN_REQUESTS[t0]
		andi t2, t1, IN_BUTTON
		bnez t2, isr_tl
		
		; was it the timer?
		andi t2, t1, IN_TIMER
		bnez t2, isr_timer_ext
		j mreturn


isr_tl		j mreturn

isr_timer_ext	; pause the timer
		li t0, TIMER_BASE
		li t1, TIMER_EN
		sw t1, C_CLEAR[t0]
		
		; clear timer interrupt
		li t1, TIMER_IN_CLEAR
		sw t1, C_CLEAR[t0]
		
		; do the stuff
		call scan
		; resume timer
		li t0, TIMER_BASE
		li t1, TIMER_EN
		sw t1, C_SET[t0]
		
		j mreturn
		
		

ecall_handler	; check in range
		li t1, ECALL_COUNT
		bgeu a7, t1, terminate	; will catch negatives as unsigned
		
		la t0, ecall_table
		slli a7, a7, 2		; shift to address word in table
		add t1, t0, a7
		lw t1, 0[t1]		; get offset in t1
		add t0, t0, t1		; base + offset = target
		jalr ra, 0[t0]
		
		; return sequence
		; ecall will return to next instruction not same
		csrrw t0, MEPC, t0
		addi t0, t0, 4
		csrrw t0, MEPC, t0
		j mreturn

ecall_table	defw terminate - ecall_table
		defw write_char - ecall_table
		defw lcd_reset - ecall_table
		defw timer_cset - ecall_table
		defw timer_cread - ecall_table
		defw timer_reset - ecall_table
		defw stopclock_setup - ecall_table
		defw timer_cclear - ecall_table
		defw get_button - ecall_table
		defw poll_button - ecall_table
		defw fifo_pop - ecall_table
		defw play_note - ecall_table
		defw stop_note - ecall_table

	
;========================================================================
;===============================USER CODE================================
;========================================================================
		org 0x0004_0000
user_code
		j main
		; library functions	
		INCLUDE ../lib/print_string.s

		; user code with main method
		INCLUDE ../usr/main.s

usr_stack_base	defs 0x0000_0F00
		user_stack

