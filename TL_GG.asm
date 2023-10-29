; Grupo: Gabriel Gatti e Thiago Lahass
; Observação: como fizemos a leitura do programa nos baseando no código tecbuf.asm, o jogo tem algumas limitações:
; - para escrever o x ou c maiúsculos deve-se usar o shift esquerdo
; - para digitar as linhas e colunas, os números do tecado numérico não são reconhecidos (deve-se usar os que ficam acima das letras)
; - o enter do teclado numérico não é reconhecido 

extern inicia_jogo, caracter, circle, cursor, desenha_x, line, plot_xy, imprime_ultima_jog, imprime_jogada_inv, imprime_comando_inv, imprime_x_venceu, imprime_c_venceu, imprime_empatou, imprime_msg_apos_fim_jogo, limpa_campo_com, limpa_campo_msg, marca_celula11, marca_celula12, marca_celula13, marca_celula21, marca_celula22, marca_celula23, marca_celula31, marca_celula32, marca_celula33, f_verifica_leitura_jogada, func_verifica_jogada, f_verifica_ganhador, marca_ganhador

global cor, comando, cel_marcadas, cel_marcadas_c, cel_marcadas_x, ultima_jog_x_c, i_atual_comando, modo_anterior, venceu, resultado, celulas, leitura_jog_val, ultima_jog_val

segment code
..start:
	mov 	ax,data
	mov 	ds,ax
	mov 	ax,stack
	mov 	ss,ax
	mov 	sp,stacktop

	; ==================== Trecho de código retirado do programa tecbuf.asm fornecido pelo professor ====================
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
	; ===================================================================================================================
	call inicia_jogo

;leitura de comando
L1:
        ; ==================== Trecho de código retirado do programa tecbuf.asm fornecido pelo professor ====================
        MOV     AX,[p_i]	        			; loop - se não tem tecla pulsada, não faz nada! p_i só é atualizado (p_i = p_i + 1) na Rotina de Serviço de INTerrupção (ISR) "keyINT" 
        CMP     AX,[p_t]
        JE      L1
        INC     word[p_t]						; p_t - se atualiza (p_t = p_t + 1) só se p_i foi atualizado, ou seja, se teve tecla pulsada
        AND     word[p_t],7				
        MOV     BX,[p_t]						; Carrega em BX o valor de p_t
        XOR     AX, AX
        MOV     AL, [BX+tecla]					; Carrega em AL o valor da variável tecla (variável atualizada durante a ISR) mais o offset BX, AL <- [BX+tecla]  
		; ===================================================================================================================iável tecla (variável atualizada durante a ISR) mais o offset BX, AL <- [BX+tecla]  
		
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
		je 		enter_inv
		call 	imprime_msg_apos_fim_jogo
		jmp 	limpa_vetor
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
 	; ==================== Trecho de código retirado do programa tecbuf.asm fornecido pelo professor ====================
 	CLI									; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
	XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
	MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
	MOV     AX, [cs_dos]				; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
	MOV     [ES:INT9*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
	MOV     AX, [offset_dos]			; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
	MOV     [ES:INT9*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
	; ===================================================================================================================
	
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

; ==================== Trecho de código retirado do programa tecbuf.asm fornecido pelo professor ====================
keyINT:								; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX					; Salva contexto na pilha
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
        IRET						; Retorna da interrupção
; ===================================================================================================================


;*******************************************************************


segment data

	; ==================== Trecho de código retirado do programa tecbuf.asm fornecido pelo professor ====================
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
	; ===================================================================================================================

	i_atual_comando 	dw 0		; Índice atual do vetor de comando sendo digitado
	tam_max_vet_comando	equ 16
	comando 			resb tam_max_vet_comando		; Variável de 16 bytes para armazenar o comando sendo digitado
	make_c				equ 2Eh		; códigos Make/Break dos possíveis caracteres que compõem os comandos
	break_c				equ 0xAE
	make_s				equ 1Fh
	break_s				equ 9Fh
	make_enter			equ 1Ch
	break_enter			equ 9Ch
	make_backspace		equ 0Eh
	break_backspace		equ 8Eh
	make_shift			equ 2Ah
	break_shift			equ 0xAA

	cor			db		branco_intenso
	branco_intenso	equ		15

	modo_anterior	db		0
	linha   		dw  	0
	coluna  		dw  	0
	celulas			db		'112131122232132333'

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
