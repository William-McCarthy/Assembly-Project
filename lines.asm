; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE


DrawLine PROC USES ebx ecx edx edi esi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	
      ;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

LOCAL curr_x:DWORD, curr_y:DWORD, delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, prev_error:DWORD





;; Subtracts x1 and x0, and sends to negx if negative.
;; Proceeds to definey if positive. 

mov ebx, x1
mov edi, ebx
sub edi, x0
cmp edi, 0
jl negx

;; subtracts y1 and y0, and sends to negy if negative
;; jumps to delta if positive result



definey: 
mov ecx, y1
mov esi, ecx
sub esi, y0
cmp esi, 0
jl negy
jmp delta




;;absolutes delta_x if negative and jumps to definey
negx:
neg edi
jmp definey




;;absolutes delta_y if negative and jumps to delta
negy:
neg esi
jmp delta




;;Define variables delta_x and delta_y
delta:
mov delta_x, edi
mov delta_y, esi




;;If x0 is smaller than x1, inc_x = 1
;;If x0 is bigger, inc_x = -1
ifx:
mov ebx, x1
cmp x0, ebx
jl truex
mov edx, 1
neg edx
mov inc_x, edx
jmp ify




truex:
mov edx, 1
mov inc_x, edx




;If y0 is smaller than y1, inc_y = 1
;if y0 is bigger than y1, inc_y = -1




ify:
mov ecx, y1
cmp y0, ecx
jl truey
mov inc_y, -1
jmp ifdelta




truey:
mov inc_y, 1



;if delta_x is bigger than delta_y, error = delta_x/2
; Otherwise, error = - delta_y /2



ifdelta:
cmp edi, esi
jle ifelse



;Division!
mov error, edi
sar error, 1
jmp continue



ifelse: 
mov error, esi
neg error
sar error, 1



;Define curr_x and curr_y
continue:
mov edx, x0
mov curr_x, edx
mov edx, y0
mov curr_y, edx



INVOKE DrawPixel, curr_x, curr_y, color 

;Evaluate whether to enter the while loop
eval:
mov ebx, x1
cmp curr_x, ebx
jne do
mov ecx, y1
cmp curr_y, ecx
je done

do:
INVOKE DrawPixel, curr_x, curr_y, color
mov edx, error
mov prev_error, edx

One:
mov edx, delta_x
neg edx
cmp prev_error, edx
jle TWO
mov esi, delta_y
sub error, esi
mov esi, inc_x
add curr_x, esi

TWO:
mov edx, delta_y
cmp prev_error, edx
jge eval
mov edx, delta_x
add error, edx
mov edx, inc_y
add curr_y, edx
jmp eval

done:

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
