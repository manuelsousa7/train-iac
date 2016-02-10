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


; **********************************************************************
; * Constantes
; **********************************************************************

; endereços dos portos do módulo dos comboios (apenas os usados)

LCD_CIMA			EQU  8000H	; endereço do LCD de cima
LCD_BAIXO			EQU 8002H ; endereço do LCD de baixo
SLIDERS			EQU 8004H ; endereço dos sliders
TECLADO_1			EQU 8006H ; endereço dos botões 0 a 7
TECLADO_2			EQU 8008H ; endereço dos botões de 8 a F
BOTOES_PRESSAO	     EQU  800CH	; endereço dos botões de pressão		
SEMAFOROS 	     EQU  8012H	; endereço dos semáforos
AGULHAS				EQU 8016H; endereço das agulhas		
SELECAO	          EQU  8018H	; endereço do porto de seleção de comboio e comando	
OPERACAO		     EQU  801AH	; endereço do porto onde dar operações para os comboios		
SENSOR_EVENTOS	     EQU  801CH	; endereço do porto dos sensores (número de eventos)		
SENSOR_INFO	     EQU  801EH	; endereço do porto dos sensores (informação)

SEM_VERDE           EQU  2         ; cor dos semáforos (verde)
SEM_VERMELHO        EQU  1         ; cor dos semáforos (vermelho)
SEM_CINZENTO        EQU  0         ; cor dos semáforos (cinzento)
AGULHA_DIREITA 		EQU  2		   ; orientacão da agulha (direita)
AGULHA_ESQUERDA 	EQU  1		   ; orientação da agulha (direita)

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
    STRING    SEM_CINZENTO        ; cor do semáforo 8
    STRING    SEM_CINZENTO        ; cor do semáforo 9
	
sliders:
	STRING 0					  ; valor do slider de cima
	STRING 0					  ; valor do slider de baixo

sensores_passou:
	STRING	01H				 	  ; sensor 0 vai mudar o semaforo 0 e 1 para vermelho
	STRING	01H				  	  ; sensor 1 vai mudar o semaforo 0 e 1 para vermelho
	STRING	0F2H				  ; sensor 2 vai mudar o semaforo 2 para vermelho
	STRING	034H				  ; sensor 3 vai mudar o semaforo 3 e 4 para vermelho
	STRING	034H				  ; sensor 4 vai mudar o semaforo 3 e 4 para vermelho
	STRING	0F5H				  ; sensor 5 vai mudar o semaforo 5 para vermelho
	STRING	0F6H				  ; sensor 6 vai mudar o semaforo 6 para vermelho
	STRING	0F7H				  ; sensor 7 vai mudar o semaforo 7 para vermelho
	STRING	089H				  ; sensor 8 vai mudar o semaforo 8 e 9 para vermelho
	STRING	0FFH				  ; sensor 9 nao vai mudar semaforos para vermelho
	
sensores_saiu:
	STRING	0F5H				  ; sensor 0 vai mudar o semaforo 5 para verde
	STRING	0F7H				  ; sensor 1 vai mudar o semaforo 7 para verde
	STRING	0F6H				  ; sensor 2 vai mudar o semaforo 6 para verde
	STRING	01H					  ; sensor 3 vai mudar o semaforo 0 e 1 para verde
	STRING	01H					  ; sensor 4 vai mudar o semaforo 0 e 1 para verde
	STRING	034H				  ; sensor 5 vai mudar o semaforo 3 e 4 para verde
	STRING	0F9H				  ; sensor 6 vai mudar o semaforo 9 para verde
	STRING	0F2H				  ; sensor 7 vai mudar o semaforo 2 para verde
	STRING	01H					  ; sensor 8 vai mudar o semaforo 0 e 1 para verde
	STRING	089H				  ; sensor 9 vai mudar o semaforo 8 e 9 para verde
	
inf_comboio:
	STRING		0				; indica o indice do comboio, que é escrito pela int1

inf_sensor:
	STRING		0				; indica o indice do sensor, que é escrito pela int1
	
evento:
	STRING		0				; indica se houve um evento dos sensores
	
tempo_estacao:
	STRING		0				; indica o tempo que o primeiro comboio esteve parado na estação
	STRING		0				; indica o tempo que o segundo comboio esteve parado na estação
	
paragem_estacao:
	STRING 		0				; indica se o primeiro comboio precisa de estar parado na estação
	STRING 		0				; indica se o primeiro comboio precisa de estar parado na estação
	
troca_cinzento:
	STRING		0				; 
	STRING		0				; 
	
estado_botoes_teclado:
    STRING      0                   ; estado atual do botao 0
    STRING      0                   ; estado atual do botao 1
	STRING      0                   ; estado atual do botao 2
	STRING      0                   ; estado atual do botao 3
	STRING      0                   ; estado atual do botao 4
	STRING      0                   ; estado atual do botao 5
	STRING      0                   ; estado atual do botao 6
	STRING      0                   ; estado atual do botao 7
	STRING      0                   ; estado atual do botao 8
	STRING      0                   ; estado atual do botao 9
	
estado_botoes_pressao:
	STRING      0                   ; estado atual do botao 0
    STRING      0                   ; estado atual do botao 1
	STRING      0                   ; estado atual do botao 2
	STRING      0                   ; estado atual do botao 3

mascaras:
	STRING		00000001B			; lista de mascaras
	STRING		00000010B			; lista de mascaras
	STRING		00000100B			; lista de mascaras
	STRING		00001000B			; lista de mascaras
	STRING		00010000B			; lista de mascaras
	STRING		00100000B			; lista de mascaras
	STRING		01000000B			; lista de mascaras
	STRING		10000000B			; lista de mascaras
	STRING		00000001B			; lista de mascaras
	STRING		00000010B			; lista de mascaras
	
estado_sensores:
	STRING		0					; diz se o comboio 0 ja passou pelo sensor
	STRING		0					; diz se o comboio 1 ja passou pelo sensor
	
estado_comboios:
	STRING		0					; se estiver a 0, o primeiro comboio está a andar, senão está parado
	STRING		0					; se estiver a 0, o segundo comboio está a andar, senão está parado
	
estado_agulhas:
	STRING		2 					; Estado Inicial da Agulha 0
	STRING		2					; Estado Inicial da Agulha 1
	STRING		2 					; Estado Inicial da Agulha 2
	STRING		2 					; Estado Inicial da Agulha 3

	
PLACE 5000H
interrupcoes:
	WORD		int0
	WORD		int1
	
	
	
; TROCAR OS SEMAFOROS DA PASSAGEM DE NIVEL	
	
	
	
; **********************************************************************
; * Código
; **********************************************************************

PLACE		0000H
inicio:

    MOV	SP, SP_inicial           ; inicializa SP para a palavra a seguir à última da pilha
	
	MOV R7, 0					; guarda o índice das agulhas (usado na rotina agulhas_rot)
	
	
	;MOV R9, SELECAO
	;MOV R8, 0
	;MOVB [R9], R8
	;MOV R9, OPERACAO
	;MOV R8, 3
	;MOVB [R9], R8				; poe o primeiro comboio a andar
	
	MOV R9, SELECAO
	MOV R8, 1
	SHL R8, 4
	MOVB [R9], R8
	MOV R9, OPERACAO
	MOV R8, 3
	MOVB [R9], R8				; poe o segundo comboio a andar
	
	MOV BTE, interrupcoes
	
	MOV R1, 2
	MOV RCN, R1
	
	EI0							; ativa a interrupção 0
	EI 							; ativa as interrupções
	
ciclo:
	CALL principal					; chama a rotina principal
	CALL rotina_paragem				; vai ver se o comboio deve parar na estação
	CALL agulhas_rot				; muda as agulhas
    JMP ciclo





; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER
; COMENTARIOS COMO DEVE DE SER

int0:
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV	R9, SENSOR_INFO			  ; porto dos	sensores (informação)
	MOVB R1, [R9]		          ; lê 1º byte (informação sobre o comboio que passou)
	MOVB R2, [R9]		          ; lê 2º byte (número do sensor)
	SHR R1, 1
	MOV R5, inf_comboio
	MOVB [R5], R1					; indica qual dos comboios passou pelo sensor na tabela
	MOV R6, inf_sensor
	MOVB [R6], R2					; indica em qual dos sensores o comboio passou na tabela
	MOV R8, evento
	MOV R7, 1
	MOVB [R8], R7				  ; indica que houve evento na tabela
	
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	RFE

int1:
	PUSH R1
	PUSH R2
	
	MOV R1, tempo_estacao
	ADD R1, R3
	MOVB R2, [R1]			; R2 vai obter o numero de meios segundos durante os quais o comboio esteve parado
	ADD R2, 1
	MOVB [R1], R2			; vai incrementar o tempo que o comboio esteve parado em 1 valor
	
int1_fim:
	POP R2
	POP R1
	RFE

; *************************************************************************************************************
; principal - rotina principal, vai mudar os semaforos consoante os sensores pelos quais os comboios passarem
; argumentos - nenhum
; retorna - uns semaforos ficam a verde e outros a vermelho
; *************************************************************************************************************

principal:
	PUSH R0
    PUSH R1
    PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
    PUSH R9
	PUSH R10
	
	MOV R4, evento
	MOVB R6, [R4]
	CMP R6, 0					; se a tabela indicar que houve evento, vai executar as instruções, senão, vai saltar para o fim da rotina
	JZ principal_fim

houve_evento:
	MOV R4, evento
	MOV R6, 0
	MOVB [R4], R6				; vai indicar na tabela que já não há evento
	
	MOV R4, inf_comboio
	MOVB R1, [R4]				; R1 vai obter o numero do comboio que passou
	MOV R9, R1					; R9 vai ser uma cópia de R1
	MOV R6, inf_sensor
	MOVB R2, [R6]				; R2 vai obter o valor do sensor pelo qual o comboio passou
	MOV R10, R2					; R10 vai ser uma cópia do R2, visto que este último vai ser modificado
	
	MOV R5, estado_sensores
	ADD R5, R1
	MOVB R3, [R5]
	CMP R3, 0					  ; se a parte da frente do comboio ja passou pelo sensor, o sensor esta a reconhecer a parte de tras do comboio e poe o(s) semaforo(s) a verde
	JNZ saiu
	JMP escreve_numero_sensor	  ; senao, vai escrever o numero do sensor no LCD
	
saiu:
	MOV R6, 0
	MOVB [R5], R6				; escreve 0 na tabela estado_sensores, a parte de tras do comboio já passou pelo sensor
	CALL semaforos_verde		; vai por o(s) semaforo(s) a verde, visto que a parte de tras do comboio ja passou pelo sensor
		
	CALL semaforos_vermelho		; vai por os semaforos relacionados com este sensor a vermelho, visto que o comboio está a passar por ele
	
	MOV R9, R3
	CALL verifica_semaforo_verde	; vai ver se o outro comboio ja pode andar
	
	JMP principal_fim
	
escreve_numero_sensor:
	MOV R3, R1					 ; R3 vai ser uma cópia do R1
    MOV R1, 30H                  ; '0'
    ADD R2, R1                   ; converte número do sensor (0 a 9) para caracter numérico ('0' a '9')
	MOV	R9, LCD_CIMA		     ; porto da linha de cima do LCD
	ADD R9, R3
	ADD R9, R3					 ; se o comboio que passou for o de baixo, vai adicionar 2 ao endereço para escrever no endereço de baixo
	MOVB [R9], R2                ; escreve número do sensor no LCD
	MOV R4, 1
	MOVB [R5], R4				 ; escreve 1 na tabela estado_sensores, vai esperar que a parte de tras do comboio
								 ; passe pelo sensor, para por o valor da tabela a 0
	
	MOV R0, 2
	CMP R10, R0					; se o sensor lido for o 2, vai parar
	JZ paragem
	MOV R0, 5
	CMP R10, R0					; se o sensor lido for o 5, vai parar
	JZ paragem

verifica_velocidade:
	MOV R9, R3					; indica o índice do comboio
	CALL verifica_semaforo_vermelho		; vai ver se o comboio deve estar parado
	JMP principal_fim

paragem:
	MOV R7, paragem_estacao
	ADD R7, R3
	MOV R6, 1
	MOVB [R7], R6					; indica que o comboio deve estar parado na estação
	
	
	MOV R7, 0						; indica a velocidade a mudar
	MOV R6, 1						; vai escrever que o comboio esta parado na tabela (o valor fica a 1)
	MOV R9, R3						; indica o índice do comboio
	CALL velocidade_comboio			; vai parar o comboio

principal_fim:
	POP R10
    POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
    POP R2
    POP R1
	POP R0
	RET

	
; *************************************************************************************************************
; rotina_paragem - vai ver se o comboio deve parar numa estação
; argumentos - nenhum
; retorna - uns semaforos ficam a verde e outros a vermelho
; *************************************************************************************************************

rotina_paragem:
	PUSH R3
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R9
	PUSH R10
	
	MOV R10, 0

rotina_paragem_sub:
	MOV R5, paragem_estacao
	ADD R5, R10
	MOVB R6, [R5]				; R6 vai indicar se o comboio deve parar na estação
	CMP R6, 1					; se o comboio deve estar parado, vai contar o tempo que esteve parado
	JNZ rotina_paragem_1		; senão, vai saltar e adicionar 1 ao R10
	
	MOV R3, R10
	EI1							; ativa a interrupção 1
	
	MOV R5, tempo_estacao
	ADD R5, R10
	MOVB R6, [R5]				
	CMP R6, 6					; se ja esperou 3 segundos, vai por o comboio a andar
	JNZ rotina_paragem_fim		; senão vai saltar para o fim da rotina
	
	MOV R5, paragem_estacao
	ADD R5, R10
	MOV R6, 0
	MOVB [R5], R6				; vai indicar que o comboio já não deve estar parado
	
	MOV R7, 3						; indica a velocidade a executar
	MOV R6, 0						; vai escrever que o comboio esta parado na tabela (o valor fica a 1)
	MOV R9, R10						; indica o índice do comboio
	CALL velocidade_comboio			; vai parar o comboio
	
	MOV R5, tempo_estacao
	ADD R5, R10
	MOV R6, 0
	MOVB [R5], R6
	
	DI1
	
	CMP R10, 0
	JZ rotina_paragem_sub
	JMP rotina_paragem_fim

rotina_paragem_1:
	CMP R10, 0
	JNZ rotina_paragem_fim
	
	ADD R10, 1
	JMP rotina_paragem_sub
	
rotina_paragem_fim:
	POP R10
	POP R9
	POP R7
	POP R6
	POP R5
	POP R3
	RET
	

; *************************************************************************************************************
; int1 - rotina de interrupção 1, vai contar o tempo que o comboio fica parado
; argumentos - R3 (indice do comboio)
;			   R5 (para escolher as instruções)
; retorna - o tempo que o semáforo ficou parado
; *************************************************************************************************************
	
	
	
; **************************************************************************************************************
; verifica_semaforo_vermelho - vai verificar se o semaforo esta a verde, para poder avançar
; argumentos - R10 (indice do semaforo)
; retorna - o comboio parado ou a andar, consoante a cor do semaforo
; **************************************************************************************************************	
verifica_semaforo_vermelho:
	PUSH R3
	PUSH R4
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R3, cores_semaforos
	ADD R3, R10
	MOVB R4, [R3]				; vai ver se o semaforo correspondente ao sensor esta vermelho
	
	CMP R4, SEM_VERMELHO
	JNZ verifica_semaforo_vermelho_fim				 ; se nao estiver vermelho, vai saltar para o fim da rotina

semaforo_vermelho:
	CALL verifica_comboio
	CMP R3, 0
	JNZ verifica_semaforo_vermelho_fim		; se o comboio estiver a andar, vai pará-lo, senao, salta para o fim da rotina
	
	MOV R7, 0						; indica a velocidade a executar
	MOV R6, 1						; vai escrever que o comboio esta parado na tabela (o valor fica a 1)
	CALL velocidade_comboio			; vai parar o comboio

verifica_semaforo_vermelho_fim:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R4
	POP R3
	RET
	
	
; **************************************************************************************************************
; verifica_comboio - vai verificar se o comboio esta parado ou a andar
; argumentos - R9 (indice do comboio)
; **************************************************************************************************************	

verifica_comboio:
	PUSH R2
	
	MOV R2, estado_comboios
	ADD R2, R9
	MOVB R3, [R2]				; vai ver se o comboio esta parado ou a andar
	
	POP R2
	RET

	

; **************************************************************************************************************
; velocidade_comboio - vai por o comboio a andar ou pará-lo
; argumentos: R7 (velocidade do comboio, 0 ou 3)
;			  R9 (indice do comboio)
;			  R6 (valor a escrever na tabela)
; **************************************************************************************************************	
	
velocidade_comboio:
	PUSH R5
	PUSH R6
	PUSH R9
	
	MOV R5, SELECAO
	SHL R9, 4
	MOVB [R5], R9				; vai ser indicado qual dos comboios mudar a velocidade
	MOV R5, OPERACAO
	MOVB [R5], R7				; vai por o comboio a velocidade 0 ou 3
	MOV R5, estado_comboios
	ADD R5, R9
	MOVB [R5], R6				; vai atualizar a tabela do estado do comboio
	
	POP R9
	POP R6
	POP R5
	RET
	
	
; **************************************************************************************************************
; semaforos_vermelho - vai por os semaforos a vermelho de acordo com os sensores
; argumentos - R10 (indice do sensor)
; **************************************************************************************************************	
	
semaforos_vermelho:
	PUSH R1
	PUSH R2
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R1, 8
	CMP R10, R1
	JZ muda_passagem_0			; se o sensor lido for o 8, vai por os semaforos da passagem de nivel a vermelho e cinzento
	MOV R9, sensores_passou
	ADD R9, R10
	MOVB R8, [R9]				; R8 vai analisar quais os semaforos a mudar
	MOV R7, R8					; R7 vai ser uma cópia de R8
	SHR R7, 4					; R7 vai armazenar o indice um dos semaforos a mudar
	
indice_0_vermelho:
	MOV R6, 1111B				; vai atuar como uma mascara que obtem os 4 bits de menor peso
	CMP R7, R6					; se os 4 bits de maior peso estiverem a F, não é suposto mudar nada, senao muda também esse semaforo
	JNZ muda_semaforo_vermelho
	
indice_1_vermelho:
	MOV R7, R8
	AND R7, R6
	MOV R2, SEM_VERMELHO
	CALL troca_semaforo		; vai por o semaforo a vermelho, visto que o o comboio passou pelo sensor
	
	JMP semaforos_vermelho_fim
	
muda_semaforo_vermelho:
	MOV R2, SEM_VERMELHO
	CALL troca_semaforo		; vai por o semaforo a vermelho, visto que o comboio passou pelo sensor
	
	JMP indice_1_vermelho		; vai saltar para a instrução que muda o segundo semaforo para vermelho
	
muda_passagem_0:
	
	
	
semaforos_vermelho_fim:	
	POP R9
	POP R8
	POP R7
	POP R6
	POP R2
	POP R1
	RET
	

	
; **************************************************************************************************************
; semaforos_verde - vai por os semaforos a verde de acordo com os sensores
; argumentos - R10 (indice do sensor)
; **************************************************************************************************************	
	
semaforos_verde:
	PUSH R1
	PUSH R2
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R1, 9
	CMP R10, R1
	JZ muda_passagem_1			; se o sensor lido for o 9, vai mudar os semaforos da passagem de nivel
	MOV R9, sensores_saiu
	ADD R9, R10
	MOVB R8, [R9]				; R8 vai analisar quais os semaforos a mudar devido a este sensor
	MOV R7, R8					; R7 vai ser uma cópia de R8
	SHR R7, 4					; R7 vai armazenar um dos semaforos a mudar
	
indice_0_verde:
	MOV R6, 1111B				; vai atuar como uma mascara que obtem os 4 bits de menor peso
	CMP R7, R6					; se o primeiro valor estiver a F, não é suposto mudar nada
	JNZ muda_semaforo_verde
	
indice_1_verde:
	MOV R7, R8
	AND R7, R6
	MOV R2, SEM_VERDE
	CALL troca_semaforo
	
	JMP semaforos_verde_fim
	
muda_semaforo_verde:
	MOV R2, SEM_VERDE
	CALL troca_semaforo		; vai por o semaforo a verde, visto que a parte de tras do comboio passou pelo sensor
	
	JMP indice_1_verde		; vai saltar para a instrução que muda o segundo semaforo para verde
;
;
;	
muda_passagem_1:
	MOV R9, sensores_saiu
	ADD R9, R10
	MOVB R8, [R9]				; R8 vai analisar quais os semaforos a mudar devido a este sensor
	MOV R7, R8					; R7 vai ser uma cópia de R8
	SHR R7, 4					; R7 vai armazenar um dos semaforos a mudar
	
indice_0_cinzento_1:
	MOV R6, 1111B				; vai atuar como uma mascara que obtem os 4 bits de menor peso
	CMP R7, R6					; se o primeiro valor estiver a F, não é suposto mudar nada
	JNZ muda_semaforo_cinzento_1

indice_1_cinzento_1:
	MOV R7, R8
	AND R7, R6
	MOV R2, SEM_VERDE
	CALL troca_semaforo
	
	JMP semaforos_verde_fim
	
muda_semaforo_cinzento_1:
	MOV R2, SEM_CINZENTO
	CALL troca_semaforo		; vai por o semaforo a cinzento, visto que a parte de tras do comboio passou pelo sensor
	
	JMP indice_1_cinzento_1		; vai saltar para a instrução que muda o segundo semaforo para cinzento	
;
;
;	
semaforos_verde_fim:	
	POP R9
	POP R8
	POP R7
	POP R6
	POP R2
	POP R1
	RET



; **************************************************************************************************************
; troca_semaforo - Troca a cor de um dado semáforo (de SEM_VERDE para SEM_VERMELHO e vice-versa).
; **************************************************************************************************************
troca_semaforo:
    PUSH R2
	PUSH R3
	
	MOV R3, 8
	CMP R7, R3
	JZ poe_cinzento				  ; se o semáforo tiver índice 8, e estiver vermelho, vai por cinzento
	MOV R3, 9
	CMP R7, R3
	JZ poe_cinzento				  ; se o semáforo tiver índice 9, e estiver vermelho, vai por cinzento
	
atualiza_cor:
    CALL atualiza_cor_semaforo    ; atualiza cor do semáforo na tabela e na interface	
    JMP troca_semaforo_fim
	
poe_verde:
    MOV  R2, SEM_VERDE            ; semáforo vai ficar verde
    JMP  atualiza_cor
	
poe_cinzento:
	MOV R2, SEM_CINZENTO
	JMP  atualiza_cor			  ; semáforo vai ficar cinzento
     
poe_vermelho:
    MOV  R2, SEM_VERMELHO         ; semáforo via ficar vermelho

troca_semaforo_fim:	
	POP R3								   
    POP R2
    RET
   
   
; **************************************************************************************************************
; obtem_cor_semaforo - Obtém a cor atual de um dado semáforo (por leitura da tabela de cores dos semáforos).
; ARGUMENTOS: R1 - número do semáforo
; RETORNA:    R2 - cor do semáforo (SEM_VERDE, SEM_VERMELHO ou SEM_CINZENTO)
; **************************************************************************************************************
obtem_cor_semaforo:
    PUSH R10
	
    MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
    ADD  R10, R7                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
    MOVB R2, [R10]                ; lê a cor do semáforo
	
    POP R10                       
	RET
	
; **************************************************************************************************************
; atualiza_cor_semaforo - Atualiza a cor de um dado semáforo (quer na tabela de cores dos semáforos,
;                         quer no semáforo propriamente dito, na interface de visualização do módulo dos comboios).
; ARGUMENTOS: R1 - número do semáforo
;             R2 - nova cor do semáforo (SEM_VERDE, SEM_VERMELHO ou SEM_CINZENTO)
; RETORNA:    nada
; **************************************************************************************************************
atualiza_cor_semaforo:
    PUSH R7                       ; guarda valores dos registos na pilha
    PUSH R10
    PUSH R11
	
    MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
    ADD  R10, R7                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
    MOVB [R10], R2             ; atualiza a cor do semáforo na tabela de cores dos semáforos

    SHL  R7, 2                    ; formato do porto dos semáforos (número do semáforo tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
    ADD  R7, R2                   ; junta cor do semáforo (que fica nos bits 1 e 0)
    MOV  R11, SEMAFOROS           ; endereço do porto dos semáforos no módulo dos comboios
    MOVB [R11], R7                ; atualiza cor no semaforo propriamente dito
	
    POP R11                       ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
    POP R10
    POP R7
	RET




verifica_semaforo_verde:
	PUSH R6
	PUSH R7
	PUSH R9
	
	CALL verifica_comboio
	CMP R3, 0						; se R3 for 0, o comboio está a andar
	JZ verifica_semaforo_verde_fim		; se o comboio estiver parado, vai pô-lo a andar, senão, salta para o fim da rotina

	MOV R7, 3						; indica a velocidade a executar
	MOV R6, 0						; vai escrever que o comboio esta a andar na tabela (o valor fica a 0)
	CALL velocidade_comboio			; vai por o comboio a andar

verifica_semaforo_verde_fim:	
	POP R9
	POP R7
	POP R6
	RET
	
	
	
	
	
	
	
	
	
	
	
	
; **************************************************************************************************************
; agulhas - atualiza o estado das agulhas
; **************************************************************************************************************

agulhas_rot:
	PUSH R2
	PUSH R8
	
	MOV R8, 0100B					; R8 vai ser 4 (0100)
	CMP R7, R8						; enquanto o indice da agulha nao for 4, vai continuar a executar a rotina
	JNZ agulhas_rot_sub
	MOV R7, 0						; senão vai reiniciar o indice a 0
	JMP agulhas_fim

agulhas_rot_sub:
	CALL estado_pressao				; esta rotina vai obter o estado do botao de pressao de indice R7 
	CMP R2, 0
	JNZ agulha_livre				; se o indice for 1, vai esperar que fique a 0,
									; senão, o indice é 0, e vai esperar que fique a 1

agulha_premida:
	CALL espera_agulha_premida		; a estado da agulha esta a 0, vai ver se o botao correspondente esta carregado ou nao
	JMP agulhas_fim_sub
	
agulha_livre:
	CALL espera_agulha_livre		; a estado da agulha esta a 1, vai ver se o botao correspondente esta carregado ou nao

agulhas_fim_sub:
	ADD R7, 1						; incrementa o indice das agulhas	
agulhas_fim:
	POP R8
	POP R2
	RET


; **************************************************************************************
; estado_pressao - vai obter o estado do botao de pressao de indice R7
; **************************************************************************************

estado_pressao:
	PUSH R1
	MOV R1, estado_botoes_pressao
	ADD R1, R7
	MOVB R2, [R1]				; R2 vai receber o estado do botao de pressão de indice R7
	
estado_pressao_fim:
	POP R1
	RET
	
; **************************************************************************************************************
; espera_agulha_premida - vai verificar se o botao de pressao está premido
; **************************************************************************************************************

espera_agulha_premida:
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	
	MOV R9, BOTOES_PRESSAO
	MOVB R8, [R9]							; R8 vai receber o valor dos BOTOES_PRESSAO
	MOV R5, mascaras
	ADD R5, R7
	MOVB R6, [R5]							; R6 vai ser a mascara dependendo do indice (R7)
	AND R8, R6								; R8 vai ter o valor do botao de pressao	
	CMP R8, 0								; se estiver a 0, o botao nao esta carregado, vai saltar as proximas intruções
	JZ espera_agulha_premida_fim
	
	CALL troca_agulha						; vai executar a rotina que troca a agulha no visualizador
	
	MOV R4, 1
	MOV R3, estado_botoes_pressao
	ADD R3, R7
	MOVB [R3], R4							; vai escrever 1 no estado do botao de indice R7

espera_agulha_premida_fim:
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	RET
	
; **************************************************************************************************************
; espera_agulha_livre - vai verificar se o botao de pressao está livre
; **************************************************************************************************************

espera_agulha_livre:
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	
	MOV R9, BOTOES_PRESSAO
	MOVB R8, [R9]							; R8 vai receber o valor dos BOTOES_PRESSAO
	MOV R5, mascaras
	ADD R5, R7
	MOVB R6, [R5]							; R6 vai ser a mascara dependendo do indice (R7)
	AND R8, R6								; R8 vai ter o valor do botao de pressao
	CMP R8, 0								; se estiver a 1, o botao esta carregado, vai saltar as proximas intruções
	JNZ espera_agulha_livre_fim
	
	;CALL troca_estado
	
	MOV R4, 0
	MOV R3, estado_botoes_pressao
	ADD R3, R7
	MOVB [R3], R4							; vai escrever 0 no estado do botao de indice R7
	
espera_agulha_livre_fim:
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	RET
	
	
; **************************************************************************************
; troca_agulha - vai trocar a agulha no visualizador e atualizar na tabela estado_agulhas
; **************************************************************************************

troca_agulha:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R7
	
	MOV R1, AGULHAS
	MOV R2, estado_agulhas
	ADD R2, R7
	MOVB R3, [R2]					; R3 vai buscar o valor da agulha de indice R7
	SHL R7, 2
	MOV R5, 0011B
	XOR R3, R5						; R3 vai ficar com o novo estado da agulha
	MOVB [R2], R3					; vai ser escrito o novo estado da agulha na tabela estado_agulhas
	ADD R7, R3
	MOVB [R1], R7					; R4 vai mudar a agulha no visualizador
	
troca_agulha_fim:
	POP R7
	POP R5
	POP R3
	POP R2
	POP R1
	RET
	
; **************************************************************************************
; troca_agulha_2 - vai atualizar na tabela estado_agulhas
; **************************************************************************************

troca_estado:
	PUSH R2
	PUSH R3
	PUSH R5
	
	MOV R2, estado_agulhas
	ADD R2, R7
	MOVB R3, [R2]					; R3 vai buscar o valor da agulha de indice R7
	MOV R5, 0011B
	XOR R3, R5						; R3 vai ficar com o novo estado da agulha
	MOVB [R2], R3					; vai ser escrito o novo estado da agulha na tabela estado_agulhas
	
troca_estado_fim:
	POP R5
	POP R3
	POP R2
	RET
	
	
	
	
	


