; **********************************************************************
; *		Projeto de Introdução à Arquitetura de Computadores	     
; *													    
; *										  			     					   
; *	Membros: - Gonçalo Marques (84719)                                   
; *			 - Manuel Sousa (84740)                                    
; *			 - Tiago Novais (84888)	
; *
; * Número do Grupo: 1		     
; *									        				 
; *													    
; **********************************************************************


; **********************************************************************
; * Constantes
; **********************************************************************

; endereços dos portos do módulo dos comboios

LCD_CIMA			EQU  8000H	; endereço do LCD de cima
LCD_BAIXO			EQU 8002H ; endereço do LCD de baixo
SLIDERS			EQU 8004H ; endereço dos sliders
TECLADO_1			EQU 8006H ; endereço dos botões do teclado de 0 a 7
TECLADO_2			EQU 8008H ; endereço dos botões do teclado de de 8 a F
BOTOES_PRESSAO	     EQU  800CH	; endereço dos botões de pressão		
SEMAFOROS 	     EQU  8012H	; endereço dos semáforos
AGULHAS				EQU 8016H; endereço das agulhas		
SELECAO	          EQU  8018H	; endereço do porto de seleção de comboio
OPERACAO		     EQU  801AH	; endereço do porto de operações sobre o comboio	
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
	STRING		0
	STRING		0
	
estado_agulhas:
	STRING		AGULHA_DIREITA 					; Estado Inicial da Agulha 0
	STRING		AGULHA_DIREITA					; Estado Inicial da Agulha 1
	STRING		AGULHA_DIREITA 					; Estado Inicial da Agulha 2
	STRING		AGULHA_DIREITA 					; Estado Inicial da Agulha 3

	
	
	
	
	
	
	
	
	
; **********************************************************************
; * Código
; **********************************************************************

PLACE		0000H
inicio:

    MOV	SP, SP_inicial           ; inicializa SP para a palavra a seguir à última da pilha
	
	MOV R6, 0					; guarda o índice dos semáforos (usado na rotina botoes_rot)
	MOV R7, 0					; guarda o índice das agulhas (usado na rotina agulhas_rot)

ciclo:
	CALL sliders_rot				 ; muda a velocidade dos comboios
    CALL botoes_rot                  ; muda a cor dos semaforos
    CALL sensores_rot                ; escreve numeros nos sensores
	CALL agulhas_rot				 ; muda as agulhas
    JMP ciclo

	
	
	
	
	
	
	
	
	
	
	
	

; **************************************************************************************************************
; sliders_rot - vai ler os sliders
; **************************************************************************************************************

sliders_rot:
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R7
	PUSH R8
	PUSH R9
	MOV R1, SLIDERS
	
slider_1:
	MOVB R2, [R1]
	SHR R2, 4					; vai ler o slider de cima
	MOV R8, sliders				; vai ler o valor guardado na tabela
	MOVB R9, [R8]
	MOV R7, 0					; vai guardar o numero do comboio
	CMP R2, R9					
	JZ slider_2				; se o valor do slider for igual ao valor que já estava guardado, vai saltar para o slider_2
	CALL sliders_troca			; senão vai atualizar a velocidade dos sliders
	
slider_2:
	MOVB R2, [R1]
	MOV R4, 1111B
	AND R2, R4
	ADD R8, 1
	MOVB R9, [R8]
	MOV R7, 1					; vai guardar o numero do comboio
	CMP R2, R9					
	JZ sliders_fim				; se R2 for igual a R9 (o que estiver guardado na tabela), vai saltar para o fim da rotina
	CALL sliders_troca			; senão vai atualizar a velocidade dos sliders
		
sliders_fim:
	POP R9
	POP R8
	POP R7
	POP R4
	POP R2
	POP R1
	RET
	
; **************************************************************************************************************
; sliders_troca - vai trocar o valor va velocidade do comboio, consoante  valor indicado no slider
; **************************************************************************************************************
sliders_troca:
	PUSH R1
	PUSH R3
	PUSH R4
	PUSH R5
	
	MOV R8, sliders	
	MOV R3, SELECAO
	ADD R8, R7
	MOVB [R8], R2				; guarda o valor do slider na tabela
	SHL R7, 4
	MOVB [R3], R7				; escreve 0 ou 1 na SELEÇÃO (número do comboio) 
	MOV R5, R2
	SHR R2, 3
	SHL R2, 7					; R2 vai obter o sentido da velocidade indicado no slider
	MOV R1, 0111B				; R1 vai servir como uma mascara que obtem a velocidade (0111)
	AND R5, R1
	MOV R4, OPERACAO				
	ADD R2, R5					; a some entre R2 e R5 vai dar o sentido e a velocidade do comboio
	MOVB [R4], R2				; escreve R2 na OPERACAO
	
	POP R5
	POP R4
	POP R3
	POP R1
	RET
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
; **************************************************************************************************************
; botoes_rot - Testa os botoes do teclado e troca a cor dos semáforos quando forem premidos os botoes
; **************************************************************************************************************
botoes_rot:
	PUSH R2
	PUSH R5
	
botoes_rot_inicio:
	MOV R5, 1000B						; R5 = 8 (1000)
	CMP R6, R5							; se o indice (R6) for maior ou igual que 8 (R5), vai ler o segundo teclado e não o primeiro
	JGE botoes_2
	CALL estado_teclado_1				; esta rotina vai verificar o estado dos botoes do teclado_1 guardados na tabela
	CMP R2, 0							
	JNZ botao_livre						; se o estado do botao for 0, vai verificar se o botao está a 1 para atualizar
										; o valor nas variáveis, senão, vai verificar se o botão está a 0
botao_premido:										
	CALL espera_botao_premido			; o botao esta a 0, e esta rotina vai ver se o teclado está premido
	JMP botao_fim_sub
	
botao_livre:
	CALL espera_botao_livre				; vai verificar se o botão está a 1
	
botao_fim_sub:
	ADD R6,1							; incrementa R6 para poder verificar o próximo indice
	JMP botoes_fim
	
botoes_2:
	MOV R5, 1010B
	CMP R6, R5							; se R6 for 10, ultrapassou o limite do índice,
	JNZ botao_2
	MOV R6, 0							; vai por R6 a 0 (reinicializa a incrementação)
	JMP botoes_fim
	
botao_2:
	CALL estado_teclado_2				; esta rotina vai verificar o estado dos botoes do teclado_2 guardados na tabela
	CMP R2, 0							
	JNZ botao_livre						; se o estado do botao for 0, vai verificar se o botao está a 1 para atualizar
										; o valor nas variáveis, senão, vai verificar se o botão está a 0
	JMP botao_premido
	

botoes_fim:
    POP R5
	POP R2
    RET

; **************************************************************************************************************
; estado_teclado_1 - vai verificar o estado dos botoes do teclado_1
; **************************************************************************************************************

estado_teclado_1:
	PUSH R1
	MOV R1, estado_botoes_teclado
	ADD R1, R6
	MOVB R2, [R1]				; R2 vai receber o estado do botao do teclado_1 de indice R6
	
estado_teclado_1_fim:
	POP R1
	RET
	
; **************************************************************************************************************
; estado_teclado_2 - vai verificar o estado dos butoes do teclado_2
; **************************************************************************************************************

estado_teclado_2:
	PUSH R1
	MOV R1, estado_botoes_teclado
	ADD R1, R6
	MOVB R2, [R1]				; R2 vai receber o estado do botao do teclado_2 de indice R6
	
estado_teclado_2_fim:
	POP R1
	RET	
	
; **************************************************************************************************************
; espera_botao_premido - vai verificar se o botao do teclado está premido
; **************************************************************************************************************

espera_botao_premido:
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R2, 8
	CMP R6, R2
	JGE espera_botao_premido_2
	MOV R9, TECLADO_1
	MOVB R8, [R9]							; R8 vai receber o valor dos botoes do teclado_1
	MOV R5, mascaras
	ADD R5, R6								; R5 vai ser uma das mascaras indicadas na tabela mascaras, dependendo de R6
	MOVB R7, [R5]
	AND R8, R7								; R8 vai ter o valor do botao do teclado_1
	CMP R8, 0								; se estiver a 0, o botao nao esta carregado, vai saltar as proximas intruções
	JZ espera_botao_premido_fim

	CALL troca_cor_semaforo					; vai mudar a cor do semaforo
	
	MOV R4, 1
	MOV R3, estado_botoes_teclado
	ADD R3, R6
	MOVB [R3], R4							; vai escrever 1 no estado do botao de indice R6
	JMP espera_botao_premido_fim
	
espera_botao_premido_2:
	MOV R9, TECLADO_2
	MOVB R8, [R9]
	MOV R5, mascaras
	ADD R5, R6								; R5 vai ser uma das mascaras indicadas na tabela mascaras, dependendo de R9
	MOVB R7, [R5]
	AND R8, R7								; R8 vai ter o valor do botao do teclado_2
	CMP R8, 0								; se estiver a 0, o botao nao esta carregado, vai saltar as proximas intruções
	JZ espera_botao_premido_fim

	CALL troca_cor_semaforo					; vai mudar a cor do semaforo
	
	MOV R4, 1
	MOV R3, estado_botoes_teclado
	ADD R3, R6
	MOVB [R3], R4							; vai escrever 1 no estado do botao de indice R6
	
espera_botao_premido_fim:
	POP R9
	POP R8
	POP R7
	POP R5
	POP R4
	POP R3
	POP R2
	RET
	

; **************************************************************************************************************
; espera_botao_livre - vai verificar se o botao do teclado está livre
; **************************************************************************************************************

espera_botao_livre:
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R2, 8
	CMP R6, R2
	JGE espera_botao_livre_2
	MOV R9, TECLADO_1
	MOVB R8, [R9]							; R8 vai receber o valor dos botoes do teclado_1
	MOV R5, mascaras
	ADD R5, R6								; R5 vai ser uma das mascaras indicadas na tabela mascaras, dependendo do indice (R6)
	MOVB R7, [R5]
	AND R8, R7								; R8 vai ter o valor do botao do teclado_1
	CMP R8, 0								; se não estiver a 0, o botao esta carregado, vai saltar as proximas intruções
	JNZ espera_botao_livre_fim
	
	MOV R4, 0
	MOV R3, estado_botoes_teclado
	ADD R3, R6
	MOVB [R3], R4							; vai escrever 0 na tabela do estado do botao de indice R6
	JMP espera_botao_livre_fim
	
espera_botao_livre_2:
	MOV R9, TECLADO_2
	MOVB R8, [R9]
	MOV R5, mascaras
	ADD R5, R6								; R5 vai ser uma das mascaras indicadas na tabela mascaras, dependendo de R9
	MOVB R7, [R5]
	AND R8, R7								; R8 vai ter o valor do botao do teclado_2
	CMP R8, 0								; se estiver a 1, o botao esta carregado, vai saltar as proximas intruções
	JNZ espera_botao_premido_fim
	
	MOV R4, 0
	MOV R3, estado_botoes_teclado
	ADD R3, R6
	MOVB [R3], R4							; vai escrever 0 na tabela do estado do botao de indice R6
	
espera_botao_livre_fim:
	POP R9
	POP R8
	POP R7
	POP R5
	POP R4
	POP R3
	RET

; **************************************************************************************************************
; troca_cor_semaforo - Troca a cor de um dado semáforo (de SEM_VERDE para SEM_VERMELHO e vice-versa).
; **************************************************************************************************************
troca_cor_semaforo:
    PUSH R2
	PUSH R3
	
    CALL obtem_cor_semaforo       ; obtém cor do semáforo (em R2)

    CMP  R2, SEM_VERDE
    JZ   poe_vermelho             ; se o semáforo está a verde, põe a vermelho
	CMP R2, SEM_CINZENTO
	JZ poe_vermelho				  ; se o semáforo está a cinzento, põe a vermelho
	MOV R3, 8
	CMP R6, R3
	JZ poe_cinzento				  ; se o semáforo tiver índice 8, e estiver vermelho, vai por cinzento
	MOV R3, 9
	CMP R6, R3
	JZ poe_cinzento				  ; se o semáforo tiver índice 9, e estiver vermelho, vai por cinzento
     
poe_verde:
    MOV  R2, SEM_VERDE            ; semáforo vai ficar verde
    JMP  atualiza_cor
	
poe_cinzento:
	MOV R2, SEM_CINZENTO
	JMP  atualiza_cor			  ; semáforo vai ficar cinzento
     
poe_vermelho:
    MOV  R2, SEM_VERMELHO         ; semáforo vai ficar vermelho
     
atualiza_cor:
    CALL atualiza_cor_semaforo    ; atualiza cor do semáforo na tabela e na interface.
	POP R3								   
    POP R2
    RET
   
   
; **************************************************************************************************************
; obtem_cor_semaforo - Obtém a cor atual de um dado semáforo (por leitura da tabela de cores dos semáforos).
; **************************************************************************************************************
obtem_cor_semaforo:
    PUSH R10
	
    MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
    ADD  R10, R6                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
    MOVB R2, [R10]                ; lê a cor do semáforo
	
    POP R10                       
	RET
	
; **************************************************************************************************************
; atualiza_cor_semaforo - Atualiza a cor de um dado semáforo (quer na tabela de cores dos semáforos,
;                         quer no semáforo propriamente dito, na interface de visualização do módulo dos comboios).
; **************************************************************************************************************
atualiza_cor_semaforo:
    PUSH R6                       ; guarda valores dos registos na pilha
    PUSH R10
    PUSH R11
	
    MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
    ADD  R10, R6                  ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
    MOVB	[R10], R2             ; atualiza a cor do semáforo na tabela de cores dos semáforos

    SHL  R6, 2                    ; formato do porto dos semáforos (número do semáforo tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
    ADD  R6, R2                   ; junta cor do semáforo (que fica nos bits 1 e 0)
    MOV  R11, SEMAFOROS           ; endereço do porto dos semáforos no módulo dos comboios
    MOVB [R11], R6                ; atualiza cor no semaforo propriamente dito
	
    POP R11                       ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
    POP R10
    POP R6
	RET
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
; **************************************************************************************************************
; sensores_rot - Espera que o comboio passe por um sensor e nessa altura escreve o número do sensor nos LCD's.
; **************************************************************************************************************

sensores_rot:
    PUSH R1
    PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
    PUSH R9

	MOV R4, 1
	MOV R6, 0
	
espera_eventos:
	MOV	R9, SENSOR_EVENTOS
	MOVB R1, [R9]		          ; número de eventos de sensores ocorridos
	CMP	R1, 0
	JZ	sensores_fim			; se for zero, não há eventos ainda e pode sair

houve_evento:
	MOV	R9, SENSOR_INFO			  ; porto dos	sensores (informação)
	MOVB R1, [R9]		          ; lê 1º byte (informação sobre o comboio que passou) - ignora
	MOVB R2, [R9]		          ; lê 2º byte (número do sensor)
	SHR R1, 1
	CMP R1, 0
	JNZ le_sensor_2				  ; se o comboio que passou nao foi o primeiro, salta para le_sensor_2
	
	MOV R5, estado_sensores
	MOVB R3, [R5]
	CMP R3, 0					  ; se um dos lados do comboio ja passou pelo sensor, o sensor esta a reconhecer a outra parte do comboio e nao escreve no LCD
	JNZ sensor_1
	JMP escreve_numero_sensor_1	  ; senao, vai escrever o numero do sensor no LCD de cima
	
sensor_1:
	MOVB [R5], R6				; escreve 0 na tabela estado_sensores, uma das partes do comboio já passou pelo sensor
	JMP sensores_fim
	
le_sensor_2:
	MOV R5, estado_sensores
	ADD R5, 1
	MOVB R3, [R5]
	CMP R3, 0					; se uma das partes do comboio ja passou pelo sensor,
	JNZ sensor_2				; o sensor esta a reconhecer a outra parte do comboio e nao escreve no LCD
	JMP escreve_numero_sensor_2
	
sensor_2:
	MOVB [R5], R6				; escreve 0 na tabela estado_sensores, porque a parte de tras do comboio já passou pelo sensor
	JMP sensores_fim

escreve_numero_sensor_1:
    MOV R1, 30H                  ; '0'
    ADD R2, R1                   ; converte número do sensor (0 a 9) para caracter numérico ('0' a '9')
	MOV	R9, LCD_CIMA		     ; porto da linha de cima do LCD
	MOVB [R9], R2                ; escreve número do sensor no LCD de cima
	MOVB [R5], R4				 ; escreve 1 na tabela estado_sensores, vai esperar que a parte de tras do comboios
								 ; passe pelo sensor, para por o valor da tabela a 0
	JMP sensores_fim
	
escreve_numero_sensor_2:
    MOV  R1, 30H                  ; '0'
    ADD  R2, R1                   ; converte número do sensor (0 a 9) para caracter numérico ('0' a '9')
	MOV	R9, LCD_BAIXO		      ; porto da linha de baixo do LCD
	MOVB [R9], R2                 ; escreve número do sensor no LCD de baixo
	MOVB [R5], R4				  ; escreve 1 na tabela estado_sensores, vai esperar que a parte de tras do comboios
								 ; passe pelo sensor, para por o valor da tabela a 0
sensores_fim:
    POP R9
	POP R6
	POP R5
	POP R4
	POP R3
    POP R2
    POP R1
    RET	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
; **************************************************************************************************************
; agulhas_rot - atualiza o estado das agulhas
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

	
	
	
	
	


