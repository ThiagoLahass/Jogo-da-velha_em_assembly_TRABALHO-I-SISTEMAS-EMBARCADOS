; FUNÇÕES DE VERIFICAÇÃO

global f_verifica_leitura_jogada, func_verifica_jogada, f_verifica_ganhador, marca_ganhador

extern line, cor, comando, leitura_jog_val, ultima_jog_x_c, ultima_jog_val, cel_marcadas, cel_marcadas_x, cel_marcadas_c, venceu, resultado, celulas, marca_celula11, marca_celula12, marca_celula13, marca_celula21, marca_celula22, marca_celula23, marca_celula31, marca_celula32, marca_celula33

f_verifica_leitura_jogada:
		cmp 	byte [comando], make_shift		; verifica se o comando começa com Shift
		je 		testa_c							; se sim, testa Shift + c
		mov 	byte [leitura_jog_val], 0		; se não, comando inválido
	testa_c:
		cmp 	byte [comando+1], make_c		; testa se é circulo
		jne 	testa_x							; se não for, testa x
		jmp 	testa_celula1
	testa_x:
		cmp 	byte [comando+1], make_x		; testa se é x
		je 		testa_celula1
		mov 	byte [leitura_jog_val], 0		; se não for, comando invalido
		jmp 	fim_f1
	testa_celula1:
		cmp 	byte [comando+4], make_3		; verifica se o numero da celula 1 é > 3
		jle		testa_esc1						; se não, testa se é a tecla esc
		mov 	byte [leitura_jog_val], 0		; se for, comando invalido
		jmp 	fim_f1
	testa_esc1:
		cmp 	byte [comando+4], 01h			; se é < 3, verifica se é a tecla esc (make = 01h)
		jne 	testa_celula2					; se não, testa o número da celula 2
		mov 	byte [leitura_jog_val], 0		; se for, comando invalido
		jmp 	fim_f1
	testa_celula2:
		cmp 	byte [comando+6], make_3		; verifica se o numero da celula 2 é > 3
		jle		testa_esc2						; se não, testa se é a tecla esc 
		mov 	byte [leitura_jog_val], 0		; se for, comando invalido
		jmp 	fim_f1
	testa_esc2: 
		cmp 	byte [comando+6], 01h			; se é < 3, verifica se é a tecla esc (make = 01h)
		jne 	esta_no_formato					; se não, então está no formato correto
		mov 	byte [leitura_jog_val], 0		; se for, comando invalido
		jmp 	fim_f1
	esta_no_formato:
		mov 	byte [leitura_jog_val], 1		
	fim_f1:
		ret

func_verifica_jogada:
		mov 	al, byte [comando+4]						; transfere o make code da célula 1 para al
		mov 	ah, byte [comando+6]						; transfere o make code da célula 2 para ah
		mov 	bl, byte [ultima_jog_x_c]
		cmp 	byte [comando+1], bl 						; verifica se o jogador tentou jogar 2 vezes seguidas
		je 		fim_f2_inv_intermediario					; se já, jogada invalida
	; testa linha 1
		cmp 	al, make_1							
		jne 	testa_l2									; se o primeiro digito não é 1, testa linha 2
		;testa_l1_c1										; se é, testa as colunas
			cmp 	ah, make_1								; verifica se é coluna 1
			jne 	testa_l1_c2								; se n é coluna 1, testa coluna 2 
			; Se digitou L1 C1
			mov 	bx, 0x0001
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 11 
			cmp 	bx, 0x0001
			je		fim_f2_inv_intermediario				; se já, jogada invalida
			call 	marca_celula11							; se não, marca celula 11
			jmp		fim_f2_val
		testa_l1_c2:
			cmp 	ah, make_2					
			jne 	eh_l1_c3								; se n é coluna 2, é coluna 3
			; Se digitou L1 C2
			mov 	bx, 0x0002
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 12 
			cmp 	bx, 0x0002
			je		fim_f2_inv_intermediario				; se já, jogada invalida
			call 	marca_celula12							; se não, marca celula 12
			jmp		fim_f2_val
		eh_l1_c3:
			mov 	bx, 0x0004
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 13 
			cmp 	bx, 0x0004
			je		fim_f2_inv_intermediario				; se já, jogada invalida
			call 	marca_celula13							; se não, marca celula 13
			jmp		fim_f2_val
	fim_f2_inv_intermediario:
		jmp fim_f2_inv
	testa_l2:
		cmp 	al, make_2							
		jne 	eh_l3										; se o primeiro digito não é 2, então é linha 3
		;testa_l2_c1										; se é, testa as colunas
			cmp 	ah, make_1								; verifica se é coluna 1
			jne 	testa_l2_c2								; se n é coluna 1, testa coluna 2 
			; Se digitou L2 C1
			mov 	bx, 0x0008
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 21 
			cmp 	bx, 0x0008
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula21							; se não, marca celula 21
			jmp		fim_f2_val
		testa_l2_c2:
			cmp 	ah, make_2					
			jne 	eh_l2_c3								; se n é coluna 2, é coluna 3
			; Se digitou L2 C2
			mov 	bx, 0x0010
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 22 
			cmp 	bx, 0x0010
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula22							; se não, marca celula 22
			jmp		fim_f2_val
		eh_l2_c3:
			mov 	bx, 0x0020
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 23 
			cmp 	bx, 0x0020
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula23							; se não, marca celula 23
			jmp		fim_f2_val
	eh_l3:
		;testa_l3_c1										; testa as colunas
			cmp 	ah, make_1								; verifica se é coluna 1
			jne 	testa_l3_c2								; se n é coluna 1, testa coluna 2 
			; Se digitou L3 C1
			mov 	bx, 0x0040
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 31 
			cmp 	bx, 0x0040
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula31							; se não, marca celula 31
			jmp		fim_f2_val
		testa_l3_c2:
			cmp 	ah, make_2					
			jne 	eh_l3_c3								; se n é coluna 2, é coluna 3
			; Se digitou L3 C2
			mov 	bx, 0x0080
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 32 
			cmp 	bx, 0x0080
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula32							; se não, marca celula 32
			jmp		fim_f2_val
		eh_l3_c3:
			mov 	bx, 0x0100
			and 	bx, word [cel_marcadas]					; verifica se já foi marcada a célula 33 
			cmp 	bx, 0x0100
			je		fim_f2_inv								; se já, jogada invalida
			call 	marca_celula33							; se não, marca celula 33
			jmp		fim_f2_val
	fim_f2_val:
		mov 	byte [ultima_jog_val], 1
		ret
	fim_f2_inv:
		mov 	byte [ultima_jog_val], 0
		ret


f_verifica_ganhador:
		; 11-21-31 = 001001001 = 0x0049
		; 12-22-32 = 010010010 = 0x0092
		; 13-23-33 = 100100100 = 0x0124
		; 11-12-13 = 000000111 = 0x0007
		; 21-22-23 = 000111000 = 0x0038
		; 31-32-33 = 111000000 = 0x01C0
		; 11-22-33 = 100010001 = 0x0111
		; 13-22-31 = 001010100 = 0x0054
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0049
		cmp		ax, 0x0049
		jne		prox1
		mov 	word [venceu], 0x0049
		jmp 	ganhou_x
	prox1:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0092
		cmp		ax, 0x0092
		jne		prox2
		mov 	word [venceu], 0x0092
		jmp 	ganhou_x
	prox2:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0124
		cmp		ax, 0x0124
		jne		prox3
		mov 	word [venceu], 0x0124
		jmp 	ganhou_x
	prox3:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0007
		cmp		ax, 0x0007
		jne		prox4
		mov 	word [venceu], 0x0007
		jmp 	ganhou_x
	prox4:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0038
		cmp		ax, 0x0038
		jne		prox5
		mov 	word [venceu], 0x0038
		jmp 	ganhou_x
	prox5:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x01C0
		cmp		ax, 0x01C0
		jne		prox6
		mov 	word [venceu], 0x01C0
		jmp 	ganhou_x
	prox6:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0111
		cmp		ax, 0x0111
		jne		prox7
		mov 	word [venceu], 0x0111
		jmp 	ganhou_x
	prox7:
		mov 	ax, word [cel_marcadas_x]
		and 	ax, 0x0054
		cmp		ax, 0x0054
		jne		prox8
		mov 	word [venceu], 0x0054
		jmp 	ganhou_x
	prox8:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0049
		cmp		ax, 0x0049
		jne		prox9
		mov 	word [venceu], 0x0049
		jmp 	ganhou_c
	prox9:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0092
		cmp		ax, 0x0092
		jne		prox10
		mov 	word [venceu], 0x0092
		jmp 	ganhou_c
	prox10:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0124
		cmp		ax, 0x0124
		jne		prox11
		mov 	word [venceu], 0x0124
		jmp 	ganhou_c
	prox11:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0007
		cmp		ax, 0x0007
		jne		prox12
		mov 	word [venceu], 0x0007
		jmp 	ganhou_c
	prox12:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0038
		cmp		ax, 0x0038
		jne		prox13
		mov 	word [venceu], 0x0038
		jmp 	ganhou_c
	prox13:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x01C0
		cmp		ax, 0x01C0
		jne		prox14
		mov 	word [venceu], 0x01C0
		jmp 	ganhou_c
	prox14:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0111
		cmp		ax, 0x0111
		jne		prox15
		mov 	word [venceu], 0x0111
		jmp 	ganhou_c
	prox15:
		mov 	ax, word [cel_marcadas_c]
		and 	ax, 0x0054
		cmp		ax, 0x0054
		jne		n_ganhou
		mov 	word [venceu], 0x0054
		jmp 	ganhou_c
	ganhou_x:
		call 	marca_ganhador
		mov 	byte [resultado], 1
		ret
	ganhou_c:
		call 	marca_ganhador
		mov 	byte [resultado], 2
		ret
	n_ganhou:
		ret

; 11-21-31 = 001001001 = 0x0049 
; 12-22-32 = 010010010 = 0x0092	
; 13-23-33 = 100100100 = 0x0124
; 11-12-13 = 000000111 = 0x0007
; 21-22-23 = 000111000 = 0x0038
; 31-32-33 = 111000000 = 0x01C0
; 11-22-33 = 100010001 = 0x0111
; 13-22-31 = 001010100 = 0x0054
marca_ganhador: ; 11-21-31 = 001001001 = 0x0049
		mov		byte[cor],verde
		cmp 	word [venceu], 0x0049
		jne		next1
		;[190,60]->[190,450] -> VERTICAL
		mov		ax,190
		push	ax
		mov		ax,60
		push	ax
		mov		ax,190
		push	ax
		mov		ax,450
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next1:		; 12-22-32 = 010010010 = 0x0092
		cmp 	word [venceu], 0x0092
		jne		next2
		;[320,60]->[320,450] -> VERTICAL
		mov		ax,320
		push	ax
		mov		ax,60
		push	ax
		mov		ax,320
		push	ax
		mov		ax,450
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next2:		; 13-23-33 = 100100100 = 0x0124
		cmp 	word [venceu], 0x0124
		jne		next3
		;[450,60]->[450,450] -> VERTICAL
		mov		ax,450
		push	ax
		mov		ax,60
		push	ax
		mov		ax,450
		push	ax
		mov		ax,450
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next3:		; 11-12-13 = 000000111 = 0x0007
		cmp 	word [venceu], 0x0007
		jne		next4
		;[125,385]->[515,385] -> HORIZONTAL
		mov		ax,125
		push	ax
		mov		ax,385
		push	ax
		mov		ax,515
		push	ax
		mov		ax,385
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next4:		; 21-22-23 = 000111000 = 0x0038
		cmp 	word [venceu], 0x0038
		jne		next5
		;[125,255]->[515,255] -> HORIZONTAL
		mov		ax,125
		push	ax
		mov		ax,255
		push	ax
		mov		ax,515
		push	ax
		mov		ax,255
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next5:		; 31-32-33 = 111000000 = 0x01C0
		cmp 	word [venceu], 0x01C0
		jne		next6
		;[125,125]->[515,125] -> HORIZONTAL
		mov		ax,125
		push	ax
		mov		ax,125
		push	ax
		mov		ax,515
		push	ax
		mov		ax,125
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next6:		; 11-22-33 = 100010001 = 0x0111
		cmp 	word [venceu], 0x0111
		jne		next7
		;[125,450]->[515,60] -> DIAGONAL
		mov		ax,125
		push	ax
		mov		ax,450
		push	ax
		mov		ax,515
		push	ax
		mov		ax,60
		push	ax
		call	line
		jmp 	fim_marca_ganhador
	next7:		; 13-22-31 = 001010100 = 0x0054
		;[515,450]->[125,60] -> DIAGONAL
		mov		ax,515
		push	ax
		mov		ax,450
		push	ax
		mov		ax,125
		push	ax
		mov		ax,60
		push	ax
		call	line
	fim_marca_ganhador:
		ret

segment data

	make_c				equ 2Eh		; códigos Make/Break dos possíveis caracteres que compõem os comandos
	make_s				equ 1Fh
	make_x				equ 2Dh
	make_1				equ 02h
	make_2				equ 03h
	make_3				equ 04h
	make_shift			equ 2Ah

	verde			equ		2