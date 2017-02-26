.model small

.stack 1000H

.data

.code

include CARS_MGR.ASM
include LIGHTS.ASM
include LOG_FILE.ASM
include PPA.ASM
include SCREEN.ASM
include TIMER.ASM
include UTILS.ASM

DRW_STATUS proc
		call DRW_PPA_STATUS
		call DRW_CARS_STATUS
		call DRW_LIGHTS_STATUS
		ret
ENDP

DRAW proc
		call DRW_SCRN 		; Desenha a base da tela
		call DRW_CARS 		; Desenha os carros
		call DRW_TIMER 		; Desenha o timer
		call DRW_LIGHTS		; Desenha semáforos
		call DRW_STATUS		; Atualiza status dos semáforos
		ret
ENDP

UPDATE proc
		call UPDT_LOG 		; Atualiza o arquivo de log
		call UPDT_LIGHTS	; Atualiza os semáforos
		call UPDT_CARS 		; Atualiza os carros
		ret
ENDP

SIM_START proc
		call CHK_ESC_KEY 	; Verifica se a tecla ESC foi pressionada
		call TIMER_TICK 	; Espera 1 segundo
		call PPA_IN 		; Chama o serviço de comunicação da PPA
		call DRAW 			; Desenha todas as entidades
		call UPDATE 		; Atualiza a simulação
		call SIM_START 		; Continua o procedimento recursivamente
		ret
ENDP

START:	call INIT_PROGRAM 	; Inicializa o programa
		call CREATE_PPA_INT ; Cria o serviço de entrada e saída da ppa
		call SET_RES		; Seta a resolução 80x25
		call HIDE_CURSOR 	; Esconde o cursor
		call INIT_PPA 		; Configura a PPA
		call INIT_LIGHTS	; Inicializa os semáforos
		call CREATE_LOG     ; Cria arquivo do log de eventos
		call OPEN_LOG 		; Abre o arquivo de log de eventos
		call SIM_START 		; Começa a simulação
		call END_PROGRAM 	; Finaliza o programa
END START