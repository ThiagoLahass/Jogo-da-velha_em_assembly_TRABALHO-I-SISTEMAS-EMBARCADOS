;***************************************************************************
;
;   função desenha_x
;
; push xc; push yc, push l; call desenha_x;  (xc+l<639,yc+l<479)e(xc-l>0,yc-l>0)
; cor definida na variavel cor

global desenha_x

extern line

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
