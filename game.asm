; #########################################################################
;
;   game.asm - Assembly file for CompEng205 Assignment 4/5
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

;;sound
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib


;;random numbers
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib





;; Has keycodes
include keys.inc

	
.DATA
;;pause function flag
pauseflag DWORD 0
tackleflag DWORD 0

boxcheckx DWORD 1;;boolean for check, switches variables around
boxchecky DWORD 1
pvelocity DWORD 6;;velocity for player, is set till something changes


;;powerup checks
removepowerup DWORD 0
onionflagcheck DWORD 0
removeslowdown DWORD 0

boxposx DWORD 300;;defender box posx 
boxposy DWORD 300;;defender box posy

goallinecheck DWORD 1;;goalline boolean

goallinex DWORD 550;;goalline defenders x-set as a constant
goalliney DWORD 240;; goalline defenders y- const changing up or down

dfposx DWORD 300;;forward defenders x-const changing
dfposy DWORD 100;;forward defenders y-const

pposx DWORD 80;;players x
pposy DWORD 240;;players y

dposx DWORD 400;; follower defenders x
dposy DWORD 240;; follower defenders y
soundcheck DWORD 0
onionx DWORD ?
oniony DWORD ?
speedupx DWORD ?
speedupy DWORD ?
slowdownx DWORD ?
slowdowny DWORD ?

goallinecheckmax DWORD 1 ;; timer, every 2 second velocity adds itself, max at 14
goallinevelocity DWORD 1
goallineacceleration DWORD 1

playerpositioncheckone DWORD 0
playerpositionchecktwo DWORD 0
playerpositioncheckthree DWORD 0

endgame DWORD ?
SndPath BYTE "cheering.wav",0
SndBoo BYTE "boo.wav",0
SndZero BYTE "zero.wav",0
SndWhistle BYTE "whistle.wav",0
dvelocity DWORD 1;; defenders velocity - will have to change to fxtpt for math

CollisionX DWORD ?
CollisionY DWORD ?

CollisionStr BYTE 'Tackled', 0
TouchdownStr BYTE 'Touchdown, you win', 0
PauseStr BYTE 'Paused, press R to continue', 0
.CODE




;; Note: You will need to implement CheckIntersect!!!
CheckIntersect PROC USES ebx oneX:DWORD, oneY:DWORD, bitone:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, bittwo:PTR EECS205BITMAP
 LOCAL halfwidthone:DWORD, halfheightone:DWORD, halfwidthtwo:DWORD, halfheighttwo:DWORD
 
  mov CollisionX, 0
  mov CollisionY, 0

  
  mov ebx, bitone

  mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
  sar eax, 1
  mov halfwidthone, eax

  mov eax,(EECS205BITMAP PTR [ebx]).dwHeight
  sar eax, 1
  mov halfheightone, eax

  ; Repeat for Two's bitmap
  mov ebx, bittwo

  mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
  sar eax, 1
  mov halfwidthtwo, eax

  mov eax,(EECS205BITMAP PTR [ebx]).dwHeight
  sar eax, 1
  mov halfheighttwo, eax

 ;Intersection across the X-axis 
  mov eax, halfwidthone
  add eax, halfwidthtwo

  mov ebx, twoX
  sub ebx, oneX
  cmp ebx, 0
  jg x_eval

  ;; Obtain the absolute value of x 
  neg ebx

  x_eval:
  cmp eax, ebx
  jl y_compute

  ;; Intersection on the x-axis.
  ;; Proceed to check y
  mov CollisionX, 1

  
  y_compute:
  ;; Compute y-axis intersection
  mov eax, halfheightone
  add eax, halfheighttwo
  mov ebx, twoY
  sub ebx, oneY
  cmp ebx, 0
  jg y_eval

 
  neg ebx

  y_eval:
  cmp eax, ebx
  jl intersection

  ; Intersection on the y-axis.
  mov CollisionY, 1

  ; If there is a collision, will return 1. If not, return 0. 
  intersection:
  mov eax, CollisionX
  mov ebx, CollisionY
  and eax, ebx
 
  ret
CheckIntersect ENDP


GameInit PROC 
	
    invoke BasicBlit, offset background, 320,240
    invoke BasicBlit, offset player, pposx, pposy
    invoke BasicBlit, offset defense, dposx, dposy
    invoke BasicBlit, offset defensebox, boxposx, boxposy 
    invoke BasicBlit, offset goalline, goallinex, goalliney
    invoke BasicBlit, offset dforward, dfposx, dfposy
    invoke PlaySound, offset SndWhistle, 0, SND_FILENAME OR SND_ASYNC
	;;randomseed
	rdtsc
	invoke nseed, eax
	;;x cord for onion
	invoke nrandom, 580
	cmp eax, 80
	jge next
	mov eax, 100
	next:
	mov onionx, eax
	;;y cord for onion
	invoke nrandom, 425
	cmp eax, 60
	jge nextone
	mov eax, 100
	nextone:
	mov oniony, eax

	invoke nseed, eax
	;;x speed up
	invoke nrandom, 580
	cmp eax, 80
	jge sun
	mov eax, 100
	sun:
	mov speedupx, eax
	;;y speed up
	invoke nrandom, 425
	cmp eax, 60
	jge sunone
	mov eax, 100
	sunone:
	mov speedupy, eax

	invoke nseed, edx
	;;x slowdown
	invoke nrandom, 580
	cmp edx, 80
	jge sdn
	mov edx, 100
	sdn:
	mov slowdownx, edx
	;;y speed up
	invoke nrandom, 425
	cmp edx, 60
	jge sdnone
	mov edx, 100
	sdnone:
	mov slowdowny, edx

    invoke BasicBlit, offset onion, onionx, oniony
    invoke BasicBlit, offset slowdown, slowdownx, slowdowny
    invoke BasicBlit, offset speedup, speedupx, speedupy


	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC USES eax ebx ecx edx
	
	invoke BlackStarField
	invoke BasicBlit, offset background, 320,240
	invoke BasicBlit, offset defensebox, boxposx, boxposy 
        invoke BasicBlit, offset goalline, goallinex, goalliney
        invoke BasicBlit, offset dforward, dfposx, dfposy
	

	cmp onionflagcheck, 1
	je remoflagchek
	invoke BasicBlit, offset onion, onionx, oniony
	remoflagchek:
	cmp removepowerup, 1
	je remopdchek
	invoke BasicBlit, offset speedup, speedupx, speedupy
	remopdchek:
	cmp removeslowdown, 1
	je pauseflagchek
	invoke BasicBlit, offset slowdown, slowdownx, slowdowny

	pauseflagchek:
	cmp pauseflag, 1
	jne checkallflags
	cmp KeyPress, VK_R
	je resumegame
	jmp pauseddisplay
	
	resumegame:
	mov pauseflag, 0
	checkallflags:
	cmp KeyPress, VK_P
	jne endgameflagcheck
	mov pauseflag, 1
	
	endgameflagcheck:
	cmp endgame, 1
	je endgamefn
	
	cmp tackleflag, 1
	je endgamel
	

;;movement of player
	mov eax, pvelocity
	movup:
	cmp KeyPress, VK_W
	jne movdown
	cmp pposy, 40
	jle movdown
	sub pposy, eax
	invoke BasicBlit, offset player, pposx, pposy 

	movdown:
	cmp KeyPress, VK_S
	jne movright
	cmp pposy, 425
	jge movright
	add pposy, eax
	invoke BasicBlit, offset player, pposx, pposy


	movright:
	cmp KeyPress, VK_D
	jne movleft
	cmp pposx, 600
	jge movleft
	add pposx, eax
	invoke BasicBlit, offset player, pposx, pposy

	movleft:
	cmp KeyPress, VK_A
	jne endmov
	cmp pposx, 60
	jle endmov
	sub pposx, eax
	invoke BasicBlit, offset player, pposx, pposy
	
		
	endmov:
	invoke BasicBlit, offset player, pposx, pposy
;;end movement of player

	invoke CheckIntersect, pposx, pposy, offset player, speedupx, speedupy, offset speedup
	cmp eax, 1
	jne onionchk
	mov pvelocity, 10
	mov removepowerup, 1

onionchk:
	invoke CheckIntersect, pposx, pposy, offset player, onionx, oniony, offset onion
	cmp eax, 1
	jne pwdown
	mov onionflagcheck, 1

pwdown:
	cmp removeslowdown, 1
	je touchdown
	invoke CheckIntersect, pposx, pposy, offset player, slowdownx, slowdowny, offset slowdown
	cmp eax, 1
	jne touchdown
	sub pvelocity, 2
	mov removeslowdown, 1

;;check to see if players x pos scores a touchdown
	
	touchdown:
	cmp pposx, 570
	jl aftersound
	
	invoke DrawStr , offset TouchdownStr, 300, 200, 0ffh
	cmp soundcheck, 1
	je aftersound
	mov soundcheck, 1
	invoke PlaySound, offset SndPath, 0, SND_FILENAME OR SND_ASYNC
	mov endgame, 1

aftersound:
	cmp playerpositioncheckone, 1
	je ppchecktwo
	cmp pposx, 200
	jle defenseone
	add dvelocity, 1
	mov playerpositioncheckone, 1
	
	
	ppchecktwo:
	cmp playerpositionchecktwo, 1
	je ppcheckthree
	cmp pposx, 300
	jle defenseone
	add dvelocity, 1
	mov playerpositionchecktwo, 1
	
	ppcheckthree:
	cmp playerpositioncheckthree, 1
	je defenseone
	cmp pposx, 400
	jle defenseone
	mov playerpositioncheckthree, 1
	add dvelocity, 1
	
	
defenseone:
	mov eax, dposx
	cmp eax, pposx
	jg subx
	add eax, dvelocity
	mov dposx, eax
	jmp ymov

	subx:
	sub eax, dvelocity
	mov dposx, eax
	

	ymov:
	mov eax, dposy
	cmp eax, pposy
	jg suby
	add eax, dvelocity
	mov dposy, eax
	jmp draw

	suby:
	sub eax, dvelocity
	mov dposy, eax
	
	
draw:
invoke BasicBlit, offset defense, dposx, dposy 


	cmp goallinevelocity, 35
	jge defenseboxmov
	add goallinecheckmax, 1
	cmp goallinecheckmax, 5
	jle defenseboxmov
	mov eax, goallineacceleration
	sar eax, 2
	add eax, goallineacceleration
	mov goallineacceleration, eax
	add goallinevelocity, eax
	mov goallinecheckmax, 0
	


;;movement of defense lower corner
defenseboxmov:
	;;check if defense hits limits of 250 or 350 pixels, if they do switch check
	mov eax, boxposx
	cmp eax, 350
	jge negboxcheck
	cmp eax, 250
	jle posboxcheck
	jmp boxselect

	;;switch check
	negboxcheck:
	mov ebx, boxcheckx
	neg ebx
	mov boxcheckx, ebx
	jmp boxselect
	
	;;switch check
	posboxcheck:
	mov ebx, boxcheckx
	neg ebx
	mov boxcheckx, ebx


	boxselect:
	cmp boxcheckx, 0
	jg addbox
	sub eax, dvelocity
	jmp boxy
	
	addbox:
	add eax, dvelocity
	

	boxy:
	mov boxposx, eax

	mov eax, boxposy
	cmp eax, 350
	jge negboxchecky
	cmp eax, 250
	jle posboxchecky
	jmp boxselecty

	negboxchecky:
	mov ebx, boxchecky
	neg ebx
	mov boxchecky, ebx
	jmp boxselecty
	
	posboxchecky:
	mov ebx, boxchecky
	neg ebx
	mov boxchecky, ebx


	boxselecty:
	cmp boxchecky, 0
	jg addboxy
	sub eax, dvelocity
	jmp boxydone
	
	addboxy:
	add eax, dvelocity

	boxydone:
	mov boxposy, eax

	;;goalline set 
	mov eax, goalliney
	mov ebx, goallinecheck
	
	cmp eax, 40
	jg downcheck
	neg ebx
	mov goallinecheck, ebx
	downcheck:
	cmp eax, 425
	jle goallinechecky
	neg ebx
	mov goallinecheck, ebx

	goallinechecky:
	cmp ebx, 0
	jg addline
	sub eax, goallinevelocity
	jmp endliney
	addline:
	add eax, goallinevelocity
	
	endliney:
	mov goalliney, eax
	

;;collisions
	cmp onionflagcheck, 1
	je next

	mov eax, 0
	invoke CheckIntersect, pposx, pposy, offset player, dposx, dposy, offset defense
	cmp eax, 1
	je tackletrue

	mov eax, 0
	invoke CheckIntersect, pposx, pposy, offset player, boxposx, boxposy, offset defensebox
	cmp eax, 1
	je tackletrue
	mov eax, 0
	invoke CheckIntersect, pposx, pposy, offset player, dfposx, dfposy, offset dforward
	cmp eax, 1
	je zerotackle
	mov eax, 0
	invoke CheckIntersect, pposx, pposy, offset player, goallinex, goalliney, offset goalline
	cmp eax, 1
	je tackletrue


	jmp next
tackletrue:
	mov tackleflag, 1
	invoke DrawStr, offset CollisionStr, 300, 200, 0ffh
	invoke PlaySound, offset SndBoo, 0, SND_FILENAME OR SND_ASYNC
	jmp next
zerotackle:
	mov tackleflag, 1
	invoke DrawStr, offset CollisionStr, 300, 200, 0ffh
	invoke PlaySound, offset SndZero, 0, SND_FILENAME OR SND_ASYNC
next:

jmp skipend	
endgamel:
	invoke DrawStr, offset CollisionStr, 300, 200, 0ffh
	jmp skipend
endgamefn:
	invoke DrawStr , offset TouchdownStr, 300, 200, 0ffh
	jmp skipend
pauseddisplay:
	invoke DrawStr, offset PauseStr, 300, 200, 0ffh
skipend:
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END
