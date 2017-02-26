.data

LAST_PPA_ENTRY dw 0

LAST_PPA_A db 0
LAST_PPA_B db 0
LAST_PPA_C db 0

.code

INIT_PPA proc
		push ax
		push dx

		mov dx, 303H
		mov al, 89H 		; 1000 1001
		out dx, al

		pop dx
		pop ax
		ret
ENDP

PPA_IN proc
		int 6FH
		ret
ENDP

PPA_INT proc
		pushf
		sti
		push ax
		push bx
		push cx
		push dx

		mov dx, 300H		; Out Porta A
		mov ax, SEM_NS		; Semaforo NS 
		out dx, al

		mov si, offset LAST_PPA_A
  		mov byte ptr [si], al

		mov dx, 301H 		; Out Porta B
		mov ax, SEM_LO		; Semaforo LO
		out dx, al

		mov si, offset LAST_PPA_B
  		mov byte ptr [si], al

		mov dx, 302H 		; In Porta C
		in al, dx

		xor ax, ax
		and al, 3FH 		; Zera os dois bits mais significativos, que não sao usados

		xor bx, bx
		mov bl, al
		shr bl, 4
		cmp bl, 0
		je END_PPA_INT

		mov si, offset SECONDS
		mov di, offset LAST_PPA_ENTRY
		mov bx, [si]
		mov [di], bx

		mov si, offset LAST_PPA_C
  		mov byte ptr [si], al
		call SPAWN_CARS

END_PPA_INT:
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		iret
ENDP

DRW_PPA_STATUS proc
		push ax
		push bx
		push cx
		push dx
		push si

		; Atualiza os status das Portas A, B e C
		mov cx, 8 			; Quantidade de caracteres a ser escrita no status das portas por WRT_BIN_TO_SCRN
		mov dl, 69			; Coluna onde devem ser escritos os status

		mov si, offset LAST_PPA_A
		mov ah, byte ptr[si]; Armazena em ah a ultima saida da porta A
		mov dh, 3 			; Posição do status "Porta A"
		call WRT_BIN_TO_SCRN; Escreve o status da Porta A

		mov si, offset LAST_PPA_B
		mov ah, byte ptr[si]; Armazena em ah a ultima saida da porta B
		mov dh, 4 			; Posição do status "Porta B"
		call WRT_BIN_TO_SCRN; Escreve o status da Porta B

		mov si, offset LAST_PPA_C
		mov bx, [si]
		mov ah, bl 			; Armazena em ah e em bl a ultima entrada da porta C
		mov dh, 5 			; Posição do status "Porta C"
		call WRT_BIN_TO_SCRN; Escreve o status da porta C

		; Atualiza o status da ultima entrada
		mov cx, 4			; Número de caracteres para ser escrito por WRT_BIN_TO_SCRN
		mov dh, 22			; Posição do status "Carros"
		call WRT_BIN_TO_SCRN

		mov dh, 21 			; Posição do status "Pista"
		shl ah, 4 			; Desloca os bits menos significativos para o lugar dos mais significativos, pois WRT_BIN_TO_SCRN escreve de tras pra frente
		call WRT_BIN_TO_SCRN

		mov dh, 23 			; Posição do status "Tempo"
		call SET_CUR_POS
		
		mov si, offset LAST_PPA_ENTRY
		mov ax, [si]
		call PARSE_TO_INT
		mov dx, offset CUR_INT
		call WRITE_STR

		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

CREATE_PPA_INT proc
		push ax
		push bx
		push cx
		push dx

		push ds

		mov ax, cs
		mov ds, ax

		mov dx, offset PPA_INT	
		mov al, 6FH 		; Num da int
		mov ah, 25H 		; Gravação do vetor de interrupções
		int 21H
		
		pop ds

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP