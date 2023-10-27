; FUNÇÕES DE DESENHAR FORMAS NAS CELULAS

global marca_celula11, marca_celula12, marca_celula13, marca_celula21, marca_celula22, marca_celula23, marca_celula31, marca_celula32, marca_celula33

extern circle, desenha_x, cel_marcadas, comando, cel_marcadas_c, cel_marcadas_x, ultima_jog_x_c, cor

marca_celula11:
		add 	word [cel_marcadas], 1						; muda a variavel cel_marcadas indicando que marcou a celula 11
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_11									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 1					; muda a variavel cel_marcadas_c indicando que marcou a celula 11
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [190,385]
		mov		byte[cor], vermelho
		mov		ax, 190
		push	ax
		mov		ax, 385
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca11
	marca_x_11:
		add 	word [cel_marcadas_x], 1					; muda a variavel cel_marcadas_x indicando que marcou a celula 11
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [190,385] (centro)
		mov		byte[cor], azul
		mov		ax,190
		push	ax
		mov		ax,385
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca11:
		ret

marca_celula12:
		add 	word [cel_marcadas], 2						; muda a variavel cel_marcadas indicando que marcou a celula 12
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_12									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 2					; muda a variavel cel_marcadas_c indicando que marcou a celula 12
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [320,385]
		mov		byte[cor], vermelho
		mov		ax, 320
		push	ax
		mov		ax, 385
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca12
	marca_x_12:
		add 	word [cel_marcadas_x], 2					; muda a variavel cel_marcadas_x indicando que marcou a celula 12
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [320,385] (centro)
		mov		byte[cor], azul
		mov		ax,320
		push	ax
		mov		ax,385
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca12:
		ret

marca_celula13:
		add 	word [cel_marcadas], 4						; muda a variavel cel_marcadas indicando que marcou a celula 13
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_13									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 4					; muda a variavel cel_marcadas_c indicando que marcou a celula 13
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [450,385]
		mov		byte[cor], vermelho
		mov		ax, 450
		push	ax
		mov		ax, 385
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca13
	marca_x_13:
		add 	word [cel_marcadas_x], 4					; muda a variavel cel_marcadas_x indicando que marcou a celula 13
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [450,385] (centro)
		mov		byte[cor], azul
		mov		ax,450
		push	ax
		mov		ax,385
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca13:
		ret

marca_celula21:
		add 	word [cel_marcadas], 8						; muda a variavel cel_marcadas indicando que marcou a celula 21
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_21									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 8					; muda a variavel cel_marcadas_c indicando que marcou a celula 21
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [190,255]
		mov		byte[cor], vermelho
		mov		ax, 190
		push	ax
		mov		ax, 255
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca21
	marca_x_21:
		add 	word [cel_marcadas_x], 8					; muda a variavel cel_marcadas_x indicando que marcou a celula 21
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [190,255] (centro)
		mov		byte[cor], azul
		mov		ax,190
		push	ax
		mov		ax,255
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca21:
		ret

marca_celula22:
		add 	word [cel_marcadas], 16						; muda a variavel cel_marcadas indicando que marcou a celula 22
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_22									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 16					; muda a variavel cel_marcadas_c indicando que marcou a celula 22
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [320,255]
		mov		byte[cor], vermelho
		mov		ax, 320
		push	ax
		mov		ax, 255
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca22
	marca_x_22:
		add 	word [cel_marcadas_x], 16					; muda a variavel cel_marcadas_x indicando que marcou a celula 22
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [320,255] (centro)
		mov		byte[cor], azul
		mov		ax,320
		push	ax
		mov		ax,255
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca22:
		ret

marca_celula23:
		add 	word [cel_marcadas], 32						; muda a variavel cel_marcadas indicando que marcou a celula 23
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_23									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 32					; muda a variavel cel_marcadas_c indicando que marcou a celula 23
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [450,255]
		mov		byte[cor], vermelho
		mov		ax, 450
		push	ax
		mov		ax, 255
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca23
	marca_x_23:
		add 	word [cel_marcadas_x], 32					; muda a variavel cel_marcadas_x indicando que marcou a celula 23
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [450,255] (centro)
		mov		byte[cor], azul
		mov		ax,450
		push	ax
		mov		ax,255
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca23:
		ret

marca_celula31:
		add 	word [cel_marcadas], 64						; muda a variavel cel_marcadas indicando que marcou a celula 31
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_31									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 64					; muda a variavel cel_marcadas_c indicando que marcou a celula 31
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [190,125]
		mov		byte[cor], vermelho
		mov		ax, 190
		push	ax
		mov		ax, 125
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca31
	marca_x_31:
		add 	word [cel_marcadas_x], 64					; muda a variavel cel_marcadas_x indicando que marcou a celula 31
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [190,125] (centro)
		mov		byte[cor], azul
		mov		ax,190
		push	ax
		mov		ax,125
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca31:
		ret

marca_celula32:
		add 	word [cel_marcadas], 128					; muda a variavel cel_marcadas indicando que marcou a celula 32
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_32									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 128					; muda a variavel cel_marcadas_c indicando que marcou a celula 32
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [320,125]
		mov		byte[cor], vermelho
		mov		ax, 320
		push	ax
		mov		ax, 125
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca32
	marca_x_32:
		add 	word [cel_marcadas_x], 128					; muda a variavel cel_marcadas_x indicando que marcou a celula 32
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [320,125] (centro)
		mov		byte[cor], azul
		mov		ax,320
		push	ax
		mov		ax,125
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca32:
		ret

marca_celula33:
		add 	word [cel_marcadas], 256					; muda a variavel cel_marcadas indicando que marcou a celula 33
		cmp 	byte [comando+1], make_x					; verifica se é x
		je		marca_x_33									; se é, marca x
		; se não, marca c
		add 	word [cel_marcadas_c], 256					; muda a variavel cel_marcadas_c indicando que marcou a celula 33
		mov 	byte [ultima_jog_x_c], make_c				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o c
		;desenhar um circulo na posicão [450,125]
		mov		byte[cor], vermelho
		mov		ax, 450
		push	ax
		mov		ax, 125
		push	ax
		mov		ax, raio
		push	ax
		call 	circle
		jmp 	fim_marca33
	marca_x_33:
		add 	word [cel_marcadas_x], 256					; muda a variavel cel_marcadas_x indicando que marcou a celula 33
		mov 	byte [ultima_jog_x_c], make_x				; muda a variável ultima_jog_x_c indicando que o ultimo a jogar foi o x
		;desenhar um x na posicão [450,125] (centro)
		mov		byte[cor], azul
		mov		ax,450
		push	ax
		mov		ax,125
		push	ax
		mov		ax, lado
		push	ax
		call	desenha_x
	fim_marca33:
		ret


segment data

	make_c			equ 	2Eh		; códigos Make/Break dos possíveis caracteres que compõem os comandos
	make_x			equ 	2Dh

	azul			equ		1
	vermelho		equ		4

	raio			equ		45
	lado			equ		45