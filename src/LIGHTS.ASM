.data

;;;;;;;;;;;;;;;;;;;;;;;;;
; Status dos semáforos: ;
;;;;;;;;;;;;;;;;;;;;;;;;;
SEM_NS dw 0
SEM_LO dw 0

GREEN_STS db 22H
CONV_STS db 11H
YELLOW_STS db 44H
RED_STS db 88H

;;;;;;;;;;
; Cores: ;
;;;;;;;;;;
C_WHITE EQU 7H
C_GREEN EQU 2H
C_RED EQU 4H
C_YELLOW EQU 0EH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posições das sinaleiras na matriz: ;
; Dividido entre DH e DL             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Norte
N_GREEN EQU 0811h
N_CONVER EQU 0812h
N_YELLOW EQU 0810h
N_RED EQU 080fh

; Oeste
O_GREEN EQU 1011h
O_CONVER EQU 1012h
O_YELLOW EQU 1010h
O_RED EQU 100fh

; Leste
L_GREEN EQU 0829h
L_CONVER EQU 082Ah
L_YELLOW EQU 0828h
L_RED EQU 0827h

; Sul
S_GREEN EQU 1029h
S_CONVER EQU 102Ah
S_YELLOW EQU 1028h
S_RED EQU 1027h

.code

CLEAN_NORTH proc 			; Limpa as cores do semáforo norte
		push bx

		mov bl, C_WHITE

		mov dx, N_GREEN
		call DRW_SEM
		mov dx, N_CONVER
		call DRW_SEM
		mov dx, N_RED
		call DRW_SEM
		mov dx, N_YELLOW
		call DRW_SEM

		pop bx
		ret
ENDP

CLEAN_SOUTH proc 			; Limpa as cores do semáforo sul
		push bx

		mov bl, C_WHITE

		mov dx, S_GREEN
		call DRW_SEM
		mov dx, S_CONVER
		call DRW_SEM
		mov dx, S_RED
		call DRW_SEM
		mov dx, S_YELLOW
		call DRW_SEM

		pop bx
		ret
ENDP

CLEAN_WEST proc 			; Limpa as cores do semáforo Oeste
		push bx

		mov bl, C_WHITE

		mov dx, O_GREEN
		call DRW_SEM
		mov dx, O_CONVER
		call DRW_SEM
		mov dx, O_RED
		call DRW_SEM
		mov dx, O_YELLOW
		call DRW_SEM

		pop bx
		ret
ENDP

CLEAN_EAST proc 			; Limpa as cores do semáforo leste
		push bx

		mov bl, C_WHITE

		mov dx, L_GREEN
		call DRW_SEM
		mov dx, L_CONVER
		call DRW_SEM
		mov dx, L_RED
		call DRW_SEM
		mov dx, L_YELLOW
		call DRW_SEM

		pop bx
		ret
ENDP

CLEAN_ALL proc 				; Limpa todas as cores dos semáforos
		call CLEAN_NORTH
		call CLEAN_SOUTH
		call CLEAN_EAST
		call CLEAN_WEST
		ret
ENDP

DRW_SEM proc 				; Pinta o semáforo dado pela posição em DX, e cor em BL
		push ax

		mov al, SQR_CHAR
		call SET_CUR_POS
		call WRITE_CHAR_C

		pop ax
		ret
ENDP


SET_VERDE proc 				; Pega semaforo com offset em bx e seta para estado verde
		mov byte ptr[bx], 22h ; 0010 0010 
		ret
ENDP

SET_VERMELHO proc 			; Pega semaforo com offset em bx e seta para estado vermelho
		mov byte ptr[bx], 88h ; 1000 1000 
		ret
ENDP

SET_AMARELO proc 			; Pega semaforo com offset em bx e seta para estado amarelo 
		mov byte ptr[bx], 44h ; 0100 0100 
		ret
ENDP

SET_CONVERSAO proc 			; Pega semaforo com offset em bx e seta para estado conversão a esquerda
		mov byte ptr[bx], 11h ; 0001 0001 
		ret
ENDP

INIT_LIGHTS proc 			; Primeira inicialização dos semáforos
		push bx

		mov bx, offset SEM_NS
		call SET_VERMELHO
		mov bx, offset SEM_LO
		call SET_VERDE

		pop bx
		ret
ENDP

DRW_LIGHTS proc 			; Desenha os semáforos de acordo com o status na memória
		push bx

		call CLEAN_ALL 		; Limpa todos estados

		mov bx, offset SEM_NS ; Pega Norte-Sul
TEST1:	cmp byte ptr[bx], 22h ; Se estiver aberto 
		jnz TEST2
		mov dx, S_GREEN 	; Sul -> Aberto
		mov bl, C_GREEN
		call DRW_SEM
		mov dx, N_GREEN		; Norte -> Aberto
		call DRW_SEM
		jmp NEXTT
TEST2:	cmp byte ptr[bx], 88h ; Se estiver fechado 
		jnz TEST3
		mov dx, S_RED 		; Sul -> fechado
		mov bl, C_RED
		call DRW_SEM
		mov dx, N_RED 		; Norte -> fechado
		call DRW_SEM
		jmp NEXTT
TEST3: 	cmp byte ptr[bx], 44h ; Se for amarelo 
		jnz TEST4
		mov dx, S_YELLOW 	; Sul -> amarelo
		mov bl, C_YELLOW
		call DRW_SEM
		mov dx, N_YELLOW 	; Norte -> amarelo
		call DRW_SEM
		jmp NEXTT
TEST4: 	mov dx, S_CONVER 	; Sul -> conversão
		mov bl, C_GREEN 
		call DRW_SEM
		mov dx, N_CONVER 	; Norte -> conversão
		call DRW_SEM

NEXTT:	mov bx, offset SEM_LO ; Pega Leste - Oeste

TEST5:	cmp byte ptr[bx], 22h ; Se estiver aberto 
		jnz TEST6
		mov dx, L_GREEN 	; Leste -> Aberto
		mov bl, C_GREEN
		call DRW_SEM
		mov dx, O_GREEN 	; Oeste -> Aberto
		call DRW_SEM
		jmp END_DRW
TEST6:	cmp byte ptr[bx], 88h ; Se estiver fechado 
		jnz TEST7
		mov dx, L_RED 		; Leste -> fechado
		mov bl, C_RED
		call DRW_SEM
		mov dx, O_RED 		; Oeste -> fechado
		call DRW_SEM
		jmp END_DRW
TEST7: 	cmp byte ptr[bx], 44h ; Se for amarelo 
		jnz TEST8
		mov dx, L_YELLOW 	; Leste -> amarelo
		mov bl, C_YELLOW
		call DRW_SEM
		mov dx, O_YELLOW 	; Oeste -> amarelo
		call DRW_SEM
		jmp END_DRW
TEST8: 	mov dx, L_CONVER 	; Leste -> conversão
		mov bl, C_GREEN 
		call DRW_SEM
		mov dx, O_CONVER 	; Oeste -> conversão
		call DRW_SEM

END_DRW:pop bx
		ret
ENDP

UPDT_LIGHTS proc 			; Atualiza status na memória, de acordo com a lógica dos sinais
		push cx
		push ax

		call INC_CRONOS
		call GET_CRONOS

		call GET_NS

		cmp al, GREEN_STS 	; Se for verde
		jz U_GREEN

		cmp al, CONV_STS 	; Se for conversão
		jz U_CONV

		cmp al, YELLOW_STS 	; Se for amarelo
		jz U_YELL

		cmp al, RED_STS 	; Se for vermelho
		jz U_RED

U_GREEN:cmp cl, 5 			; 5 segundos
		jnz NO_CHNG

		mov bx, offset SEM_NS ; Troca para conversão
		call SET_CONVERSAO

		call RESET_CRONOS 	; Zera tempo
		jmp NO_CHNG 		; Jmp fim

U_CONV:	cmp cl, 3 			
		jnz NO_CHNG

		mov bx, offset SEM_NS
		call SET_AMARELO

		call RESET_CRONOS
		jmp NO_CHNG

U_YELL: cmp cl, 2 			; Se estiver já um segundo ligado, vai para vermelho 
		jnz NO_CHNG

		mov bx, offset SEM_NS ; Seta Norte-Sul como vermelho
		call SET_VERMELHO
		mov bx, offset SEM_LO ; e Leste-Oeste como verde.
		call SET_VERDE

		call RESET_CRONOS 	; Zera tempo
		jmp NO_CHNG 		; Jmp fim

U_RED:  cmp cl, 5
		jnz CHNG_C

		mov bx, offset SEM_LO
		call SET_CONVERSAO	

CHNG_C: cmp cl, 8
		jnz CHNG_Y

		mov bx, offset SEM_LO
		call SET_AMARELO

CHNG_Y:	cmp cl, 10
		jnz NO_CHNG
		mov bx, offset SEM_NS ; Seta Norte-Sul como verde
		call SET_VERDE
		mov bx, offset SEM_LO ; e Leste-Oeste como vermelho.
		call SET_VERMELHO

		call RESET_CRONOS 	; Zera tempo

NO_CHNG:pop cx 				; Nada precisa ser alterado
		pop ax
		ret
ENDP

GET_NS proc 				; Retorna status da sinaleira Norte-Sul em AL
		push bx

		xor ax, ax
		mov bx, offset SEM_NS
		mov ax, [bx]

		pop bx
		ret
ENDP

GET_LO proc 				; Retorna status da sinaleira Leste-Oeste em AL
		push bx

		xor ax, ax
		mov bx, offset SEM_LO
		mov ax, [bx]

		pop bx
		ret
ENDP

DRW_LIGHTS_STATUS proc		; Coloca as informações das sinaleiras no status da direita
		push bx
		push cx
		push dx

		mov cx, 4 			; 4 caracteres em cada semáforo para serem escritos
		mov dl, 69 			; Coluna onde deve ser escrito

		mov bx, offset SEM_NS
		mov ah, [bx]

		mov dh, 8			; Posição da status Norte-Sul
		call WRT_BIN_TO_SCRN
		mov dh, 11			; Posição da status Sul-Norte
		call WRT_BIN_TO_SCRN

		mov bx, offset SEM_LO
		mov ah, [bx]

		mov dh, 14			; Posição da status Oeste-Leste
		call WRT_BIN_TO_SCRN
		mov dh, 17			; Posição da status Leste-Oeste
		call WRT_BIN_TO_SCRN

		pop dx
		pop cx
		pop bx
		ret
ENDP