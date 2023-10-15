; Grupo: Gabriel Gatti e Thiago Lahass

segment code
..start:
	mov 	ax,data
	mov 	ds,ax
	mov 	ax,stack
	mov 	ss,ax
	mov 	sp,stacktop

	CLI											; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas	
	XOR     AX, AX								; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
	MOV     ES, AX								; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
	MOV     AX, [ES:INT9*4]						; Carrega em AX o valor do IP do vector de INTerrupção 9 
	MOV     [offset_dos], AX    	        	; Salva na variável offset_dos o valor do IP do vector de INTerrupção 9
	MOV     AX, [ES:INT9*4+2]   	        	; Carrega em AX o valor do CS do vector de INTerrupção 9
	MOV     [cs_dos], AX						; Salva na variável cs_dos o valor do CS do vector de INTerrupção 9     
	MOV     [ES:INT9*4+2], CS					; Atualiza o valor do CS do vector de INTerrupção 9 com o CS do programa atual 
	MOV     WORD [ES:INT9*4],keyINT         	; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "keyINT" do programa atual
	STI											; Habilita INTerrupções por hardware - pin INTR SIM atende INTerrupções externas

	call inicia_jogo

;leitura de comando
L1:
        MOV     AX,[p_i]	        			; loop - se não tem tecla pulsada, não faz nada! p_i só é atualizado (p_i = p_i + 1) na Rotina de Serviço de INTerrupção (ISR) "keyINT" 
        CMP     AX,[p_t]
        JE      L1
        INC     word[p_t]						; p_t - se atualiza (p_t = p_t + 1) só se p_i foi atualizado, ou seja, se teve tecla pulsada
        AND     word[p_t],7				
        MOV     BX,[p_t]						; Carrega em BX o valor de p_t
        XOR     AX, AX
        MOV     AL, [BX+tecla]					; Carrega em AL o valor da variável tecla (variável atualizada durante a ISR) mais o offset BX, AL <- [BX+tecla]  
		
		mov		bx, [i_atual_comando]			; carrega em bx o indice do vetor de comando
		mov 	[comando+bx], al				; transfere o valor make/break da tecla digitada
		inc  	word [i_atual_comando]			; incrementa o indice

		; verificações
		cmp 	byte [comando], break_enter		; se acabou de começar o jogo, lê o break do enter e limpa o vetor
		jne 	verifica_backspace
		mov 	word [i_atual_comando], 0		; índice volta para a primeira posição
		jmp 	L1								; lê novamente
	verifica_backspace:
		cmp 	byte [comando+bx], break_backspace ; se não, verifica se digitou backspace
		jne 	verifica_tam_vetor				; se não, segue verificando
		cmp 	bx, 3							; se sim, verifica se o tamanho atual do vetor é <= 4
		jg		sub4							
		mov 	word [i_atual_comando], 0		; se sim, limpa o vetor (make e break do backspace + possivelmente make e break de outra tecla)
		jmp 	L1								
	sub4:	
		sub  	word [i_atual_comando], 4		; se não, subtrai o indice do vetor em 4
		jmp 	L1								; volta a ler

	verifica_tam_vetor:
		cmp		word [i_atual_comando], tam_max_vet_comando ; verifica se estourou o tamanho máximo do vetor
		jne		verifica_enter					; se não, segue verificando
		call 	imprime_comando_inv				; se sim, imprime comanda inválido e limpa o vetor
		jmp 	limpa_vetor

	verifica_enter:
		cmp 	byte [comando+bx], break_enter	; verifica se digitou Enter
		jne 	L1								; se não, continua lendo

		call 	limpa_campo_msg					; se apertou Enter limpa o campo de mensagem
		call 	limpa_campo_com					; se apertou Enter limpa o campo de comando

		cmp 	bx, 3							; se apertou 2 teclas -> verifica Enter + 'c' e Enter + 's'
		je	 	verifica_s_c
		jg 		verifica_tamanho				; se apertou mais de 2 teclas -> verifica o tamanho do vetor
		; se apertou somente Enter
		cmp 	byte [resultado], 0				; verifica se digitou apos fim do jogo
		call 	imprime_msg_apos_fim_jogo
		jmp 	limpa_vetor
		je 		enter_inv
	enter_inv:
		call 	imprime_comando_inv				; se apertou só Enter -> comando inválido
		jmp		limpa_vetor

	verifica_s_c:
		cmp 	byte [comando+1], break_s		; se Enter + 's' -> sai do jogo
		je 		L2_intermediario
		cmp 	byte [comando+1], break_c		; se Enter + 'c' -> renicia jogo
		jne 	s_c_inv
		call 	inicia_jogo
		jmp		L1
	s_c_inv:
		cmp 	byte [resultado], 0				; verifica se digitou apos fim do jogo
		jne 	msg_apos_fim_jogo
		call 	imprime_comando_inv				; se Enter + qualquer outra tecla -> comando inválido
		jmp 	limpa_vetor
		
	verifica_tamanho:
		cmp 	byte [resultado], 0				; verifica se digitou apos fim do jogo
		jne 	msg_apos_fim_jogo
		cmp		bx, 9							; se o vetor tem tamanho 10 -> verifica se é jogada
		je		verifica_comando_jogada
		call 	imprime_comando_inv				; se não, comando inválido
		jmp 	limpa_vetor
	verifica_comando_jogada:					; jogada = make_shift + x ou c + break_shift + num1 + num2 + enter
		call 	f_verifica_leitura_jogada		; ao final da função sabe-se se a jogada está no formato pelo valor da variavel leitura_jog_val
		cmp 	byte [leitura_jog_val], 1			
		je 		verifica_validade_jogada		; se está no formato, verifica se é válida
		call 	imprime_comando_inv				; se não, comando inválido
		jmp 	limpa_vetor
	verifica_validade_jogada:
		call 	imprime_ultima_jog				; se o ultimo comando de jogada esta no formato correto, imprime
		call 	func_verifica_jogada			; função que verifica se a jogada é valida, se for marca a celula e muda o valor de ultima_jog_val para 1
		cmp 	byte [ultima_jog_val], 1
		jne		jogada_inv						; se a ultima jogada foi inválida, imprime msg inv e lê de novo
		call 	f_verifica_ganhador				; função que verifica se alguem venceu
		cmp 	byte [resultado], 1				; verifica se X venceu
		jne 	verifica_c_venceu
		call 	imprime_x_venceu				; X VENCEU!
		jmp 	limpa_vetor

	L2_intermediario:
		jmp L2

	verifica_c_venceu:
		cmp 	byte [resultado], 2				; verifica se C venceu
		jne 	verifica_empate
		call 	imprime_c_venceu				; C VENCEU!
		jmp 	limpa_vetor
	verifica_empate:
		cmp 	word [cel_marcadas], 0x01FF		; verifica se todas as celulas foram marcadas
		jne 	limpa_vetor
		call 	imprime_empatou					; EMPATOU!
		mov 	byte [resultado], 3
		jmp 	limpa_vetor
		
	jogada_inv:
		call	imprime_jogada_inv				; se não, jogada invalida

	limpa_vetor:
		mov 	word [i_atual_comando], 0		; índice volta para a primeira posição
		jmp 	L1								; lê novamente

	msg_apos_fim_jogo:
		call 	imprime_msg_apos_fim_jogo
		jmp 	limpa_vetor
; TERMINAR EXECUÇÃO DO PROGRAMA
; reseta o modo de video
L2:
 	CLI									; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
	XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
	MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
	MOV     AX, [cs_dos]				; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
	MOV     [ES:INT9*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
	MOV     AX, [offset_dos]			; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
	MOV     [ES:INT9*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
	
	mov    	ah,08h
	int     21h
	mov  	ah,0   						; set video mode
	mov  	al,[modo_anterior]   		; modo anterior
	int  	10h
	mov     ax,4c00h
	int     21h

;===========================================================================
;========================== FIM DO PROGRAMA ================================
;===========================================================================

keyINT:						; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX				; Salva contexto na pilha
        PUSH    BX
        PUSH    DS
        MOV     AX,data				; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
        MOV     DS,AX				; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
        IN      AL, kb_data			; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        INC     WORD [p_i]			; Incrementa p_i para indicar no loop principal que uma tecla foi acionada!
        AND     WORD [p_i],7			
        MOV     BX,[p_i]			; Carrega p_i em BX
        MOV     [BX+tecla],al		; Transfere o valor Make/Break da tecla armacenado em AL "linha 84" para o segmento de dados com offset DX, na variável "tecla"
        IN      AL, kb_ctl			; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h				; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL			; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh				; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL			; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi				; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL			; Livera o PIC
        
		POP     DS			        ; Reestablece os registradores salvos na linha 79 
        POP     BX
        POP     AX
        IRET					; Retorna da interrupção

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

	;escrever mensagem de comando
		mov     cx,16					;número de caracteres
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
		mov     cx,17					;número de caracteres
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
	mov word [i_atual_comando], 0
	ret

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
;***************************************************************************
;
;   função desenha_x
;	lado estático de 'lado'px == 55 px
;
; push xc; push yc; call desenha_x;  (xc+l<639,yc+l<479)e(xc-l>0,yc-l>0)
; cor definida na variavel cor
desenha_x:
	push 	bp
	mov	 	bp,sp
	pushf               	;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+8]   	; resgata xc
	mov		bx,[bp+6]    	; resgata yc
	mov		cx,[bp+4]		; resgata l
	
	;desenha primeira diagonal
	mov 	dx,ax			
	sub		dx,cx	; Ponto inferior esquerdo
	push	dx
	mov 	dx,bx
	sub		dx,cx
	push    dx

	mov 	dx,ax
	add		dx,cx	; Ponto superior direito
	push	dx
	mov 	dx,bx
	add		dx,cx
	push    dx

	call line

	;desenha segunda diagonal
	mov 	dx,ax			
	add		dx,cx	; Ponto inferior direito
	push	dx
	mov 	dx,bx
	sub		dx,cx
	push    dx

	mov 	dx,ax
	sub		dx,cx	; Ponto superior esquerdo
	push	dx
	mov 	dx,bx
	add		dx,cx
	push    dx

	call line

	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6


;***************************************************************************
;
;   função cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	mov     ah,2
	mov     bh,0
	int     10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret


;_____________________________________________________________________________
;
; função caracter escrito na posisão do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	mov     ah,9
	mov     bh,0
	mov     cx,1
	mov     bl,[cor]
	int     10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret


;_____________________________________________________________________________
;
;   função plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
	push	bp
	mov		bp,sp
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	mov    	ah,0ch
	mov     al,[cor]
	mov     bh,0
	mov     dx,479
	sub		dx,[bp+4]
	mov     cx,[bp+6]
	int     10h
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		4


;_____________________________________________________________________________
;    função circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push 	bp
	mov	 	bp,sp
	pushf               	;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+8]   	; resgata xc
	mov		bx,[bp+6]    	; resgata yc
	mov		cx,[bp+4]    	; resgata r
	
	mov 	dx,bx	
	add		dx,cx      		;ponto extremo superior
	push    ax			
	push	dx
	call 	plot_xy
	
	mov		dx,bx
	sub		dx,cx       	;ponto extremo inferior
	push    ax			
	push	dx
	call 	plot_xy
	
	mov 	dx,ax	
	add		dx,cx       	;ponto extremo direita
	push    dx			
	push	bx
	call 	plot_xy
	
	mov		dx,ax
	sub		dx,cx       	;ponto extremo esquerda
	push    dx			
	push	bx
	call 	plot_xy
		
	mov		di,cx
	sub		di,1	 		;di=r-1
	mov		dx,0  			;dx será a variável x. cx é a variavel y
	
;aqui em cima a lógica foi invertida, 1-r => r-1
;e as comparações passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:						;loop
	mov		si,di
	cmp		si,0
	jg		inf      		;caso d for menor que 0, seleciona pixel superior (não  salta)
	mov		si,dx			;o jl é importante porque trata-se de conta com sinal
	sal		si,1			;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si    		;nesse ponto d=d+2*dx+3
	inc		dx				;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  			;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si			;nesse ponto d=d+2*(dx-cx)+5
	inc		dx				;incrementa x (dx)
	dec		cx				;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si				;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si				;coloca a ordenada y+yc na pilha
	call 	plot_xy			;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si				;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si				;coloca a ordenada yc-y na pilha
	call 	plot_xy			;toma conta do sétimo octante
	mov		si,ax
	add		si,cx
	push    si				;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si				;coloca a ordenada yc+x na pilha
	call 	plot_xy			;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si				;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si				;coloca a ordenada yc-x na pilha
	call 	plot_xy			;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si				;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si				;coloca a ordenada yc+y na pilha
	call 	plot_xy			;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si				;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si				;coloca a ordenada yc-y na pilha
	call 	plot_xy			;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si				;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si				;coloca a ordenada yc-x na pilha
	call 	plot_xy			;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si				;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si				;coloca a ordenada yc-x na pilha
	call 	plot_xy			;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle 		;se cx (y) está abaixo de dx (x), termina     
	jmp		stay			;se cx (y) está acima de dx (x), continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6


;-----------------------------------------------------------------------------
;
;   função line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
	push	bp
	mov		bp,sp
	pushf              		;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	mov		ax,[bp+10]   	; resgata os valores das coordenadas
	mov		bx,[bp+8]    	; resgata os valores das coordenadas
	mov		cx,[bp+6]    	; resgata os valores das coordenadas
	mov		dx,[bp+4]    	; resgata os valores das coordenadas
	cmp		ax,cx
	je		line2
	jb		line1
	xchg	ax,cx
	xchg	bx,dx
	jmp		line1
line2:						; deltax=0
	cmp		bx,dx  			;subtrai dx de bx
	jb		line3
	xchg	bx,dx     		;troca os valores de bx e dx entre eles
line3:						; dx > bx
	push	ax
	push	bx
	call 	plot_xy
	cmp		bx,dx
	jne		line31
	jmp		fim_line
line31:
	inc		bx
	jmp		line3
;deltax <>0
line1:
; comparar módulos de deltax e deltay sabendo que cx>ax
; cx > ax
	push	cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push	dx
	sub		dx,bx
	ja		line32
	neg		dx
line32:		
	mov		[deltay],dx
	pop		dx

	push	ax
	mov		ax,[deltax]
	cmp		ax,[deltay]
	pop		ax
	jb		line5

; cx > ax e deltax>deltay
	push	cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push	dx
	sub		dx,bx
	mov		[deltay],dx
	pop		dx

	mov		si,ax
line4:
	push	ax
	push	dx
	push	si
	sub		si,ax			;(x-x1)
	mov		ax,[deltay]
	imul	si
	mov		si,[deltax]		;arredondar
	shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
	cmp		dx,0
	jl		ar1
	add		ax,si
	adc		dx,0
	jmp		arc1
ar1:
	sub		ax,si
	sbb		dx,0
arc1:
	idiv	word [deltax]
	add		ax,bx
	pop		si
	push	si
	push	ax
	call	plot_xy
	pop		dx
	pop		ax
	cmp		si,cx
	je		fim_line
	inc		si
	jmp		line4

line5:	
	cmp		bx,dx
	jb 		line7
	xchg	ax,cx
	xchg	bx,dx
line7:
	push	cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push	dx
	sub		dx,bx
	mov		[deltay],dx
	pop		dx
	mov		si,bx
line6:
	push	dx
	push	si
	push	ax
	sub		si,bx			;(y-y1)
	mov		ax,[deltax]
	imul	si
	mov		si,[deltay]		;arredondar
	shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
	cmp		dx,0
	jl		ar2
	add		ax,si
	adc		dx,0
	jmp		arc2
ar2:
	sub		ax,si
	sbb		dx,0
arc2:
	idiv	word [deltay]
	mov		di,ax
	pop		ax
	add		di,ax
	pop		si
	push	di
	push	si
	call	plot_xy
	pop		dx
	cmp		si,dx
	je		fim_line
	inc		si
	jmp		line6

fim_line:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		8
;*******************************************************************


segment data

	kb_data EQU 60h  			; PORTA DE LEITURA DE TECLADO
	kb_ctl  EQU 61h  			; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
	pictrl  EQU 20h				; PORTA DO PIC DE TECLADO
	eoi     EQU 20h				; Byte de final de interrupção PIC - resgistrador
	INT9    EQU 9h				; Interrupção por hardware do teclado
	cs_dos  DW  1				; Variável de 2 bytes para armacenar o CS da INT 9
	offset_dos  DW 1			; Variável de 2 bytes para armacenar o IP da INT 9
	tecla   resb  8				; Variável de 8 bytes para armacenar a tecla presionada. Só precisa de 2 bytes!	 
	p_i     dw  0   			; Indice p/ Interrupcao (Incrementa na ISR quando pressiona/solta qualquer tecla)  
	p_t     dw  0   			; Indice p/ Interrupcao (Incrementa após retornar da ISR quando pressiona/solta qualquer tecla) 

	i_atual_comando 	dw 0		; Índice atual do vetor de comando sendo digitado
	tam_max_vet_comando	equ 16
	comando 			resb tam_max_vet_comando		; Variável de 16 bytes para armazenar o comando sendo digitado
	make_c				equ 2Eh		; códigos Make/Break dos possíveis caracteres que compõem os comandos
	break_c				equ 0xAE
	make_s				equ 1Fh
	break_s				equ 9Fh
	make_x				equ 2Dh
	break_x				equ 0xAD
	make_1				equ 02h
	break_1				equ 82h
	make_2				equ 03h
	break_2				equ 83h
	make_3				equ 04h
	break_3				equ 84h
	make_enter			equ 1Ch
	break_enter			equ 9Ch
	make_backspace		equ 0Eh
	break_backspace		equ 8Eh
	make_shift			equ 2Ah
	break_shift			equ 0xAA

	cor			db		branco_intenso

	;	I R G B COR
	;	0 0 0 0 preto
	;	0 0 0 1 azul
	;	0 0 1 0 verde
	;	0 0 1 1 cyan
	;	0 1 0 0 vermelho
	;	0 1 0 1 magenta
	;	0 1 1 0 marrom
	;	0 1 1 1 branco
	;	1 0 0 0 cinza
	;	1 0 0 1 azul claro
	;	1 0 1 0 verde claro
	;	1 0 1 1 cyan claro
	;	1 1 0 0 rosa
	;	1 1 0 1 magenta claro
	;	1 1 1 0 amarelo
	;	1 1 1 1 branco intenso

	preto			equ		0
	azul			equ		1
	verde			equ		2
	cyan			equ		3
	vermelho		equ		4
	magenta			equ		5
	marrom			equ		6
	branco			equ		7
	cinza			equ		8
	azul_claro		equ		9
	verde_claro		equ		10
	cyan_claro		equ		11
	rosa			equ		12
	magenta_claro	equ		13
	amarelo			equ		14
	branco_intenso	equ		15

	raio			equ		45
	lado			equ		45

	modo_anterior	db		0
	linha   		dw  	0
	coluna  		dw  	0
	deltax			dw		0
	deltay			dw		0	
	titulo    		db  	'JOGO DA VELHA'
	campo_comando	db		'Campo de Comando'
	campo_mensagem	db		'Campo de Mensagem'
	celulas			db		'112131122232132333'
	msg_com_inv		db		'Comando Invalido'
	msg_jog_inv		db		'Jogada Invalida'
	msg_limpa_com	db		'000'
	msg_x_venceu	db		'X VENCEU!'
	msg_c_venceu	db		'C VENCEU!'
	msg_empatou		db		'EMPATOU!'
	msg_fim_jogo	db		'Digite s + Enter para sair ou c + Enter para reiniciar' 
	leitura_jog_val db		0						; Variável que indica se a jogada está no formato esperado ou se é comando inválido
	ultima_jog_val	db		0						; Variável que indica se a ultima jogada feita é válida
	ultima_jog_x_c 	db		0						; Variável que indica se a ultima jogada feita foi c ou x, guarda o make code
	cel_marcadas	dw 		0						; Variável que indica quais celulas foram marcadas
													; bit0 = 11, bit1 = 12, bit3 = 13, bit4 = 21, ..., bit8 = 33
	cel_marcadas_x	dw		0						; Variável que indica quais celulas foram marcadas com x
	cel_marcadas_c	dw		0						; Variável que indica quais celulas foram marcadas com c	
	venceu 			dw 		0 						; variável que indica se algum jogador venceu e como venceu (se = 0, nimguem venceu)
													; valor em hexa indica como venceu
													; 11-21-31 = 001001001 = 0x0049 
													; 12-22-32 = 010010010 = 0x0092	
													; 13-23-33 = 100100100 = 0x0124
													; 11-12-13 = 000000111 = 0x0007
													; 21-22-23 = 000111000 = 0x0038
													; 31-32-33 = 111000000 = 0x01C0
													; 11-22-33 = 100010001 = 0x0111
													; 13-22-31 = 001010100 = 0x0054
	resultado		db		0						; jogo n terminou = 0, ganhou x = 1, ganhou c = 2, empate = 3
;*************************************************************************
segment stack stack
    			resb 	512
stacktop:
