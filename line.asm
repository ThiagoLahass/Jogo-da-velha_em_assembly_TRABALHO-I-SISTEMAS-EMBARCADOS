;-----------------------------------------------------------------------------
;
; Função line
; PUSH x1; PUSH y1; PUSH x2; PUSH y2; call line;  (x<639, y<479)
;
global line

extern plot_xy

line:
		PUSH 	BP
	    MOV	 	BP,SP
;Salvando o contexto, empilhando registradores		
	    PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
;Resgata os valores das coordenadas	previamente definidas antes de chamar a funcao line
		MOV		AX,[bp+10]  ;x1
		MOV		BX,[bp+8]   ;y1 
		MOV		CX,[bp+6]   ;x2 
		MOV		DX,[bp+4]   ;y2
		
		CMP		AX,CX       ;Compare x1 with x2 
		JE		lineV       ;Jump to Vertical Line
		
		JB		line1       ;Jump if x1 < x2 
		
		XCHG	AX,CX       ;else, exchange x1 with x2,
		XCHG	BX,DX       ;and exchange y1 with y2,
		JMP		line1

;---------------- Vertical line ------------------------------
lineV:		                ;DeltAX=0
		CMP		BX,DX       ;Compare y1 with y2                   |
		JB		lineVD      ;Jump if y1 < y2, down vertical line \|/ 
		XCHG	BX,DX       ;else, exchange y1 with y2, up vertical line /|\        
lineVD:	                    ;                                             |
		PUSH	AX          ;column
		PUSH	BX          ;row
		CALL 	plot_xy
		
		CMP		BX,DX       ;Compare y1 with y2
		JNE		IncLineV    ;if not equal, jump to increase pixel
		JMP		End_line    ;else jump fim_line
IncLineV:	
        INC		BX
		JMP		lineVD

;---------------- Horizotnal line ----------------------------
;DeltAX <,=,>0
line1:
;Compare modulus DeltAX & Deltay due to CX > AX -> x2 > x1
		PUSH	CX          ;Save x2 in stack
		SUB		CX,AX       ;CX = CX-AX -> x2 = x2-x1 -> DeltAX
		MOV		[deltax],CX ;Save deltAX
		POP		CX          ;CX = x2
		
		PUSH	DX          ;Save y2 in stack		
		SUB		DX,BX       ;DX = DX-BX -> y2 = y2-y1 -> Deltay \
		JA		line32      ;Jump if DX > BX -> y2 > y1          \|
		NEG		DX          ;else, invert DX                                   --

;y = -mx+b 
line32:		
		MOV		[deltay],DX ;Save deltay
		POP		DX          ;DX = y2

		PUSH	AX          ;Save x2 in stack
		MOV		AX,[deltax] ;Compare DeltAX with DeltaY
		CMP		AX,[deltay]
		POP		AX          ;AX = x2
		JB		line5       ;Jump if DeltAX < DeltaY

	; CX > AX e deltAX>deltay
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,AX
line4:
		PUSH	AX
		PUSH	DX
		PUSH	SI
		SUB		SI,AX	;(x-x1)
		MOV		AX,[deltay]
		IMUL		SI
		MOV		SI,[deltax]		;arredondar
		SHR		SI,1
; se numerador (DX)>0 soma se <0 SUBtrai
		cmp		DX,0
		JL		ar1
		ADD		AX,SI
		ADC		DX,0
		JMP		arc1
ar1:	SUB		AX,SI
		sbb		DX,0
arc1:
		idiv    word[deltax]
		ADD		AX,BX
		POP		SI
		PUSH	SI
		PUSH	AX
		call	plot_xy
		POP		DX
		POP		AX
		cmp		SI,CX
		je		End_line
		inc		SI
		JMP		line4
                                ;                         --
line5:	cmp		BX,DX           ;Compare y1 with y2       /|
		jb 		line7           ;Jump if y1 < y2 -> line /
		xchg	AX,CX       ;else 
		xchg	BX,DX
line7:                          
		PUSH	CX
		SUB		CX,AX
		MOV		word[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,BX
line6:
		PUSH	DX
		PUSH	SI
		PUSH	AX
		SUB		SI,BX	;(y-y1)
		MOV		AX,[deltax]
		IMUL		SI          ;SIgned multiply
		MOV		SI,[deltay]		;arredondar
		SHR		SI,1            ;Shift operand1 Right
		
; se numerador (DX)>0 soma se <0 SUBtrai
		cmp		DX,0
		JL		ar2
		ADD		AX,SI
		ADC		DX,0
		JMP		arc2
ar2:	SUB		AX,SI
		sbb		DX,0
arc2:
		idiv    word[deltay]
		MOV		di,AX
		POP		AX
		ADD		di,AX
		POP		SI
		PUSH	di
		PUSH	SI
		call	plot_xy
		POP		DX
		cmp		SI,DX
		je		End_line
		inc		SI
		JMP		line6

End_line:
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		POP		BP
		RET		8


linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0
;*************************************************************************
segment stack stack
    		resb 		512
stacktop: