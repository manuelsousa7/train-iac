; **********************************************************************
; *		Projeto de Introdução à Arquitetura de Computadores	     
; *													    
; *										  			     
; * Modulo:    projeto_codigo.asm						   
; *	Membros: - Gonçalo Marques (84719)                                   
; *			 - Manuel Sousa (84740)                                    
; *			 - Tiago Novais (84888)					     
; *									        				 
; *													    
; **********************************************************************


hjjhjhjh


; **********************************************************************
; * Constantes
; **********************************************************************

; endereços dos portos do módulo dos comboios (apenas os usados)
LCD_CIMA			EQU  8000H	; endereço do LCD de cima
BOTOES_PRESSAO	     EQU  800CH	; endereço dos botões de pressão		
SEMAFOROS 	     EQU  8012H	; endereço dos semáforos		
SELECAO	          EQU  8018H	; endereço do porto de seleção de comboio e comando		
COMANDO		     EQU  801AH	; endereço do porto onde dar comandos para os comboios		
SENSOR_EVENTOS	     EQU  801CH	; endereço do porto dos sensores (número de eventos)		
SENSOR_INFO	     EQU  801EH	; endereço do porto dos sensores (informação)

SEM_VERDE           EQU  2         ; cor dos semáforos (verde)
SEM_VERMELHO        EQU  1         ; cor dos semáforos (vermelho)
SEM_CINZENTO        EQU  0         ; cor dos semáforos (cinzento)

; **********************************************************************
; * Dados
; **********************************************************************

PLACE     1000H

pilha:		TABLE 100H		; espaço reservado para a pilha (200H bytes, pois são 100H words)
SP_inicial:				     ; este é o endereço (1200H) com que o SP deve ser inicializado.
                                   ; O 1º end. de retorno será armazenado em 11FEH (1200H-2)

cores_semaforos:                   ; tabela para as cores dos semáforos (VERDE, CINZENTO ou VERMELHO).
                                   ; Por omissão, todos os semáforos são mostrados inicialmente a VERDE
     STRING    SEM_VERDE           ; cor do semáforo 0
     STRING    SEM_VERDE           ; cor do semáforo 1
     STRING    SEM_VERDE           ; cor do semáforo 2
     STRING    SEM_VERDE           ; cor do semáforo 3
     STRING    SEM_VERDE           ; cor do semáforo 4
     STRING    SEM_VERDE           ; cor do semáforo 5
     STRING    SEM_VERDE           ; cor do semáforo 6
     STRING    SEM_VERDE           ; cor do semáforo 7
     STRING    SEM_VERDE           ; cor do semáforo 8
     STRING    SEM_VERDE           ; cor do semáforo 9

estado_botao_5:
     WORD      0                   ; estado atual do processo botao_5

; **********************************************************************
; * Código
; **********************************************************************

PLACE		0000H
inicio:

     MOV	SP, SP_inicial           ; inicializa SP para a palavra a seguir à última da pilha

     MOV  R0, 0                    ; número do comboio 0
     MOV	R9, SELECAO
     SHL  R0, 4                    ; nº do comboio: bits 7 a 4
	MOVB	[R9], R0				; o próximo comando vai alterar a velocidade do comboio indicado por R0
	MOV	R9, COMANDO
     MOV  R1, 3                    ; sentido para a frente, velocidade máxima (3)
	MOVB	[R9], R1                 ; põe comboio a andar

ciclo:
     CALL	botao_5                  ; testa o botão de pressão 5 e troca a cor do semáforo 5 quando for premido
     CALL sensores                 ; testa sensores e escreve no LCD quando o comboio passar por um deles
     JMP	ciclo
     
     
; **************************************************************************************************************
; Processo botao_5 - Testa o botão de pressão 5 e troca a cor do semáforo 5 quando for premido.
; ARGUMENTOS: nenhum
; RETORNA:    nada
; **************************************************************************************************************
botao_5:
     PUSH R1
     PUSH R9
     PUSH R10
     PUSH R11

     MOV  R10, estado_botao_5
     MOV  R11, [R10]               ; obtém estado atual do processo botao_5
     
botao_5_0:					; estado 0 - À espera que o botão seja premido
	CMP	R11, 0				; estamos no estado 0?
	JNZ	botao_5_1

espera_botao_premido:
     MOV	R9, BOTOES_PRESSAO       ; endereço do porto dos botões de pressão
     MOVB	R1, [R9]                 ; lê o estado dos botões (modo byte, pois o periférico é de 8 bits)
     BIT  R1, 5                    ; testa o botão de pressão 5
     JZ   botao_5_fim              ; se o bit está a zero, o botão não está carregado. Tem de esperar que seja premido

botao_premido:                     ; botão foi premido! Pode trocar a cor e passar ao estado 1
     MOV  R1, 5                    ; número do semáforo cujan cor é para trocar
     CALL troca_cor_semaforo       ; troca cor do semáforo
     
	MOV	R11, 1
	MOV	[R10], R11			; passa ao estado 1 (atualiza na variável)
	JMP	botao_5_fim              ; mas só na próxima iteração. Agora sai

botao_5_1:					; estado 1 - À espera que o botão seja libertado
	CMP	R11, 1
	JNZ	botao_5_fim              ; se estado desconhecido, sai e ignora

espera_botao_livre:
     MOV	R9, BOTOES_PRESSAO       ; endereço do porto dos botões de pressão
     MOVB	R1, [R9]                 ; lê o estado dos botões (modo byte, pois o periférico é de 8 bits)
     BIT  R1, 5                    ; testa o botão de pressão 5
     JNZ  botao_5_fim              ; se o bit não está a zero, o botão está carregado. Tem de esperar que esteja não premido
     
	MOV	R11, 0
	MOV	[R10], R11			; passa ao estado 0 (atualiza na variável)
	JMP	botao_5_fim
     
botao_5_fim:    
     POP R11
     POP R10
     POP R9
     POP R1
     RET


; **************************************************************************************************************
; Processo sensores - Espera que o comboio passe por um sensor e nessa altura escreve o número do sensor na linha de cima do LCD.
; ARGUMENTOS: nenhum
; RETORNA:    nada
; **************************************************************************************************************
sensores:
     PUSH R1
     PUSH R2
     PUSH R9

espera_eventos:
	MOV	R9, SENSOR_EVENTOS
	MOVB	R1, [R9]		          ; número de eventos de sensores ocorridos
	CMP	R1, 0
	JZ	sensores_fim			; se for zero, não há eventos ainda e pode sair

houve_evento:
	MOV	R9, SENSOR_INFO		; porto dos sensores (informação)
	MOVB	R1, [R9]		          ; lê 1º byte (informação sobre o comboio que passou) - ignora
	MOVB	R2, [R9]		          ; lê 2º byte (número do sensor)

escreve_numero_sensor:
     MOV  R1, 30H                  ; '0'
     ADD  R2, R1                   ; converte número do sensor (0 a 9) para caracter numérico ('0' a '9')
	MOV	R9, LCD_CIMA		     ; porto da linha de cima do LCD
     MOVB [R9], R2                 ; escreve número do sensor no LCD

sensores_fim:
     POP R9
     POP R2
     POP R1
     RET

     
; **************************************************************************************************************
; troca_cor_semaforo - Troca a cor de um dado semáforo (de SEM_VERDE para SEM_VERMELHO e vice-versa).
; ARGUMENTOS: R1 - número do semáforo
; RETORNA:    nada
; **************************************************************************************************************
troca_cor_semaforo:
     PUSH R2
     CALL obtem_cor_semaforo       ; obtém cor do semáforo (em R2)

     CMP  R2, SEM_VERDE
     JZ   poe_vermelho             ; se o semáforo está a verde, põe a vermelho, caso contrário põe a verde
     
poe_verde:
     MOV  R2, SEM_VERDE            ; semáforo via ficar verde
     JMP  atualiza_cor
     
poe_vermelho:
     MOV  R2, SEM_VERMELHO         ; semáforo via ficar vermelho
     
atualiza_cor:
     CALL atualiza_cor_semaforo    ; atualiza cor do semáforo na tabela e na interface.
                                   ; R1 ainda tem o número do semáforo e R2 tem a nova cor
     POP R2
     RET
   
   
; **************************************************************************************************************
; obtem_cor_semaforo - Obtém a cor atual de um dado semáforo (por leitura da tabela de cores dos semáforos).
; ARGUMENTOS: R1 - número do semáforo
; RETORNA:    R2 - cor do semáforo (SEM_VERDE, SEM_VERMELHO ou SEM_CINZENTO)
; **************************************************************************************************************
obtem_cor_semaforo:
     PUSH R10                      ; guarda valor do registo na pilha
     MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
     ADD  R10, R1                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
     MOVB	R2, [R10]                ; lê a cor do semáforo
     POP R10                       ; repõe o valor anterior do registo a partir da cópia guardada na pilha
	RET
	
     
; **************************************************************************************************************
; atualiza_cor_semaforo - Atualiza a cor de um dado semáforo (quer na tabela de cores dos semáforos,
;                         quer no semáforo propriamente dito, na interface de visualização do módulo dos comboios).
; ARGUMENTOS: R1 - número do semáforo
;             R2 - nova cor do semáforo (SEM_VERDE, SEM_VERMELHO ou SEM_CINZENTO)
; RETORNA:    nada
; **************************************************************************************************************
atualiza_cor_semaforo:
     PUSH R1                       ; guarda valores dos registos na pilha
     PUSH R10
     PUSH R11
     MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
     ADD  R10, R1                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
     MOVB	[R10], R2                ; atualiza a cor do semáforo na tabela de cores dos semáforos

     SHL  R1, 2                    ; formato do porto dos semáforos (número do semáforo tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
     ADD  R1, R2                   ; junta cor do semáforo (que fica nos bits 1 e 0)
     MOV  R11, SEMAFOROS           ; endereço do porto dos semáforos no módulo dos comboios
     MOVB [R11], R1                ; atualiza cor no semaforo propriamente dito
     POP R11                       ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
     POP R10
     POP R1
	RET

bascula:
	 MOVB R1,[R9]	
	 BIT R1, 1
	 JNZ bascula
     JMP  le_botoes                ; vai novamente ler os botões
				






