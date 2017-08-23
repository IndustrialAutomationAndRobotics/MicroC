;====================================================================
; Created:   Wed May 31 2017
; Processor: 80C51
; Author: Mohamed Hazim Bin Mohamed Gharib 50212116040
;	  Muhammad Adib bin Ismail 50212116338
;	  
;====================================================================
	org 0000h
	ljmp main

;====================================================================
; INTERRUPT
;====================================================================

	; ext interupt 0
	org 0003h
	lcall stop
	lcall indc
	mov sbuf, #225
	call send
	reti
	
	; timer interupt 0
	org 000bh
	cpl p2.4
	lcall indc
	reti
	
	; ext interrupt 1
	org 0013h
	lcall stop
	mov sbuf, #19
	call send
	reti
	
;====================================================================
; Initialization
;====================================================================

	org 0030h
main:	;Initialize interrupt
	mov ie, #10000111b
	setb tcon.0 ; edge-trigger for both external interrupt
	setb tcon.2
	
	;Initialize Timer Interrupt and Serial Communication Baudrate
	mov tmod, #00100001b
	mov th1, #-3 ; use 9600 baudrate
	mov scon, #50h
	setb tr1
	mov th0, #0b7h
	mov tl0, #0efh
	setb tr0
	
	;initialize led
	clr p2.5
	clr p2.6
	clr p2.7

	;initialize 7 segment
	mov r1, #255
	call disp
	
	;initialize bar position in HMI
	mov sbuf, #19 ; bar at down position
	call send

;====================================================================
; Code Segment
;====================================================================
; Uncomment 1 line in start to run each modules
;	mod1 : Motor Control
;	mod2 : LEDs Indicator
;	mod3 : 7 Segments
;	mod4 : System Indicator
;	mod5 : Intergration of all modules
;	mod6 : Software - Hardware Interfacing
;====================================================================
start:	
	;call mod1 
	;call mod2
	;call mod3
	;call mod4
	;call mod5
	call mod6
	sjmp start

;====================================================================
; Subroutine
;====================================================================
;====================================================================
; Main Subroutine for each modules
;====================================================================
mod1:	jb p0.0, $
	call ccw
	jb p0.1, $
	jnb p0.1, $
	call cw
	ret
	
mod2:	call indc
	ret
	
mod3:	jb p0.1, $
	jnb p0.1, $
	call tolak
	ret
	
mod4:	
	ret
	
mod5:	
	jb p0.0, $
	call ccw
	jb p0.1, $
	jnb p0.1, $
	call tolak
	call cw
	ret
	
mod6:	jb p0.0, $
	call ccw
	mov sbuf, #183 ; bar at middle position
	call send
	jb p0.1, $
	jnb p0.1, $
	mov sbuf, #247
	call send
	;call rec
	mov sbuf, #183 ; bar at middle position
	call send
	call tolak
	call cw
	ret
;====================================================================
; Subroutine for led indicator
;====================================================================
indc:	jb p0.1, offl3
	setb p2.7
	mov sbuf, #155
	call send
	sjmp l2
	
offl3:	clr p2.7
	;mov sbuf, #247
	;call send

l2:	jb p3.3, offl2
	setb p2.6
	mov sbuf, #105
	call send
	sjmp l1
	
offl2:	clr p2.6
	mov sbuf, #197
	call send

l1:	jb p3.2, offl1
	setb p2.5
	mov sbuf, #55
	call send
	sjmp endindc
	
offl1:	clr p2.5
	mov sbuf, #147
	call send
	ret
endindc:ret

;====================================================================
; Subroutine for motor control
;====================================================================
stop:	clr p0.2
	clr p0.3
	mov sbuf, #133
	call send
	ret

ccw:	setb p0.3
	clr p0.2
	mov sbuf, #41
	call send
	ret
		
cw:	setb p0.2
	clr p0.3
	mov sbuf, #83
	call send
	ret
	
;====================================================================
; Subroutine for 7 segment display
;====================================================================

tolak:  dec r1
disp:	mov a, r1
	mov b, #10
	div ab
	mov r6, b ; ones
	
	mov b, #10
	div ab
	mov r5, b ; tenth
	mov r4, a ; hundredth
	
	; display ones
	mov p1, r4
	clr p2.0
	setb p2.0
	
	; display tenth
	mov p1, r5
	clr p2.1
	setb p2.1
	
	; display hundreth
	mov p1, r6
	clr p2.2
	setb p2.2
	
	ret
	
;====================================================================
; Subroutine for Serial Communication
;====================================================================

send:	jnb ti, $
	clr ti
	ret
	
rec:	jnb ri, $
	mov b, sbuf
	mov r1, b
	clr ri
	call disp
	ret
	
	end