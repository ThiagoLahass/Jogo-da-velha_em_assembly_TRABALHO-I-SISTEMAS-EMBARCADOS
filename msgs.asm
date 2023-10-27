; FUNÇÕES DE EXEBIÇÃO DE MENSAGENS

global imprime_ultima_jog, imprime_jogada_inv, imprime_comando_inv, imprime_x_venceu, imprime_c_venceu, imprime_empatou, imprime_msg_apos_fim_jogo, limpa_campo_com, limpa_campo_msg

extern cursor, caracter, cor, comando

imprime_ultima_jog:
		pushf      
		push 	ax
		push	dx
		mov		byte[cor],branco
		mov 	dh, 27
		mov		dl, 20
		call	cursor

		cmp 	byte [comando+1], make_c	; verifica se é C
		jne 	entao_x						; se não, é X
		mov 	al,	'C' 					; se sim, coloca a string C em al
		jmp 	printa_x_c
	entao_x:
		mov 	al, 'X'						; coloca a string X em al
	printa_x_c:
		call 	caracter					; printa X ou C
		inc 	dl							; proxima coluna
		call	cursor

		cmp 	byte [comando+4], make_1	; verifica se é linha 1
		jne 	check_l2
		mov 	al,	'1' 					; se sim, coloca a string 1 em al
		jmp 	printa_l
	check_l2:
		cmp 	byte [comando+4], make_2	; verifica se é linha 2
		jne 	entao_l3
		mov 	al,	'2' 					; se sim, coloca a string 2 em al
		jmp 	printa_l
	entao_l3:
		mov 	al,	'3' 					; se não, coloca a string 3 em al
	printa_l:
		call 	caracter					; printa 1 2 ou 3
		inc 	dl							; proxima coluna
		call	cursor
		
		cmp 	byte [comando+6], make_1	; verifica se é coluna 1
		jne 	check_c2
		mov 	al,	'1' 					; se sim, coloca a string 1 em al
		jmp 	printa_c
	check_c2:
		cmp 	byte [comando+6], make_2	; verifica se é coluna 2
		jne 	entao_c3
		mov 	al,	'2' 					; se sim, coloca a string 2 em al
		jmp 	printa_c
	entao_c3:
		mov 	al,	'3' 					; se não, coloca a string 3 em al
	printa_c:
		call 	caracter						; printa 1 2 ou 3

		pop 	dx
		pop		ax
		popf
		ret

imprime_jogada_inv:
		pushf      
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,15					;número de caracteres
		mov     bx,0
		mov     dh,29					;linha 0-29
		mov     dl,21					;coluna 0-79
		mov		byte[cor],branco
	l_joginv:
		call	cursor
		mov     al,[bx+msg_jog_inv]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		loop    l_joginv

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

imprime_comando_inv:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,16					;número de caracteres
		mov     bx,0
		mov     dh,29					;linha 0-29
		mov     dl,21					;coluna 0-79
		mov		byte[cor],branco
	l_cominv:
		call	cursor
		mov     al,[bx+msg_com_inv]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		loop    l_cominv
		
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

imprime_x_venceu:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,9							;número de caracteres
		mov     bx,0
		mov     dh,29							;linha 0-29
		mov     dl,21							;coluna 0-79
		mov		byte[cor],branco
	l_xvenc:
		call	cursor
		mov     al,[bx+msg_x_venceu]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_xvenc

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

imprime_c_venceu:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,9							;número de caracteres
		mov     bx,0
		mov     dh,29							;linha 0-29
		mov     dl,21							;coluna 0-79
		mov		byte[cor],branco
	l_cvenc:
		call	cursor
		mov     al,[bx+msg_c_venceu]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_cvenc

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

imprime_empatou:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,8							;número de caracteres
		mov     bx,0
		mov     dh,29							;linha 0-29
		mov     dl,21							;coluna 0-79
		mov		byte[cor],branco
	l_empatou:
		call	cursor
		mov     al,[bx+msg_empatou]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_empatou

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

imprime_msg_apos_fim_jogo:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,54							;número de caracteres
		mov     bx,0
		mov     dh,29							;linha 0-29
		mov     dl,21							;coluna 0-79
		mov		byte[cor],branco
	l_fimjogo:
		call	cursor
		mov     al,[bx+msg_fim_jogo]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_fimjogo

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

limpa_campo_com:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,3							;número de caracteres
		mov     bx,0
		mov     dh,27							;linha 0-29
		mov     dl,20							;coluna 0-79
		mov		byte[cor],preto
	l_limpacom:
		call	cursor
		mov     al,[bx+msg_limpa_com]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_limpacom

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

limpa_campo_msg:
		pushf               	
		push 	ax
		push 	bx
		push	cx
		push	dx

		mov     cx,54							;número de caracteres
		mov     bx,0
		mov     dh,29							;linha 0-29
		mov     dl,21							;coluna 0-79
		mov		byte[cor],preto
	l_limpamsg:
		call	cursor
		mov     al,[bx+msg_fim_jogo]
		call	caracter
		inc     bx								;proximo caracter
		inc		dl								;avanca a coluna
		loop    l_limpamsg

		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

segment data

	preto			equ		0
	branco			equ		7

	make_c				equ 2Eh		; códigos Make/Break dos possíveis caracteres que compõem os comandos
	make_1				equ 02h
	make_2				equ 03h
	
    msg_com_inv		db		'Comando Invalido'
	msg_jog_inv		db		'Jogada Invalida'
	msg_limpa_com	db		'000'
	msg_x_venceu	db		'X VENCEU!'
	msg_c_venceu	db		'C VENCEU!'
	msg_empatou		db		'EMPATOU!'
	msg_fim_jogo	db		'Digite s + Enter para sair ou c + Enter para reiniciar'