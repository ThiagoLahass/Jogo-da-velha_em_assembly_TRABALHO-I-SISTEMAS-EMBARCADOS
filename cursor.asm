;
;Funcao cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
global cursor

cursor:
;Salvando o contexto, empilhando registradores
		PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	BP
;Preparando para chamar a int 10h	        	
		MOV     AH,2        ;INT 10h/AH = 2 - set cursor position.
		MOV     BH,0        ;BH = page number (0..7).
                            ;DL = column.		
		INT     10h
;Recupera-se o contexto			
		POP		BP
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		RET