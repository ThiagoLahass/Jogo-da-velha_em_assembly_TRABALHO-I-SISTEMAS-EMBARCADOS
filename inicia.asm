; FUNÇÃO DE INICIALIZAÇÃO: DESENHA LAYOUT DO JOGO

global inicia_jogo

extern caracter, cursor, line, cel_marcadas, comando, cel_marcadas_c, cel_marcadas_x, ultima_jog_x_c, i_atual_comando, modo_anterior, venceu, resultado, celulas, cor

inicia_jogo:
		mov 	byte [ultima_jog_x_c], 0
		mov 	word [cel_marcadas], 0
		mov 	word [cel_marcadas_x], 0
		mov 	word [cel_marcadas_c], 0
		mov 	word [venceu], 0
		mov 	byte [resultado], 0

	; salvar modo corrente de video(vendo como está o modo de video da maquina)
		mov  	ah,0Fh
		int  	10h
		mov  	[modo_anterior],al   

	; alterar modo de video para gráfico 640x480 16 cores
		mov     al,12h
		mov     ah,0
		int     10h

	;desenhar retas da tabela de jogo
		mov		byte[cor],branco_intenso	
		
		;[125,190]->[515,190] -> HORIZONTAL
		mov		ax,125
		push	ax
		mov		ax,190
		push	ax
		mov		ax,515
		push	ax
		mov		ax,190
		push	ax
		call	line

		;[125,320]->[515,320] -> HORIZONTAL
		mov		ax,125
		push	ax
		mov		ax,320
		push	ax
		mov		ax,515
		push	ax
		mov		ax,320
		push	ax
		call	line

		;[255,60]->[255,450] -> VERTICAL
		mov		ax,255
		push	ax
		mov		ax,60
		push	ax
		mov		ax,255
		push	ax
		mov		ax,450
		push	ax
		call	line

		;[385,60]->[385,450] -> VERTICAL
		mov		ax,385
		push	ax
		mov		ax,60
		push	ax
		mov		ax,385
		push	ax
		mov		ax,450
		push	ax
		call	line

	;escrever mensagem topo "JOGO DA VELHA"
		mov     cx,13					;número de caracteres
		mov     bx,0
		mov     dh,0					;linha 0-29
		mov     dl,34					;coluna 0-79
		mov		byte[cor],azul
	lm1:
		call	cursor
		mov     al,[bx+titulo]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		inc		byte [cor]				;mudar a cor para a seguinte
		loop    lm1

	;desenhar caixa de comando
	;[5,50]->[635,50] -> HORIZONTAL
	mov		ax,5
	push	ax
	mov		ax,50
	push	ax
	mov		ax,635
	push	ax
	mov		ax,50
	push	ax
	call	line

	;[5,30]->[635,30] -> HORIZONTAL
	mov		ax,5
	push	ax
	mov		ax,30
	push	ax
	mov		ax,635
	push	ax
	mov		ax,30
	push	ax
	call	line

	;[5,30]->[5,50] -> VERTICAL
	mov		ax,5
	push	ax
	mov		ax,30
	push	ax
	mov		ax,5
	push	ax
	mov		ax,50
	push	ax
	call	line

	;[635,30]->[635,50] -> VERTICAL
	mov		ax,635
	push	ax
	mov		ax,30
	push	ax
	mov		ax,635
	push	ax
	mov		ax,50
	push	ax
	call	line

	;desenhar caixa de mensagem
	;[5,20]->[635,20] -> HORIZONTAL
	mov		ax,5
	push	ax
	mov		ax,20
	push	ax
	mov		ax,635
	push	ax
	mov		ax,20
	push	ax
	call	line

	;[5,30]->[5,50] -> VERTICAL
	mov		ax,5
	push	ax
	mov		ax,0
	push	ax
	mov		ax,5
	push	ax
	mov		ax,20
	push	ax
	call	line

	;[635,30]->[635,50] -> VERTICAL
	mov		ax,635
	push	ax
	mov		ax,0
	push	ax
	mov		ax,635
	push	ax
	mov		ax,20
	push	ax
	call	line

	;escrever mensagem de comando
		mov     cx,17					;número de caracteres
		mov     bx,0
		mov     dh,27					;linha 0-29
		mov     dl,2					;coluna 0-79
		mov		byte[cor],branco
	lm2:
		call	cursor
		mov     al,[bx+campo_comando]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		loop    lm2

	;escrever mensagem de mensagens
		mov     cx,18					;número de caracteres
		mov     bx,0
		mov     dh,29					;linha 0-29
		mov     dl,2					;coluna 0-79
		mov		byte[cor],branco
	lm3:
		call	cursor
		mov     al,[bx+campo_mensagem]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		loop    lm3

	;escrever identificação das células
		mov     cx,18					;número de caracteres
		mov     bx,0
		mov		ah,2					;valor para comparar e saber se já escreveu 'l' e 'c'
		mov     dh,3					;linha 0-29
		mov     dl,16					;coluna 0-79
		mov		byte[cor],branco
	lm4:
		call	cursor
		mov     al,[bx+celulas]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		cmp 	bl,ah					;se ainda não escreveu o num da 'l' e 'c' da célula continua
		jl		cont1
		;se já, muda para a célula abaixo
		add 	ah,2
		sub 	dl,2
		add 	dh,8	
		
		cmp 	bl,6					;verifica se terminou de escrever nas celulas da coluna 1
		jne		cont				;se sim, muda para a coluna 2
		mov 	dh,3
		mov 	dl,33
	cont:
		cmp 	bl,12					;verifica se terminou de escrever nas células da coluna 2
		jne		cont1				;se sim, muda para a coluna 3
		mov 	dh,3
		mov 	dl,49
	cont1:
		loop    lm4

	;escrever mensagem de como jogar
		mov     cx,70					;número de caracteres
		mov     bx,0
		mov		ah,12					;valor para comparar e saber se já escreveu a linha toda
		mov     dh,3					;linha 0-29
		mov     dl,0					;coluna 0-79
		mov		byte[cor],branco
	lm5:
		call	cursor
		mov     al,[bx+msg_como_jogar]
		call	caracter
		inc     bx						;proximo caracter
		inc		dl						;avanca a coluna
		cmp 	bl,ah					;se ainda não escreveu a linha toda, continua
		jl		cont2
		;se já, muda para a linha abaixo
		add 	ah,12
		sub 	dl,12
		add 	dh,1
	cont2:
		loop    lm5

	mov word [i_atual_comando], 0
	ret

segment data

	azul			equ		1
	branco			equ		7
	branco_intenso	equ		15

    titulo    		db  	'JOGO DA VELHA'
    campo_comando	db		'Campo de Comando:'
	campo_mensagem	db		'Campo de Mensagem:'
	msg_como_jogar	db		'Use o left  shift e nao use teclado numerico    para digitaras jogadas'