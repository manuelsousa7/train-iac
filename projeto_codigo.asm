; **********************************************************************
; *		Projeto de Introdução à Arquitetura de Computadores	      *
; *													      *
; *										  			      *
; * Modulo:    projeto_codigo.asm						     	 *
; *	Membros: - Gonçalo Marques (84719)                                     *
; *			 - Manuel Sousa (84740)                                      *
; *			 - Tiago Novais (84888)					      	      *
; *									        				 *
; *													      *
; **********************************************************************

; *********************************************************************
; *                       C O N S T A N T E S                         *             
; *********************************************************************




; *********************************************************************
; *                           C Ó D I G O                             *             
; *********************************************************************

; endereços dos portos do módulo dos comboios (apenas os usados)
BOTOES_PRESSAO	     EQU  800CH	; endereço dos botões de pressão		
SEMAFOROS 	     EQU  8012H	; endereço dos semáforos		

SEM_VERDE           EQU  2         ; cor dos semáforos (verde)
SEM_VERMELHO        EQU  1         ; cor dos semáforos (vermelho)
SEM_CINZENTO        EQU  0         ; cor dos semáforos (cinzento)

; **********************************************************************
; * Dados (variáveis)
; **********************************************************************

PLACE     1000H

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



; **********************************************************************
; * Código
; **********************************************************************

PLACE		0000H
inicio:

     MOV	R9, BOTOES_PRESSAO       ; endereço do porto dos botões de pressão

le_botoes:
     MOVB	R1, [R9]                 ; lê o estado dos botões (modo byte, pois o periférico é de 8 bits)
     BIT  R1, 5                    ; testa o botão de pressão 5
     JZ   le_botoes                ; se o bit está a zero, o botão não está carregado e continua a ler os botões

botao_carregado:
     MOV  R10, cores_semaforos     ; endereço da tabela das cores dos vários semáforos
     MOV  R3, 5                    ; número do semáforo com que se quer trabalhar (5)
     ADD  R10, R3                  ; obtém endereço do byte de cor do semáforo (soma 5 à base da tabela)
     MOVB	R2, [R10]                ; lê a cor do semáforo (modo byte, pois a tabela de cores dos semáforos foi definida com STRING)
     CMP  R2, SEM_VERDE
     JZ   poe_vermelho             ; se o semáforo está a verde, põe a vermelho, caso contrário põe a verde
     
poe_verde:
     MOV  R4, SEM_VERDE            ; semáforo via ficar verde
     JMP  atualiza_cor
     
poe_vermelho:
     MOV  R4, SEM_VERMELHO         ; semáforo via ficar vermelho
     
atualiza_cor:
     MOVB [R10], R4                ; atualiza cor do semáforo na tabela (modo byte)

atualiza_semaforo:
     SHL  R3, 2                    ; formato do porto dos semáforos (número do semáforo tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
     ADD  R3, R4                   ; junta cor do semáforo (que fica nos bits 1 e 0)
     MOV  R11, SEMAFOROS           ; endereço do porto dos semáforos no módulo dos comboios
     MOVB [R11], R3                ; atualiza cor no semaforo propriamente dito (modo byte)

bascula:
	 MOVB R1,[R9]
	 BIT R1, 5
	 JNZ bascula
     JMP  le_botoes                ; vai novamente ler os botões
