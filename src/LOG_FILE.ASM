.data

FILE_N db 'Log.txt',0	    ; String com nome do arquivo de log
FILE_HANDLE dw 0            ; Handle do arquivo do log  

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Strings para uso do log ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

CHAR_TAB  db  09
CHAR_CR   db  13
CHAR_ONE  db  49
CHAR_ZERO db  48
CHAR_SPAC db  32

.code

CREATE_LOG proc             ; Cria o arquivo de log na pasta do executável
		push ax
		push cx
		push dx

		xor cx, cx	        ; Atributos do arquivo
		mov dx, offset FILE_N ; Nome do arquivo
		mov ah, 3ch			; Modo para criar arquivo
		int 21h

		pop dx
		pop cx
		pop ax
		ret
ENDP

OPEN_LOG proc               ; Abre o arquivo de log, handle em ax é salvo em FILE_HANDLE
		push ax
		push bx
		push dx

		mov dx, offset FILE_N ; Nome do arquivo
		mov al, 2d          ; Modo "Read/Write"
		mov ah, 03dh        ; Modo "Open"
		int 21h

		mov bx, offset FILE_HANDLE
		mov [bx], ax 		; Salva handle

		pop dx
		pop bx
		pop ax
		ret
ENDP

CLOSE_LOG proc              ; Fecha o arquivo de log
		push ax

		mov bx, FILE_HANDLE
		mov ah, 03eh        ; Modo "Close"
		int 21h

		pop ax
		ret
ENDP

WRT_TIME proc               ; Escrita do tempo
		push ax
		push dx
		push cx

		mov ax, SECONDS
		call PARSE_TO_INT
		mov dx, offset CUR_INT; Dado a ser escrito
		xor ax, ax
		mov ah, 40h         ; Função 40h, "Write"
		mov cx, 4           ; Escrever 4 caractares
		int 21h             ; InterrupÃ§Ã£o 21h    

		call WRT_TAB 

		pop cx
		pop dx
		pop ax
		ret
ENDP

WRT_TAB proc                ; TAB no arquivo
		push ax
		push cx
		push dx

		mov ah, 40h  
		mov dx, offset CHAR_TAB 
		mov cx, 1           ; Escrever 1 caracteres
		int 21h

		pop dx
		pop cx
		pop ax
		ret
ENDP

WRT_SPACE proc              ; SPACE no arquivo
		push ax
		push dx
		push cx

		mov ah, 40h
		mov dx, offset CHAR_SPAC
		mov cx, 1
		int 21h

		pop cx
		pop dx
		pop ax
		ret
ENDP

WRT_CR proc                 ; Quebra de linha no arquivo
		push ax
		push dx
		push cx
		
		mov ah, 40h  
		mov dx, offset CHAR_CR
		mov cx, 1           ; Escrever 1 caracteres
		int 21h

		pop cx
		pop dx
		pop ax
		ret
ENDP

WRT_ST_NORTE proc
		push ax
		push cx
		push dx

		;**** Semáforo ****;
		mov si, offset SEM_NS
		mov ax, [si]
		mov cx, 4
		call WRT_BIN

		call WRT_TAB

		;**** Rua de conversão NORTE ***;
		mov ah, 40h
		mov dh, 0		
		mov dl, 27
		call GET_ROW_NS
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de frente NORTE ***;
		mov ah, 40h
		mov dh, 0
		mov dl, 25
		call GET_ROW_NS
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE 

		;**** Rua de conversão a direita NORTE ***;
		mov ah, 40h
		mov dh, 0
		mov dl, 23
		call GET_ROW_NS
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE 

		;**** Rua de conversão a direita após semáforo NORTE ***;
		mov ah, 40h
		mov dh, 0
		mov dl, 31
		call GET_ROW_NS
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE 

		;**** Rua de conversão a esquerda após semáforo NORTE ***;
		mov ah, 40h
		mov dh, 0
		mov dl, 29
		call GET_ROW_NS
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_CR
		call WRT_TAB
		call WRT_TAB

		pop dx
		pop cx
		pop ax
		ret
ENDP

WRT_ST_SUL proc
		push ax
		push cx
		push dx

		;**** Semáforo ****;
		mov si, offset SEM_NS
		mov ax, [si]
		mov cx, 4
		call WRT_BIN

		call WRT_TAB

		;**** Rua de conversão SUL ***;
		mov ah, 40h
		mov dh, 24
		mov dl, 27
		call GET_ROW_SN
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de frente SUL ***;
		mov ah, 40h
		mov dh, 24
		mov dl, 29
		call GET_ROW_SN
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão a direita SUL ***;
		mov ah, 40h
		mov dh, 24
		mov dl, 31
		call GET_ROW_SN
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão a direita após sinal SUL ***;
		mov ah, 40h
		mov dh, 24
		mov dl, 23
		call GET_ROW_SN
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão a esquerda após sinal SUL ***;
		mov ah, 40h
		mov dh, 24
		mov dl, 25
		call GET_ROW_SN
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_CR
		call WRT_TAB
		call WRT_TAB

		pop dx
		pop cx
		pop ax
		ret
ENDP

WRT_ST_LESTE proc
		push ax
		push cx
		push dx

		;**** Leste ****;
		mov si, offset SEM_LO
		mov ax, [si]
		mov cx, 4
		call WRT_BIN

		call WRT_TAB

		;**** Rua de conversão LESTE ***;
		mov ah, 40h
		mov dl, 55
		mov dh, 12
		call GET_ROW_LO
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de frente LESTE ***;
		mov ah, 40h
		mov dl, 55
		mov dh, 11
		call GET_ROW_LO
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão direita LESTE ***;
		mov ah, 40h
		mov dl, 55
		mov dh, 10
		call GET_ROW_LO
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão esquerda após sinal LESTE ***;
		mov ah, 40h
		mov dl, 55
		mov dh, 13
		call GET_ROW_LO
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão direita após sinal LESTE ***;
		mov ah, 40h
		mov dl, 55
		mov dh, 14
		call GET_ROW_LO
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_CR
		call WRT_TAB
		call WRT_TAB

		pop dx
		pop cx
		pop ax
		ret
ENDP

WRT_ST_OESTE proc
		push ax
		push cx
		push dx

		;**** SEMÁFORO ****;
		mov si, offset SEM_LO
		mov ax, [si]
		mov cx, 4
		call WRT_BIN

		call WRT_TAB

		;**** Rua de conversão OESTE ***;
		mov ah, 40h
		mov dh, 12
		mov dl, 0
		call GET_ROW_OL
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de frente OESTE ***;
		mov ah, 40h
		mov dh, 13
		mov dl, 0
		call GET_ROW_OL
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão direita OESTE ***;
		mov ah, 40h
		mov dh, 14
		mov dl, 0
		call GET_ROW_OL
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão esquerda após sinal OESTE ***;
		mov ah, 40h
		mov dh, 11
		mov dl, 0
		call GET_ROW_OL
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_SPACE

		;**** Rua de conversão direita após sinal OESTE ***;
		mov ah, 40h
		mov dh, 55
		mov dl, 10
		call GET_ROW_OL
	    mov dx, offset ROW_STATE
		mov cx, 5
		int 21h

		call WRT_CR
		call WRT_TAB
		call WRT_TAB

		pop dx
		pop cx
		pop ax
		ret
ENDP

WRT_ST_PPA proc
		push si
		push ax
		push cx	

		mov si, offset LAST_PPA_C
		mov al, byte ptr [si]
		mov cx, 6
		call WRT_BIN

		pop cx
		pop ax
		pop si
		ret
ENDP

UPDT_LOG proc
		push ax
		push bx
		push cx
		push dx

		mov bx, FILE_HANDLE ; Pega o FILE_HANDLE da memória
		
		call WRT_TIME

		call WRT_ST_NORTE
		call WRT_ST_SUL
		call WRT_ST_LESTE
		call WRT_ST_OESTE

		call WRT_ST_PPA
		
		call WRT_CR
		call WRT_CR

		pop dx
		pop cx
		pop bx
		pop ax
		ret
ENDP

WRT_BIN proc         		; Converte int em AX para string, para ser escrito em arquivo   
  		push bx
  
  		mov bx, cx
  
PARSING:shr ax, 1    		; Verifica se o byte é '0' ou '1' e seta dx com o respectivo caracter
 		jnc ZERO 
  		mov dx, offset CHAR_ONE
  		jmp SAVE_BIT
ZERO: 	mov dx, offset CHAR_ZERO

SAVE_BIT:      
  		push dx       		; Empilha o caracter
  		loop PARSING   		; Loop para todos os caracteres
  
  		mov cx, bx

PRINT: 	pop dx     			; Desempilha os caracteres convertidos
  		push cx    			; Empilha o index do loop atual
  		mov ah, 40h
  		mov cx, 1
  		mov bx, FILE_HANDLE
  		int 21h    			; Escreve no arquivo
		
		pop cx    			; Desempilha o index do loop 
		loop PRINT

		pop bx
  		ret
ENDP