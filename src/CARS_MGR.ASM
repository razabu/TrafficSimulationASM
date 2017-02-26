.data

; Direção é mapeada da seguinte forma:
DIR_UP EQU 0	; 00 = ↑ 
DIR_LEFT EQU 1	; 01 = ←
DIR_RIGHT EQU 2 ; 10 = →
DIR_DOWN EQU 3 	; 11 = ↓

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cada byte é mapeado da seguinte forma: 									 ;
; | ISUPDATED | 0 | COR | COR | DIRECTION | DIRECTION | ISMOVIN | PRESENCE | ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CARS_MATRIX db 25 dup (56 dup (0))
CM_LINE_SIZE EQU 56			; Tamanho da linha da matriz

ROW_STATE db 5 dup (0) 		; Variável para status da fileira

.code

SPAWN_CARS proc
		push ax
		push bx
		push cx
		push dx

		xor cx, cx
		mov cl, al
		shr cl, 4 			; Mantém a quantidade de carros a serem instanciados
		
		mov bl, al
		and bl, 0FH 		; Mantém somente os 4 bits menos significativos

		mov al, 0FH
		mov dh, 0

		cmp bl, 0 			; Norte-Sul -> Siga em frente
		jne SW1
		mov dl, 25
		jmp SPAWN

SW1: 	cmp bl, 1H 			; Norte-Sul -> Conversão à esquerda
		jne SW2
		mov dl, 27
		jmp SPAWN

SW2: 	cmp bl, 2H 			; Norte-Sul -> Conversão à direita
		jne SW3
		mov dl, 23
		jmp SPAWN

SW3: 	mov al, 3H
		mov dh, 24

		cmp bl, 3H 			; Sul-Norte -> Siga em frente
		jne SW4
		mov dl, 29
		jmp SPAWN

SW4: 	cmp bl, 4H 			; Sul-Norte -> Conversão à esquerda
		jne SW5
		mov dl, 27
		jmp SPAWN

SW5: 	cmp bl, 5H 			; Sul-Norte -> Conversão à direita
		jne SW6
		mov dl, 31
		jmp SPAWN

SW6: 	mov al, 0BH
		mov dl, 0

		cmp bl, 6H 			; Oeste-Leste -> Siga em frente
		jne SW7
		mov dh, 13
		jmp SPAWN

SW7: 	cmp bl, 7H 			; Oeste-Leste -> Conversão à esquerda
		jne SW8
		mov dh, 12
		jmp SPAWN

SW8: 	cmp bl, 8H 			; Oeste-Leste -> Conversão à direita
		jne SW9
		mov dh, 14
		jmp SPAWN

SW9: 	mov al, 7H
		mov dl, 55

		cmp bl, 9H 			; Leste-Oeste -> Siga em frente
		jne SW10	
		mov dh, 11
		jmp SPAWN

SW10: 	cmp bl, 0AH 		; Leste-Oeste -> Conversão à esquerda
		jne SW11
		mov dh, 12
		jmp SPAWN

SW11: 	cmp bl, 0BH
		jne END_SPW
		mov dh, 10			; Leste-Oeste -> Conversão à direita

SPAWN: 	call SPAWN_CAR
		
		cmp bl, 3
		jns SPW_SN
		add dh, 2
		jmp LP_SPW

SPW_SN: cmp bl, 6
		jns SPW_LO
		sub dh, 2
		jmp LP_SPW

SPW_LO: cmp bl, 9
		jns SPW_OL
		add dl, 5
		jmp LP_SPW

SPW_OL: sub dl, 5

LP_SPW:	loop SPAWN

END_SPW:pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

SPAWN_CAR proc
		push ax
		push bx
		push cx

		; Verifica se existe carro na posição DH DL
		mov cx, ax
		mov bx, offset CARS_MATRIX
		call GET_MATRIX_ELEMENT
		call TEST_PRESENCE
		jc END_SPAWN
		mov ax, cx

		; Random pra cor
		push dx

		xor cx, cx
		mov cl, 4
		call GET_RAND_UINT 	; Pega um número aleatório em CL, menor do que o enviado em CL
		shl dl, 4
		or al, dl
		
		pop dx

		mov bx, offset CARS_MATRIX
		call WRITE_MATRIX_ELEMENT
		clc

END_SPAWN:
		pop cx
		pop bx
		pop ax
		ret
ENDP

DRW_CARS proc 				; Desenha todos os carros da matrix
		push ax
		push bx
		push cx
		push dx

		xor dx, dx 			; Zera dx
		mov bx, offset CARS_MATRIX
		jmp DRWC 			

IL: 	inc dh 				; Incrementa o indice da linha
		cmp dh, 25 			; Compara com o ultimo indice endereçavel
		jz ENDDRWC 			; Caso seja, acaba o procedimento
		xor dl, dl 			; Caso não seja, zera a coluna e continua o procedimento

DRWC:	call GET_MATRIX_ELEMENT
		call TEST_PRESENCE 	; Verifica se há carro na posição [DH][DL]
		jnc IC 				; Se não tiver, incrementa a posição
		call DRW_CAR 		; se tiver, desenha o carro

IC:		inc dl 				; Incrementa o indice da coluna
		cmp dl, CM_LINE_SIZE; Verifica se é a ultima coluna
		jnz DRWC 			; Se não for, continua o procedimento de desenhar
		jmp IL 			 	; se for a ultima coluna, incrementa a linha

ENDDRWC:pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

DRW_CAR proc 				; Desenha o carro em AX na Linha DH e na coluna DL
		push ax
		push bx
		push cx

		call GET_COLOR 		; Retorna a cor do carro em BL
		add bl , 1 			; Impede que seja a cor "0"

		mov al, SQR_CHAR	; Move para AL o caracter de carro
		call SET_CUR_POS 	; Seta a posição do cursor
		call WRITE_CHAR_C	; Escreve o caracter de carro na posição do cursor, com a cor em BL

		pop cx
		pop bx
		pop ax
		ret
ENDP

DRW_CARS_STATUS proc
		push ax
		push bx
		push cx
		push dx

		mov dh, 0
		mov dl, 23
		call GET_ROW_NS
		call COUNT_CARS
		mov bx, ax

		mov dh, 0
		mov dl, 25
		call GET_ROW_NS
		call COUNT_CARS
		add bx, ax

		mov dh, 0
		mov dl, 27
		call GET_ROW_NS
		call COUNT_CARS
		add bx, ax

		mov ax, bx
		call PARSE_TO_INT
		mov dl, 69 			; Posição dos status
		mov dh, 9 			; Posição do status "Carros" - Norte-Sul
		call SET_CUR_POS
		mov dx, offset CUR_INT
		call WRITE_STR

		mov dh, 24
		mov dl, 27
		call GET_ROW_SN
		call COUNT_CARS
		mov bx, ax

		mov dh, 24
		mov dl, 29
		call GET_ROW_SN
		call COUNT_CARS
		add bx, ax

		mov dh, 24
		mov dl, 31
		call GET_ROW_SN
		call COUNT_CARS
		add bx, ax

		mov ax, bx
		mov dh, 12 			; Posição do status "Carros" - Sul-Norte
		mov dl, 69
		call SET_CUR_POS
		call PARSE_TO_INT
		mov dx, offset CUR_INT
		call WRITE_STR

		mov dl, 0
		mov dh, 12
		call GET_ROW_OL
		call COUNT_CARS
		mov bx, ax

		mov dl, 0
		mov dh, 13
		call GET_ROW_OL
		call COUNT_CARS
		add bx, ax

		mov dl, 0
		mov dh, 14
		call GET_ROW_OL
		call COUNT_CARS
		add bx, ax

		mov ax, bx
		call PARSE_TO_INT

		mov dh, 15 			; Posição do status "Carros" - Oeste-Leste
		mov dl, 69
		call SET_CUR_POS
		mov dx, offset CUR_INT
		call WRITE_STR

		mov dh, 10
		mov dl, 55
		call GET_ROW_LO
		call COUNT_CARS
		mov bx, ax

		mov dh, 11
		mov dl, 55
		call GET_ROW_LO
		call COUNT_CARS
		add bx, ax

		mov dh, 12
		mov dl, 55
		call GET_ROW_LO
		call COUNT_CARS
		add bx, ax

		mov ax, bx
		call PARSE_TO_INT
		mov dh, 18 			; Posição do status "Carros" - Leste-Oeste
		mov dl, 69
		call SET_CUR_POS
		mov dx, offset CUR_INT
		call WRITE_STR

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

COUNT_CARS proc
		push bx
		push cx
		push dx
		push si

		xor ax, ax
		xor si, si

		mov bx, offset ROW_STATE
		mov cx, 5
COUNT:	mov dl, byte ptr bx[si]
		cmp dl, '1'
		jne LP_COUNT
		inc ax
LP_COUNT:
		inc si
		loop COUNT

		pop si
		pop dx
		pop cx
		pop bx
		ret
ENDP

UPDT_CARS proc 				; Atualiza posições da matrix e da tela
		push ax
		push bx
		push cx
		push dx

		xor dx, dx 			; Zera DX - Linha 0, Coluna 0
		mov bx, offset CARS_MATRIX
		call RESET_STATUS 	; Reseta o bit 'está atualizado'
		jmp UPD 			; Começa a atualização da matrix

INC_LN: inc dh 				; Incrementa o indice da linha
		cmp dh, 25 			; Compara com o ultimo indice endereçavel
		jz END_UPD 			; Caso seja, acaba o procedimento
		xor dl, dl 			; Caso não seja, zera a coluna e continua o procedimento

UPD:	call GET_MATRIX_ELEMENT
		call TEST_PRESENCE 	; Testa se existe carro na posição atual da matrix
		jnc INC_COL 		; Caso não tenha carro incrementa o índice da coluna

		; Atualiza a posição
		call TEST_UPDATED 	; Verifica se o carro já foi atualizado
		jc INC_COL 			; Caso ja tenha sido atualizado, incrementa o indice da coluna
		call MOVE_CAR 		; Caso esteja em movimento e nao tenha sido atualizado, atualiza a posição

INC_COL:inc dl 				; Incrementa o indice da coluna
		cmp dl, CM_LINE_SIZE; Compara com o ultimo indice endereçavel
		jnz UPD 			; Caso não seja, continua o procedimento de atualização
		jmp INC_LN 			; Caso seja a ultima coluna, incrementa a linha

END_UPD:pop dx 				; Termina a atualização
		pop cx
		pop bx
		pop ax
		ret
ENDP

MOVE_CAR proc 				; Move os carro em AL da posição [DH][DL] para sua respectiva direção
		push ax
		push bx
		push cx
		push dx

		call GET_DIR 		; Recebe em CL a direçao do carro em AL

		; Verifica a direção do carro atual e chama a respectiva proc
		cmp cl, DIR_UP
		jne DOWN
		call MOV_CAR_SN
		jmp END_MV_CAR

DOWN: 	cmp cl, DIR_DOWN
		jne LEFT
		call MOV_CAR_NS
		jmp END_MV_CAR

LEFT:   cmp cl, DIR_LEFT
		jne RIGHT
		call MOV_CAR_LO
		jmp END_MV_CAR

RIGHT: 	cmp cl, DIR_RIGHT
		jne END_MV_CAR
		call MOV_CAR_OL

END_MV_CAR:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; NS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOV_CAR_NS proc
		push ax
		push bx
		push cx
		push dx

		cmp dh, 24
		jne MV_NS
		call ERASE_POS
		jmp END_NS

MV_NS:	cmp dh, 8
		jne CHK_MV_NS

		call CHK_LIGHT_SN
		jnc UPD_NS
		jmp STOP_NS

CHK_MV_NS:
		call CHECK_SHOULD_MOV_NS
		jnc UPD_NS

STOP_NS:call STOP_CAR
		jmp END_NS

UPD_NS:	call ERASE_POS
		; Seta bit updated = true
		or al, 80H 			
		
		; Verifica e faz a conversão à direita
		call CHK_RIGHT_CONV_NS 
		jc END_NS

		; Verifica e faz a conversão à esquerda
		call CHK_LEFT_CONV_NS 
		jc END_NS

		add dh, 2
		call WRITE_MATRIX_ELEMENT

END_NS:	pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CHK_LEFT_CONV_NS proc
		push ax
		push bx

		cmp dl, 27
		jne NEXT_POS1_NS
		cmp dh, 8
		jne NEXT_POS1_NS

		add dh, 3
		inc dl
		jmp LEFT_CONV_NS

NEXT_POS1_NS:
		cmp dl, 28
		jne CLC_L_NS
		cmp dh, 11
		jne CLC_L_NS

		add dh, 2
		add dl, 2
		and al, 0FBH 		; Seta a direção 10 = →

LEFT_CONV_NS:
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_LEFT_NS

CLC_L_NS:
		clc

END_LEFT_NS:
		pop bx
		pop ax
		ret
ENDP

CHK_RIGHT_CONV_NS proc
		push ax
		push dx
		
		cmp dh, 10
		jne CLR_NS
		cmp dl, 23
		jne CLR_NS

		sub dl, 3 			; Incrementa para a próxima posição
		and al, 0F7H		; Seta direção = ← | 01XX
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_CONV_DIR_NS

CLR_NS:	clc

END_CONV_DIR_NS:
		pop dx
		pop ax
		ret
ENDP

CHECK_SHOULD_MOV_NS proc
		push ax
		push dx

		add dh , 2
		call GET_MATRIX_ELEMENT
		call TEST_PRESENCE

		pop dx
		pop ax
		ret
ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOV_CAR_SN proc
		push ax
		push bx
		push cx
		push dx

		cmp dh, 0
		jne MV_SN
		call ERASE_POS
		jmp END_SN

MV_SN:	cmp dh, 16
		jne CHK_MV_SN

		call CHK_LIGHT_SN
		jnc UPD_SN
		jmp STOP_SN

CHK_MV_SN:
		call CHECK_SHOULD_MOV_SN
		jnc UPD_SN

STOP_SN:call STOP_CAR
		jmp END_SN

UPD_SN:	call ERASE_POS
		or al, 80H 		; Seta bit updated = true
		
		; Verifica e faz a conversão à direita
		call CHK_RIGHT_CONV_SN 
		jc END_SN

		call CHK_LEFT_CONV_SN 
		jc END_SN

		sub dh, 2
		call WRITE_MATRIX_ELEMENT
		
END_SN:	pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CHK_LEFT_CONV_SN proc
		push ax
		push bx

		cmp dl, 27
		jne NEXT_POS1_SN
		cmp dh, 16
		jne NEXT_POS1_SN

		sub dh, 3
		dec dl
		jmp LEFT_CONV_SN

NEXT_POS1_SN:
		cmp dl, 26
		jne CLC_L_SN
		cmp dh, 13
		jne CLC_L_SN

		sub dh, 2
		dec dl
		or al, 4 			; Seta a direção 01 = ←

LEFT_CONV_SN:
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_LEFT_SN

CLC_L_SN:
		clc

END_LEFT_SN:
		pop bx
		pop ax
		ret
ENDP

CHK_RIGHT_CONV_SN proc
		push ax
		push dx
		
		cmp dh, 14
		jne CLC_SN
		cmp dl, 31
		jne CLC_SN

		add dl, 4 			; Incrementa para a próxima posição
		or al, 8 			; Seta direção = → | 10XX
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_CONV_DIR_SN

CLC_SN:	clc

END_CONV_DIR_SN:
		pop dx
		pop ax
		ret
ENDP

CHK_LIGHT_SN proc 			; Verifica se o sinal Sul-Norte está aberto para o carro na posição [DH] [DL]
		push ax
		push bx
		push cx
		push dx

		call GET_NS

		cmp dl, 27			; Verifica se o carro está na pista de conversão
		jnz CMP_STS			; Se não estiver pula para a próxima verificação
		cmp al, CONV_STS 	; Verifica o status do sinal
		je END_LIGHT_SN 	; Sinal aberto
		jmp CLOSE_SN		; Sinal fechado

CMP_STS:cmp al, GREEN_STS 	
		je END_LIGHT_SN 	; Sinal aberto

CLOSE_SN:
		stc 				; Seta carry quando o sinal está fechado
		
END_LIGHT_SN:	
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CHECK_SHOULD_MOV_SN proc
		push ax
		push bx
		push cx
		push dx

		sub dh, 2
		call GET_MATRIX_ELEMENT
		call TEST_PRESENCE

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOV_CAR_OL proc
		push ax
		push bx
		push cx
		push dx

		; Verifica se é a ultima posição endereçavel. Caso seja, somente é removido o carro
		cmp dl, 55 			
		jnz MV_OL 			
		call ERASE_POS 		
		jmp END_OL

		; verifica se está na posição da sinaleira
MV_OL:	cmp dl, 20 			
		jne CHK_MV_OL 		

		; Verifica o status do semáforo, se der carry o sinal está fechado
		call CHK_LIGHT_OL  	
		jnc UPD_OL 			
		jmp STOP_OL 		

		; Verifica se o carro deve ser movido
CHK_MV_OL:
		; Verifica se deve fazer conversão a esquerda
		call CHK_LEFT_CONV_OL
		jc END_OL

		call CHECK_SHOULD_MOV_OL
		jnc UPD_OL
		
		; Faz com que o carro pare
STOP_OL:call STOP_CAR 		
		jmp END_OL

		; Apaga a posição antiga do carro
UPD_OL:	call ERASE_POS 		
		or al, 80H 			; Seta bit updated = true
		
		; Verifica se deve fazer conversão a direita
		call CHK_RIGHT_CONV_OL
		jc END_OL


		; Incrementa a posição do carro e escreve na matrix
		add dl, 5
		call WRITE_MATRIX_ELEMENT

END_OL:	pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP	

CHK_LEFT_CONV_OL proc
		push ax
		push dx

		; Verifica se o carro está na pista de conversão à esquerda.
		cmp dh, 12 			
		jne NEXT_POS1_OL
		
		; Verifica a posição atual do carro incrementa para a próxima.
		cmp dl, 25 			
		jne NEXT_POS1_OL

		call ERASE_POS
		sub dh, 2
		add dl, 3
		jmp LEFT_CONV_OL

		; Verifica a posição atual do carro e incrementa para a próxima.
NEXT_POS1_OL:
		cmp dh, 10
		jne CLC_L_OL
		cmp dl, 28
		jne CLC_L_OL

		call ERASE_POS
		sub dh, 2
		inc dl
		and al, 0F3H 		; Seta direção XXXX 00XX = ↑ 

		; Escreve na matrix o carro atualizado e seta o carry informando que a conversão está/foi feita.
LEFT_CONV_OL:
		or al, 80H
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_LEFT_OL

		; Limpa o carry informando que a conversão nao está/foi feita.
CLC_L_OL:
		clc

END_LEFT_OL:
		pop dx
		pop ax
		ret
ENDP

CHK_RIGHT_CONV_OL proc
		push ax
		push dx
		
		; Verifica se esta na pista de conversão à direita
		cmp dh, 14 			
		jne CLC_OL
		
		; Verifica a posição atual do carro e incrementa para a próxima
		cmp dl, 20 			
		jne CHK_TURN_OL
		add dl, 3

		call WRITE_MATRIX_ELEMENT
		jmp STC_OL

CHK_TURN_OL:
		cmp dl, 23
		jne CLC_OL

		or al, 0CH 			; Seta direção = ↓ | XXXX 11XX
		add dh, 2
		call WRITE_MATRIX_ELEMENT
STC_OL:	stc
		jmp END_CONV_DIR_OL

CLC_OL: clc

END_CONV_DIR_OL:
		pop dx
		pop ax
		ret
ENDP

CHK_LIGHT_OL proc
		push ax
		push bx
		push cx
		push dx

		call GET_LO

		cmp dh, 12			; Verifica se o carro está na pista de conversão
		jnz CMP_STS_OL		; Se não estiver pula para a próxima verificação
		cmp al, CONV_STS 	; Verifica o status do sinal
		je END_LIGHT_OL 	; Sinal aberto
		jmp CLOSE_OL		; Sinal fechado

CMP_STS_OL:
		cmp al, GREEN_STS 	
		je END_LIGHT_OL 	; Sinal aberto

CLOSE_OL:
		stc 				; Seta carry quando o sinal está fechado
		
END_LIGHT_OL:	
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CHECK_SHOULD_MOV_OL proc
		push ax
		push dx

		add dl, 5
		call GET_MATRIX_ELEMENT
		call TEST_PRESENCE

		pop dx
		pop ax
		ret
ENDP	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOV_CAR_LO proc
		push ax
		push bx
		push cx
		push dx

		; Verifica se o carro está na ultima posição endereçavel, caso esteja somente é removido
		cmp dl, 0
		jne MV_LO
		call ERASE_POS
		jmp END_LO

		; Verifica se o carro está na posição do semáforo
MV_LO:	cmp dl, 35
		jne CHK_MV_LO

		; Verifica se o semáforo está aberto, caso nao esteja o carry é setado
		call CHK_LIGHT_OL 	
		jnc UPD_LO
		jmp STOP_LO
		
CHK_MV_LO:
		; Verifica se deve fazer conversão a esquerda
		call CHK_LEFT_CONV_LO
		jc END_LO

		; Verifica se o carro deve se mover
		call CHECK_SHOULD_MOV_LO
		jnc UPD_LO
		
		; Para o carro
STOP_LO:call STOP_CAR
		jmp END_LO		

		; Apaga a posição antiga do carro
UPD_LO:	call ERASE_POS
		or al, 80H 			; Seta bit updated = true

		; Verifica se deve fazer conversão a direita
		call CHK_RIGHT_CONV_LO
		jc END_LO

		; Incrementa a posição do carro e escreve na matrix
		sub dl, 5
		call WRITE_MATRIX_ELEMENT

END_LO:	pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CHK_LEFT_CONV_LO proc
		push ax
		push cx
		push dx

		; Verifica se o carro está na pista de conversão à esquerda.
		cmp dh, 12 			
		jne NEXT_POS1_LO
		
		; Verifica a posição atual do carro incrementa para a próxima.
		cmp dl, 30 			
		jne NEXT_POS1_LO

		call ERASE_POS
		add dh, 2
		sub dl, 4
		jmp LEFT_CONV_LO

		; Verifica a posição atual do carro e incrementa para a próxima.
NEXT_POS1_LO:
		cmp dh, 14
		jne CLC_L_LO
		cmp dl, 26
		jne CLC_L_LO

		call ERASE_POS
		add dh, 2
		dec dl
		; Seta direção XXXX 11XX = ↓
		or al, 0CH

		; Escreve na matrix o carro atualizado e seta o carry informando que a conversão está/foi feita.
LEFT_CONV_LO:
		or al, 80H
		call WRITE_MATRIX_ELEMENT
		stc
		jmp END_LEFT_LO

		; Limpa o carry informando que a conversão nao está/foi feita.
CLC_L_LO:
		clc

END_LEFT_LO:
		pop dx
		pop cx
		pop ax
		ret
ENDP

		; Verifica e faz a conversão a direita dos carros Leste-Oeste
CHK_RIGHT_CONV_LO proc 		
		push ax
		push dx
		
		; Verifica se esta na pista de conversão à direita
		cmp dh, 10 			
		jne CLC_LO
		
		; Verifica a posição atual do carro e incrementa para a próxima
		cmp dl, 35 			
		jne CHK_TURN_LO
		sub dl, 4

		call WRITE_MATRIX_ELEMENT
		jmp STC_LO

CHK_TURN_LO:
		cmp dl, 31
		jne CLC_LO

		; Seta direção = ↑ |XXXX 00XX
		and al, 0F3H 			
		sub dh, 2
		call WRITE_MATRIX_ELEMENT
STC_LO:	stc
		jmp END_CONV_DIR_LO

CLC_LO: clc

END_CONV_DIR_LO:
		pop dx
		pop ax
		ret
ENDP

CHECK_SHOULD_MOV_LO proc
		push ax
		push dx

		sub dl, 5
		call GET_MATRIX_ELEMENT
		call TEST_PRESENCE

		pop dx
		pop ax
		ret
ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STOP_CAR proc
		push ax

		or al, 80H 			; Seta bit updated = true
		and al, 0FDH 		; Set bit moving = false
		call WRITE_MATRIX_ELEMENT

		pop ax
		ret
ENDP

ERASE_POS proc
		push ax

		xor ax, ax
		call WRITE_MATRIX_ELEMENT

		pop ax
		ret
ENDP

RESET_STATUS proc 				; Reseta o bit 'Updated'
		push ax
		push bx
		push cx
		push dx

		mov cx, 1400 			; Tamanho da matriz 55 x 25
		mov bx, offset CARS_MATRIX

RSTCAR:	mov al, [bx] 			; Pega o byte da matriz em AL | RSTCAR = RESET CAR		
		and al, 7FH 			; Seta o bit 'Updated' para 0
		mov [bx], al 			; Grava o byte alterado na matriz
		inc bx 					; Incrementa a posição da matriz
		loop RSTCAR
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

TEST_PRESENCE proc 			; Verifica se byte em AX possui o bit 'presença' ligado
		push ax
		shr al, 1 			; Se carry é 1, o bit de presence está ligado
		pop ax
		ret
ENDP

TEST_MOV proc 				; Verifica se posição da matriz dada em BX possui bit 'movimento' ligado
		push ax
		shr al, 2 			; Resultado fica no carry flag
		pop ax
		ret
ENDP

TEST_UPDATED proc			; Verifica se posição da matriz dada em BX possui bit 'atualizado' ligado
		push ax
		shl al, 1 			; Resultado fica no carry flag
		pop ax
		ret
ENDP

GET_DIR proc 				; Retorna a direção correspondente do byte da matriz, em cl
		push ax
		
		xor cx, cx 			; Zera CX
		mov cx, ax 			; Envia byte para CX
		shr cl, 2 			; Desloca 2 bits
		and cl, 3 			; Zera 2 bits de cor, não necessários na proc
		
		pop ax
		ret 				; Direção em AL
ENDP

GET_COLOR proc 				; Retorna a cor correspondente do byte da matriz, em BL
		push ax

		mov bl , al
		shr bl, 4			; Desloca 4 bits

		pop ax
		ret 				; Cor em AL
ENDP

GET_ROW_NS proc            			; Retorna os bits de presença de toda a fileira da posição [dh][dl] incrementando o dh
		push ax
		push bx
		push cx
		push dx
		push si
		
		mov bx, offset CARS_MATRIX  ; Prepara a primeira posição da matriz
		mov si, offset ROW_STATE   	; Pega variável para incrementar o status

G_B_NS: call GET_MATRIX_ELEMENT     ; Pega byte da matriz
		call TEST_PRESENCE          ; Testa presença no byte
		jc W_1_NS                   ; Se estiver 1, deverá escrever no status

W_0_NS: mov al, '0'
		jmp REC_NS

W_1_NS: mov al, '1'

REC_NS: mov byte ptr[si], al        ; Coloca char na posição da variavel
		inc si                      ; Incrementa index
		add dh, 2                   ; Incrementa posição na matriz

		cmp dh, 10                  ; Se chegar no fim da rua
		jnz G_B_NS

		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

GET_ROW_SN proc            ; Retorna os bits de presença de toda a fileira de Sul-Norte, começando em [dh][dl]
		push ax
		push bx
		push cx
		push dx
		push si
		
		mov bx, offset CARS_MATRIX  ; Prepara a primeira posição da matriz
		mov si, offset ROW_STATE   ; Pega variável para incrementar o status

G_B_SN: call GET_MATRIX_ELEMENT     ; Pega byte da matriz
		call TEST_PRESENCE          ; Testa presença no byte
		jc W_1_SN                 ; Se estiver 1, deverá escrever no status

W_0_SN: mov al, '0'
		jmp REC_SN

W_1_SN: mov al, '1'

REC_SN: mov byte ptr[si], al        ; Coloca char na posição da variavel
		inc si                      ; Incrementa index
		sub dh, 2                   ; Decrementa posição na matriz

		cmp dh, 14                  ; Se chegar no fim da rua
		jnz G_B_SN

		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

GET_ROW_LO proc                     ; Retorna os bits de presença de toda a fileira de Leste-Oeste, começando em [dh][dl]
		push ax
		push bx
		push cx
		push dx
		
		mov bx, offset CARS_MATRIX  ; Prepara a primeira posição da matriz
		mov si, offset ROW_STATE   ; Pega variável para incrementar o status

G_B_LO: call GET_MATRIX_ELEMENT     ; Pega byte da matriz
		call TEST_PRESENCE          ; Testa presença no byte
		jc W_1_LO                  ; Se estiver 1, deverá escrever no status

W_0_LO: mov al, '0'
		jmp REC_LO

W_1_LO:mov al, '1'

REC_LO: mov byte ptr[si], al        ; Coloca char na posição da variavel
		inc si                      ; Incrementa index
		sub dl, 5

		cmp dl, 30                  ; Se chegar no fim da rua
		jnz G_B_LO

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

GET_ROW_OL proc                     ; Retorna os bits de presença de toda a fileira de Oeste-Leste, começando em [dh][dl]
		push ax
		push bx
		push cx
		push dx
		
		mov bx, offset CARS_MATRIX  ; Prepara a primeira posição da matriz
		mov si, offset ROW_STATE   	; Pega variável para incrementar o status

G_B_OL: call GET_MATRIX_ELEMENT     ; Pega byte da matriz
		call TEST_PRESENCE          ; Testa presença no byte
		jc W_1_OL                  	; Se estiver 1, deverá escrever no status

W_0_OL: mov al, '0'
		jmp REC_OL

W_1_OL:mov al, '1'

REC_OL: mov byte ptr[si], al        ; Coloca char na posição da variavel
		inc si                      ; Incrementa index
		add dl, 5

		cmp dl, 25                  ; Se chegar no fim da rua
		jnz G_B_OL

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP