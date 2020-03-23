; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
;
;
;
; 
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc




.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES ebx ecx edx edi x:DWORD, y:DWORD, color:DWORD

jmp cond1

body:
   mov ecx, [ScreenBitsPtr]
   mov eax, y
   mov ebx,x
   mov edi, 640
   imul edi
   add eax,ebx
   xor ebx, ebx
   mov ebx, color
   mov [ecx+eax], bl
   jmp away
   


cond1:
    cmp x, 0
    jl lsetx
    cmp x, 640
    jge gsetx

 cond2:
    cmp y, 0
    jl lsety
    cmp y, 480
    jge gsety
    jmp body

lsetx:
    mov x, 0
    jmp cond2
gsetx:
    mov x, 639
    jmp cond2
 lsety:
    mov y, 0
    jmp body
  gsety:
    mov y, 479
    jmp body





away:

	ret 			; Don't delete this line!!!
DrawPixel ENDP



BasicBlit PROC USES edi ebx ecx edx esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
 
 LOCAL starty:DWORD, startx:DWORD, dWidth:DWORD, dHeight:DWORD, x:DWORD, y:DWORD, Transparent:BYTE, color:BYTE

 mov edx, ptrBitmap
 mov ebx, (EECS205BITMAP PTR [edx]).dwWidth
 mov dWidth, ebx
 xor ebx, ebx
 mov ebx, (EECS205BITMAP PTR [edx]).dwHeight
 mov dHeight, ebx
 xor ebx, ebx

;edi will be our x
;ebx will be our y

;Calculates where to start drawing in the x-axis
mov edi, xcenter
mov eax, dWidth 
sar eax, 1 ; Width/2
sub edi, eax ; xcenter - width/2
mov startx, edi ;start x value

;Calculates where to start drawing in the y-axis
mov ebx, ycenter
mov eax, dHeight 
sar eax, 1 ; Height/2
sub ebx, eax ; ycenter - height/2
mov starty, ebx ;starting y value

mov al, (EECS205BITMAP PTR[edx]).bTransparent
mov Transparent, al

mov esi, 0 ; this will be my y increment
mov edx, (EECS205BITMAP PTR[edx]).lpBytes
jmp outcheck

 outfor:
 mov edi, 0 ; this is my x increment
 mov ecx, startx
 jmp incheck


infor:
mov eax, esi 
imul eax, dWidth
add eax, edi ; adding x to y*width
add eax, edx  ; eax becomes the ptr to lpbytes

mov al, BYTE PTR [eax]
cmp al, Transparent
je Ignore

INVOKE DrawPixel, ecx, ebx, al


;if pixel is transparent, do the below
Ignore:
inc edi ; x++
inc ecx ; startx++

incheck: 
cmp edi, dWidth
jl infor

inc ebx ; ystart++
inc esi ; y++

outcheck:
cmp esi, dHeight
jl outfor

	ret 			; Don't delete this line!!!	
BasicBlit ENDP



FixedConverter PROC uses edx x:DWORD, y:FXPT
mov edx, x
mov eax, y
shl edx, 16
imul edx
mov eax, edx

ret 
FixedConverter ENDP


RotateBlit PROC USES edi esi ebx ecx edx lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

 LOCAL starty:DWORD, cosa:FXPT, sina:FXPT, shiftx:DWORD, shifty:DWORD, dstWidth:DWORD, dstHeight:DWORD, srcx:DWORD, srcy:DWORD, dstX:DWORD, dstY:DWORD




	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
