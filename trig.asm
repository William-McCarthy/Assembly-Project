; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE


FixedSin PROC USES ebx ecx edi esi angle:FXPT


mov edi, PI_INC_RECIP
;Checks to see if positive radian value

cond1:
mov esi, angle
cmp esi, 0
jl NEGSIN

;Checks to see if between 0 and pi/2.
;Otherwise, sends to the appropriate label block

cond2: 

cmp esi, PI_HALF
je PIHALF
jl WithinRange
jmp LessPI 
 
jge OverTWOPI
jl TWOPI


;0 < radian < pi/2

WithinRange:

mov eax, PI_INC_RECIP
imul esi
xor eax, eax
mov ax, WORD PTR [SINTAB + 2*edx]
jmp continue

;radian = pi/2 
PIHALF:
xor eax, eax
mov eax, 10000h
jmp continue

;pi/2 < radian < pi

LessPI:
cmp esi, PI
jge TWOPI
mov esi, angle
mov ebx, esi ; put angle into ebx
mov ecx, PI
sub ecx, ebx
mov eax, ecx
jmp calculate


;pi < radian < 2pi

TWOPI: 
cmp esi, TWO_PI
jg OverTWOPI

mov ebx, esi
sub ebx, PI
INVOKE FixedSin, ebx
neg eax
jmp continue

;radian > 2pi

OverTWOPI:

sub esi, TWO_PI
invoke FixedSin, esi
jmp continue

;Radian < 0

NEGSIN:
neg esi
INVOKE FixedSin, esi
neg eax
jmp continue

calculate:
mov edi, PI_INC_RECIP
imul edi
xor eax, eax
mov ax, WORD PTR [SINTAB + 2*edx]
continue:

	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC USES edx angle:FXPT

    mov eax, 10000h
    mov edx, angle
	add edx, PI_HALF
	INVOKE FixedSin, edx

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
