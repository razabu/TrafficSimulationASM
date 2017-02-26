.data

LF EQU 0AH					; Line Feed
CR EQU 0DH					; Carriage Return
CUR_INT_SIZE EQU 4			; Tamanho da variável CUR_INT
CUR_INT DB '0000$'
STR_BUFFER DB ?

SQR_CHAR EQU 0FEH

CRONOS dw 0000h 			; Variável de cronômetro

.code

INIT_PROGRAM proc
		mov ax, @DATA
		mov ds, ax
		mov es, ax
		ret
ENDP

END_PROGRAM proc
  		call CLOSE_LOG   	; Fecha o arquivo de log de eventos
  		call SET_RES        ; Limpa a tela
  		mov AH, 4CH
  		int 21H
  		ret
ENDP

CHK_ESC_KEY proc            ; Verifica se a tecla ESC está pressionada, se está finaliza o programa
  		push ax

  		mov ah, 01h         ; Serviço para verificar tecla pressionada
  		int 16h             ; Interrupção 16h
  		jz N_KEY            ; Se nenhuma tecla foi pressionada

  		cmp al, 27          ; Compara com char da tecla ESC
  		jnz N_KEY
  		call END_PROGRAM

N_KEY: 	pop ax
  		ret
ENDP

PAUSE proc 					; Espera por input do teclado
    	push ax
    	
    	mov  ah, 08h
    	int  21h
    	
    	pop  ax
    	ret 
ENDP

NEWLINE proc 				; Faz uma nova linha
		push ax
		push dx

		mov ah, 2

		mov dl, LF 			
		int 21h

		mov dl, CR 			
		int 21h

		pop dx
		pop ax
		ret
ENDP

WRITE_STR proc 				; Escreve a string em DX na posição do cursor
		push ax
		
		mov ah, 9
		mov al, 0
		int 21H

		pop ax
		ret
		endp

WRITE_CHAR proc 			; Escreve o char em AL na posição do cursor
		push ax
		push bx
		push cx
		push dx

		mov bh, 0
		mov bl, 0
		mov cx, 1
		mov ah, 0AH

		int 10H

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

WRITE_CHAR_C proc           ; Escreve char em AL na posição do cursor, com a cor em BL
  		push cx
 		push bx

  		mov bh, 0
		mov cx, 1
  		mov ah, 09H

  		int 10H

  		pop bx
  		pop cx
  		ret
ENDP

GET_CHAR proc 			; Retorna em AL o char que está na posição do cursor
		push bx
		push cx
		push dx

		mov bh, 0
		mov ah, 08H

		int 10H

		pop dx
		pop cx
		pop bx
		ret
ENDP

SET_CUR_POS proc 			; Seta o cursor na linha DH e na coluna DL
		push ax
		push bx

		xor bh, bh
		mov ah, 2
		int 10h

		pop bx
		pop ax
		ret
ENDP

SET_RES proc 				; Seta resolução 80X25 em modo texto
		push ax

		mov al, 3h
		mov ah, 0
		int 10h

		pop ax
		ret
ENDP

HIDE_CURSOR proc 			; Esconde o cursor
		push ax
		push cx

		mov ch, 20H
		mov ah, 1
		int 10H

		pop cx
		pop ax
		ret
ENDP

GET_SYS_TIME proc			; Pega os segundos do sistema em DH e os Minutos em CL 
		push ax

		mov ah, 02h
		int 1Ah
	
		pop ax
		ret
ENDP

GET_CRONOS proc 			; Retorna CRONOS em cl
		push bx

		mov bx, offset CRONOS
		mov cx, [bx]

		pop bx
		ret
ENDP

INC_CRONOS proc 			; Incrementa CRONOS
		push bx

		mov bx, offset CRONOS
		inc byte ptr[bx]

		pop bx
		ret
ENDP

RESET_CRONOS proc 			; Reseta CRONOS
		push bx

		mov bx, offset CRONOS
		mov byte ptr[bx], 0000h

		pop bx
		ret
ENDP

GET_RAND_UINT proc 			; Recebe limitador em CX e Retorna em DX
		push ax
		push bx

		xor ax, ax
		xor dx, dx

		mov bx, cx
		mov al, byte ptr SECONDS
		cmp al,0
		jne RAND
		inc al

RAND:	div bx       		; Divides AX by BX. DX = REMAINDER and AX = QUOCIENT

		pop bx
		pop ax
		ret
ENDP

WRT_BIN_TO_SCRN proc 		; Escreve CX bits do número em AH em representação binária, a partir da posição [DH][DL]
		push ax
		push cx
		push dx

		call SET_CUR_POS

PRT_0:	dec cx                
		shl ah, 1           ; Faz shift left, se o carry flag for 1, ele printa o char '1', e vice-versa.
		jc PRT_1
		mov al, 48d
		call WRITE_CHAR
		inc dl
		call SET_CUR_POS
		cmp cx, 0
		jz OUT_I
		jmp PRT_0

PRT_1:	mov al, 49d
		call WRITE_CHAR
		inc dl
		call SET_CUR_POS
		cmp cx, 0
		jz OUT_I

		jmp PRT_0

OUT_I:  pop dx
		pop cx
		pop ax
		ret
ENDP

GET_MATRIX_ELEMENT proc 	; Pega elemento da matriz dada em BX na posição [DH][DL] em AL
		push cx
		push bx
		push si

		mov ax, CM_LINE_SIZE; Tamanho da linha da matrix em Ax
		mul dh 				; Multiplica o tamanho da linha pelo numero da linha para corrigir o indice e armazena em AX
		add bx, ax 			; Desloca para a linha correta. AX contem o deslocamento

		xor ah, ah 			;
		mov al, dl 			; Move DL para SI, por AL ser 8 bits é necessário antes envia-lo para AX para que AX possa ser enviado a SI
		mov si, ax 			;

		mov al, byte ptr[bx][si] ;mov byte ptr [bx][si]

		pop si
		pop bx
		pop cx
		ret
ENDP

WRITE_MATRIX_ELEMENT proc 	; Escreve byte em AL na posiçao [DH][DL] da matriz em BX
		push cx
		push bx
		push si
		push ax

		mov ax, CM_LINE_SIZE; Tamanho da linha da matrix em Ax
		mul dh 				; Multiplica o tamanho da linha pelo numero da linha para corrigir o indice e armazena em AX
		add bx, ax 			; Desloca para a linha correta. AX contem o deslocamento

		xor ah, ah 			;
		mov al, dl 			; Faz com que DX tenha somente DL. Zera o DH. DX = Coluna
		mov si, ax 			;
		
		pop ax		
		mov byte ptr[bx][si], al ; Move byte em cl para a matriz

		pop si
		pop bx
		pop cx
		ret
ENDP

PARSE_TO_INT PROC   		; Converte para inteiro o número em AX
        push bx
        push cx
        push dx
        
        call RESET_CUR_INT 	; Zera a variavel CUR_INT

        xor cx, cx 			; Contador de caracteres	
        mov bx, 10 			; Divisor
DIVIDE: xor dx, dx
    
	    div bx				; Separa dígito menos significativo de AX em DX
        add dl,'0'			; Converte o dígito separado para caractere
        push dx				; Empilha caractere contido em DX
        inc cx				; Incrementa o contador de caracteres
        or ax, ax   		; Verifica se acabaram os dígitos de AX (cmp AX, 0H)
        jnz DIVIDE 			; Caso não, continua divindo

        mov bx, CUR_INT_SIZE; Quantidade de dígitos na string CUR_INT
        sub bx, cx 			; Diferente entre dígitos na string e dígitos do número convertido
        mov di, offset CUR_INT
        add di, bx 			; Desloca o ponteiro com a diferença de dígitos para que seja escrito 0030 ao invéz de 3000 por exemplo
SAVE:	pop dx				; Desempilha os dígitos em DX
		mov [di], dx 		; Mandao dígito em DX pra CUR_INT
		inc di 				; Desloca o ponteiro para escrever o próximo dígito
        loop SAVE 			; Loop para armazenar todos os dígitos

        mov byte ptr [di], 24H ; Adiciona '$' no fim da string
        
        pop dx
        pop cx
        pop bx
        ret
ENDP

RESET_CUR_INT proc
		push ax
		push bx
		push cx
		push si

		xor si, si
		mov bx, offset CUR_INT

		mov cx, CUR_INT_SIZE

RST_INT:mov bx[si], '0'
		inc si
		loop RST_INT

		pop si
		pop cx
		pop bx
		pop ax
		ret
ENDP