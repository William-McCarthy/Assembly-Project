; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive



include stars.inc


.DATA

	;; If you need to, you can place global variables here

.CODE
DrawStarField proc

	;; Place your code here
;;will draw 16 stars here, all will look the same within 640, 480

invoke DrawStar, 150, 200 ;; draw a star at location 150, 200
invoke DrawStar, 100, 150 ;; draw a star at 100, 150
invoke DrawStar, 50, 150 ;; draw a star at 50, 150
invoke DrawStar, 200, 150 ;; draw a star at 200, 150
;;remaining 12
invoke DrawStar, 600, 400 ;; draw a star at 600, 400

invoke DrawStar, 30, 150 ;; draw a star at 30, 150

invoke DrawStar, 40, 150 ;; draw a star at 40, 150

invoke DrawStar, 400, 150 ;; draw a star at 400, 150

invoke DrawStar, 60, 150 ;; draw a star at 60, 150

invoke DrawStar, 80, 150 ;; draw a star at 80, 150

invoke DrawStar, 90, 150 ;; draw a star at 90, 150

invoke DrawStar, 200, 250 ;; draw a star at 200, 250

invoke DrawStar, 120, 20 ;; draw a star at 120, 20

invoke DrawStar, 480, 150 ;; draw a star at 480, 150

invoke DrawStar, 70, 150 ;; draw a star at 70, 150

invoke DrawStar, 10, 15 ;; draw a star at 10, 15





	ret  			; Careful! Don't remove this line
DrawStarField endp


END
