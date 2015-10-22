; *********************************************************************
; *			Projeto de Introdução à Arquitetura de Computadores		  *
; *																	  *
; *																	  *
; * Modulo:    projeto_codigo.asm									  *
; *	Membros: - Gonçalo Marques ()                                     *
; *			 - Manuel Sousa ()                                        *
; *			 - Tiago Novais ()									      *				
; *																	  *
; *																	  *
; *********************************************************************

; *********************************************************************
; *                       C O N S T A N T E S                         *                
; *********************************************************************




; *********************************************************************
; *                           C Ó D I G O                             *                
; *********************************************************************


PLACE		0000H               ; localiza código a partir do endereço 0000H (onde o PEPE começa a executar após reset)
inicio:

; acesso à memória, em modo word (16 bits) e em modo byte (8 bits)
     MOV	R1, VALOR_16_BITS	     ; inicializa valor a escrever
     MOV	R9, END_ACESSO_16	     ; endereço (necessariamente par) a ser acedido em modo word (16 bits)
     MOV	[R9], R1	               ; acesso (MOV) à RAM em 16 bits

     MOV	R9, END_ACESSO_8_PAR     ; endereço (par) a ser acedido em modo byte (8 bits)
     MOVB	[R9], R1	               ; acesso (MOVB) à RAM em 8 bits (só o byte de menor peso do R1)

     MOV	R9, END_ACESSO_8_IMPAR   ; endereço (impar) a ser acedido em modo byte (8 bits)
     MOVB	[R9], R1	               ; acesso (MOVB) à RAM em 8 bits (só o byte de menor peso do R1)

; acesso ao periférico (só em modo byte, pois o periférico é de 8 bits)
     MOV	R9, LCD_CIMA             ; endereço do porto 00H do módulo dos comboios (linha de cima do LCD)
     MOV	R1, CARACTER_A           ; caracter 'A' em ASCII
     MOVB	[R9], R1                 ; escreve carácter no LCD

     MOV	R9, LCD_BAIXO            ; endereço do porto 01H do módulo dos comboios (linha de baixo do LCD)
     MOV	R1, CARACTER_D           ; caracter 'D' em ASCII
     MOVB	[R9], R1                 ; escreve carácter no LCD

     MOV	R9, AGULHAS              ; endereço do porto 0BH do módulo dos comboios (agulhas)
     MOV	R1, AGULHA_2_ESQ         ; agulha 2 para a esquerda
     MOVB	[R9], R1                 ; muda estado da agulha

     MOV	R9, SEMAFOROS            ; endereço do porto 09H do módulo dos comboios (semáforos)
     MOV	R1, SEM_5_VERMELHO       ; semáforo 5 a vermelho
     MOVB	[R9], R1                 ; muda estado do semáforo

fim: JMP  fim                      ; "termina" o programa
