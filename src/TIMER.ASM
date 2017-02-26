.data

SECONDS DW 0000H

.code

DRW_TIMER proc
		push ax
		push dx

		mov ax, SECONDS  	; Segundos atuais
		call PARSE_TO_INT 	; Converte o numero em ax e armazena em CUR_INT(current integer)

		mov dh, 1			
		mov dl, 63			
		call SET_CUR_POS	; Move o cursor para a linha 1 e coluna 63

		mov dx, offset CUR_INT
		mov ah, 9
		mov al, 0
		int 21H 			; Escreve a string CUR_INT que está em DX na posição do cursor

		pop dx
		pop ax
		ret
ENDP

TIMER_TICK proc
		push bx
		push dx
		push cx

		xor dx, dx
		xor cx, cx
		
		call GET_SYS_TIME 	; Temos os segundos no DH e minutos em CL 
		mov bh, dh	 		; Salva os segundos no BH
		mov bl, cl	 		; Salva minutos no BL

WAITING:call GET_SYS_TIME 	; Pega novamente minutos e segundos

		cmp cl, bl			; Verifica se está virando o minuto
		jne TICK 			; Se virou incrementa os segundos
	
		cmp bh, dh			; Compara se passou 1 seg
		jnb WAITING 		; Se não passou, espera. Se passou incrementa os segundos
	
TICK:	mov ax, SECONDS		; Pega os segundos anteriores ao tick em AX
		inc ax 				; Incrementa os segundos
		mov di, offset SECONDS
		mov [di], ax 		; Salva os segundos em SECONDS

		pop cx
		pop dx
		pop bx
		ret
ENDP