;Funcao plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
global plot_xy

extern cor

plot_xy:
		PUSH    BP
		MOV		BP,SP
;Salvando o contexto, empilhando registradores		
		PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
;Preparando para chamar a int 10h	    
	    MOV     AH,0Ch      ;INT 10h/AH = 0Ch - change color for a single pixel.
	    MOV     AL,[cor]    ;AL = pixel color    
	    MOV     BH,0
	    MOV     DX,479
		SUB		DX,[BP+4]   ;DX = row
	    MOV     CX,[BP+6]   ;CX = column - Load in AX
	    INT     10h
;Recupera-se o contexto		
		POP     DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		POP		BP
		RET		4			;Add 4 cause row and column were updated before to enter in the function