;Esse é um programa de um cofre, o cofre possui uma senha de quatro dígitos.
;Essa senha deve ser definida ao iniciar o funcionamento do código.
;Existem cinco opções de algarismos para essa senha, esses cinco dígitos estão 
;dispostos em cinco botões:
;PTC0 é o algarismo 0,
;PTA1 é o algarismo 1,
;PTA2 é o algarismo 2,
;PTA3 é o algarismo 3,
;PTA6 é o algarismo 4.
;Ao definir uma senha, o programa aguardará que outra senha seja comparada com a 
;definida anteriormente. Cada dígito é comparado, então tanto o algarismo quanto
;a ordem que foi utilizado deve ser a mesma.
;Caso o usuário acerte, o LED verde irá piscar, depois o cofre pode ser fechado 
;pressionando o botão PTD6, e o programa aguardará outro teste.
;Caso o usuário erre, o LED vermelho acenderá, se o usuário errar três vezes consecutivas
;o programa irá ser bloqueado, piscando os LEDs verde e vermelho de forma alternada e 
;acionando o BUZZER de forma intermitente. E o programa deverá ser resetado pelo
;botão da placa.


	INCLUDE 'derivative.inc'

	ORG $0080

;Variáveis utilizadas no programa

N_ERROS: DS.B 1; Conta quantas vezes já errou ao longo do programa

MAXIMO_ERRO: DS.B 1; 3x foi escolhido como número máximo de erros consecutivos

tempo: DS.B 1; Contagem de tempo interna

COMEMORA: DS.B 1; Definição de por quanto tempo a "comemoração" ao acertar deve durar

QUANTAS_COMEMOROU: DS.B 1; Por quanto tempo já está comemorando

DIGITO_1_OFICIAL: DS.B 1; Dígito 1 da senha escolhida

DIGITO_2_OFICIAL: DS.B 1; Dígito 2 da senha escolhida

DIGITO_3_OFICIAL: DS.B 1; Dígito 3 da senha escolhida

DIGITO_4_OFICIAL: DS.B 1; Dígito 4 da senha escolhida

DIGITO_1_TESTE: DS.B 1; Dígito 1 da senha testada

DIGITO_2_TESTE: DS.B 1; Dígito 2 da senha testada

DIGITO_3_TESTE: DS.B 1; Dígito 3 da senha testada

DIGITO_4_TESTE: DS.B 1; Dígito 4 da senha testada

ERROU_D: DS.B 1; Quando um dígito está errado, a variável é incrementada

    ORG $C000

   
INICIO:

   	LDA SOPT1
	AND #127
	STA SOPT1; Desabilitar o COP
    
; Configuração das entradas e saídas digitais
	MOV #%10000000,PTADD	; Configuração do PTAD, apenas uma saída digital
					;BUZZERno PTA7
	MOV #%00001100,PTBDD    ;Configuração do PTBD, duas saídas digitais:
            ;no PTB3 - LED verde e no PTB2 - LED vermelho 
	MOV #%00101110,PTCDD    ;Configuração do PTCD , quatro saídas digitais:
            ;PTC1, PTC2, PTC3 e PTC5 com LEDs Branco
	MOV #0, PTDDD		; Configuração do PTDD, não possui saídas digitais 


; Zerar as saídas digitais
	MOV #$00,PTAD		; Zera saídas do PTAD (BUZZER)
	MOV #$00,PTCD		; Zera saídas do PTCD (LEDS brancos)
	MOV #$00,PTBD		;Zera saídas do PTBD (LED vermelho e LED verde)
    
;Valores iniciais para as variáveis

	MOV #$00,N_ERROS	;Variável incrementada ao errar a senha
	MOV #03,MAXIMO_ERRO	;Número máximo de erros consecutivos
	MOV #0,tempo		;Zera o valor do tempo
	MOV #7,COMEMORA	;A comemoração ao acertar irá durar 7 repetições
MOV #0,ERROU_D		;Flag que é incrementada caso as variáveis da senha				;oficial não correspondam com os respectivos da  
;variável testada
	MOV #0,QUANTAS_COMEMOROU; Conta quantas vezes já comemorou
;Abaixo todos os dígitos das senhas oficiais e das testadas são zerados e serão 
;incrementados no decorrer do algoritmo	
MOV #0,DIGITO_1_OFICIAL
	MOV #0,DIGITO_2_OFICIAL
	MOV #0,DIGITO_3_OFICIAL
	MOV #0,DIGITO_4_OFICIAL
	MOV #0,DIGITO_1_TESTE
	MOV #0,DIGITO_2_TESTE
	MOV #0,DIGITO_3_TESTE
	MOV #0,DIGITO_4_TESTE

	 
	 
; PULL UP das entradas digitais

	LDA PTAPE				;PULL UP
	ORA #%01001110			;nas portas: PTA1, PTA2, PTA3 e PTA6
	STA PTAPE				;São portas que contêm botões
    
    
	LDA PTCPE				;PULL UP 
	ORA #$01				;Apenas na porta PTC0
	STA PTCPE				;Contém um botão
 
	LDA PTDPE				;PULL UP 
	ORA #%01000000			;Na porta PTD6
	STA PTDPE   				;Contém um botão


 ;Configuração da interrupção em tempo real, é utilizada como timmer
 
	LDA #$1F 			;Clock interno, 1 segundo
	STA RTCSC			;Clock externo, interrupção habilitada a cada 1s
	CLI				;Habilita todas as interrupções


;A partir desse ponto, inicia-se a criação da senha oficial

CRIAR1:				;Sub-rotina para criar o primeiro dígito da senha

DIGITO_1_REAL:
	BRSET 0,PTAD,NAO_FAZ1		;Sub-rotina que foi utilizada para resolução 
;de um Bug que estava ocorrendo. 

	BRCLR 0,PTCD,DIGITO_1_OFICIAL_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_1_OFICIAL_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_1_OFICIAL_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_1_OFICIAL_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_1_OFICIAL_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina
	BRA DIGITO_1_REAL			;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado

NAO_FAZ1:  						;Rotina que apenas retorna sem realizar
JMP DIGITO_1_REAL 			;nenhuma ação
  			

;--------------------------DÍGITO 1 DA SENHA REAL É 0: ------------------------------------------
DIGITO_1_OFICIAL_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
	BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 0,DIGITO_1_OFICIAL			;A variável do dígito 1 da senha oficial
							;tem seu bit 0 setado.
FICA1:							;É necessário manter-se nesta sub
    	BRCLR 0,PTCD, FICA1			;Até que o botão seja solto, daí
	JMP CRIAR2					;pula para criação do segundo dígito

;--------------------------DÍGITO 1 DA SENHA REAL É 1: ------------------------------------------

DIGITO_1_OFICIAL_02:				;Quando o PTA1 for pressionado,
							;o valor  escolhido para o dígito é 1
	BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 1,DIGITO_1_OFICIAL			;A variável do dígito 1 da senha oficial
							;tem seu bit 1 setado.
FICA2:							;É necessário manter-se nesta sub
  	 BRCLR 1,PTAD, FICA2			;Até que o botão seja solto, daí
	JMP CRIAR2					;pula para criação do segundo dígito

;--------------------------DÍGITO 1 DA SENHA REAL É 2: ------------------------------------------

DIGITO_1_OFICIAL_04:				;Quando o PTA2 for pressionado,
							;o valor  escolhido para o dígito é  2
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 2,DIGITO_1_OFICIAL			;A variável do dígito 1 da senha oficial
							;tem seu bit 2 setado.
FICA3:							;É necessário manter-se nesta sub
    	BRCLR 2,PTAD, FICA3			;Até que o botão seja solto, daí
	JMP CRIAR2					;pula para criação do segundo dígito

;--------------------------DÍGITO 1 DA SENHA REAL É 3: ------------------------------------------


DIGITO_1_OFICIAL_08:				;Quando o PTA3 for pressionado
							;o valor  escolhido para o dígito é 3
	BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 3,DIGITO_1_OFICIAL			;A variável do dígito 1 da senha oficial
							;tem seu bit 3 setado.
FICA4:							;É necessário manter-se nesta sub	 
BRCLR 3,PTAD, FICA4			;Até que o botão seja solto, daí
JMP CRIAR2   				;pula para criação do segundo dígito

;--------------------------DÍGITO 1 DA SENHA REAL É 4: ------------------------------------------

DIGITO_1_OFICIAL_16:				;Quando o PTA6 for pressionado
							;o valor  escolhido para o dígito é 4

	BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 4,DIGITO_1_OFICIAL			;A variável do dígito 1 da senha oficial
							;tem seu bit 4 setado.
FICA5:							;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA5			;Até que o botão seja solto, daí
JMP CRIAR2   				;Pula para criação do segundo dígito


;Para o código chegar aqui, o primeiro dígito obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do segundo dígito, é muito parecido com o primeiro
;muda apenas a que é alterada    

CRIAR2:				;Sub-rotina para criar o segundo dígito da senha

DIGITO_2_REAL:
  	BRSET 0,PTAD,NAO_FAZ2		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo. 

BRCLR 0,PTCD,DIGITO_2_OFICIAL_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_2_OFICIAL_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_2_OFICIAL_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_2_OFICIAL_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_2_OFICIAL_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina
	BRA DIGITO_1_REAL			;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado
   
NAO_FAZ2:  						;Rotina que apenas retorna sem realizar
JMP DIGITO_2_REAL 			;nenhuma ação

;--------------------------DÍGITO 2 DA SENHA REAL É 0: ------------------------------------------  
DIGITO_2_OFICIAL_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 0,DIGITO_2_OFICIAL			;A variável do dígito 2 da senha oficial
							;tem seu bit 0 setado
FICA6:							;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA6			;Até que o botão seja solto, daí
	JMP CRIAR3					;pula para criação do terceiro dígito

;--------------------------DÍGITO 2 DA SENHA REAL É 1: ------------------------------------------ 

DIGITO_2_OFICIAL_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
	BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 1,DIGITO_2_OFICIAL			;A variável do dígito 2 da senha oficial
							;tem seu bit 1 setado
FICA7:							;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA7			;Até que o botão seja solto, daí
	JMP CRIAR3					;pula para criação do terceiro dígito

;--------------------------DÍGITO 2 DA SENHA REAL É 2: ------------------------------------------ 

DIGITO_2_OFICIAL_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 2,DIGITO_2_OFICIAL			;A variável do dígito 2 da senha oficial
							;tem seu bit 2 setado
FICA8:							;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA8			;Até que o botão seja solto, daí
	JMP CRIAR3					;pula para criação do terceiro dígito

;--------------------------DÍGITO 2 DA SENHA REAL É 3: ------------------------------------------ 

DIGITO_2_OFICIAL_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 3,DIGITO_2_OFICIAL			;A variável do dígito 2 da senha oficial
							;tem seu bit 3 setado
FICA9:							;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA9			;Até que o botão seja solto, daí
	JMP CRIAR3					;pula para criação do terceiro dígito

;--------------------------DÍGITO 2 DA SENHA REAL É 4: ------------------------------------------ 

DIGITO_2_OFICIAL_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
BSET 4,DIGITO_2_OFICIAL			;A variável do dígito 2 da senha oficial
							;tem seu bit 4 setado
FICA10:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA10			;Até que o botão seja solto, daí
	JMP CRIAR3					;pula para criação do terceiro dígito

;Para o código chegar aqui, o segundo dígito obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do terceiro dígito

CRIAR3:				;Sub-rotina para criar o terceiro dígito da senha

DIGITO_3_REAL:
	BRSET 0,PTAD,NAO_FAZ3		;Sub-rotina que foi utilizada para resolução 
;de um Bug que estava ocorrendo. 
	BRCLR 0,PTCD,DIGITO_3_OFICIAL_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_3_OFICIAL_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_3_OFICIAL_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina
	BRCLR 3,PTAD,DIGITO_3_OFICIAL_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_3_OFICIAL_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina
	JMP CRIAR3					;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado

NAO_FAZ3:						;Rotina que apenas retorna sem realizar
JMP DIGITO_3_REAL 			;nenhuma ação

;--------------------------DÍGITO 3 DA SENHA REAL É 0: ------------------------------------------ 

DIGITO_3_OFICIAL_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
BSET 0,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha oficial
							;tem seu bit 0 setado.
FICA11:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA11			;Até que o botão seja solto, daí
	JMP CRIAR4					;pula para criação do quarto dígito

;--------------------------DÍGITO 3 DA SENHA REAL É 1: ------------------------------------------ 

DIGITO_3_OFICIAL_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
BSET 1,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha oficial
							;tem seu bit 1 setado.
FICA12:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA12			;Até que o botão seja solto, daí
	JMP CRIAR4					;pula para criação do quarto dígito

;--------------------------DÍGITO 3 DA SENHA REAL É 2: ------------------------------------------

DIGITO_3_OFICIAL_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 2,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha oficial
							;tem seu bit 2 setado.
FICA13:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA13			;Até que o botão seja solto, daí
	JMP CRIAR4					;pula para criação do quarto dígito

;--------------------------DÍGITO 3 DA SENHA REAL É 3: ------------------------------------------
	
DIGITO_3_OFICIAL_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 3,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha oficial
							;tem seu bit 3 setado.
FICA14:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA14			;Até que o botão seja solto, daí
	JMP CRIAR4					;pula para criação do quarto dígito

;--------------------------DÍGITO 3 DA SENHA REAL É 4: ------------------------------------------

DIGITO_3_OFICIAL_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 4,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha oficial
							;tem seu bit 4 setado.
FICA15:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA15			;Até que o botão seja solto, daí
	JMP CRIAR4					;pula para criação do quarto dígito

;Para o código chegar aqui, o terceiro dígito obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do quarto e último dígito
    
CRIAR4:				;Sub-rotina para criar o quarto dígito da senha

DIGITO_4_REAL:
	BRSET 0,PTAD,NAO_FAZ4		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo.
	BRCLR 0,PTCD,DIGITO_4_OFICIAL_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_4_OFICIAL_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_4_OFICIAL_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_4_OFICIAL_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_4_OFICIAL_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina
	JMP CRIAR4					;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado    
NAO_FAZ4:						;Rotina que apenas retorna sem realizar
JMP DIGITO_4_REAL			;nenhuma ação



;--------------------------DÍGITO 4 DA SENHA REAL É 0: ------------------------------------------ 

DIGITO_4_OFICIAL_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 0,DIGITO_4_OFICIAL			;A variável do dígito 4 da senha oficial
							;tem seu bit 0 setado.
FICA16:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA16			;Até que o botão seja solto, daí
	JMP PARTE2					;pula para a segunda parte do código

;--------------------------DÍGITO 4 DA SENHA REAL É 1: ------------------------------------------ 
    
DIGITO_4_OFICIAL_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 1,DIGITO_4_OFICIAL			;A variável do dígito 4 da senha oficial
							;tem seu bit 1 setado.
FICA17:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA17			;Até que o botão seja solto, daí
	JMP PARTE2					;pula para a segunda parte do código

;--------------------------DÍGITO 4 DA SENHA REAL É 2: ------------------------------------------ 
 
DIGITO_4_OFICIAL_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 2,DIGITO_4_OFICIAL			;A variável do dígito 4 da senha oficial
							;tem seu bit 2 setado.
FICA18:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA18			;Até que o botão seja solto, daí
	JMP PARTE2					;pula para a segunda parte do código

;--------------------------DÍGITO 4 DA SENHA REAL É 3: ------------------------------------------ 

DIGITO_4_OFICIAL_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 3,DIGITO_4_OFICIAL			;A variável do dígito 4 da senha oficial
							;tem seu bit 3 setado.
FICA19:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA19			;Até que o botão seja solto, daí
	JMP PARTE2					;pula para a segunda parte do código

;--------------------------DÍGITO 4 DA SENHA REAL É 4: ------------------------------------------ 

DIGITO_4_OFICIAL_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 4,DIGITO_4_OFICIAL			;A variável do dígito 4 da senha oficial
							;tem seu bit 4 setado.
FICA20:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA20			;Até que o botão seja solto, daí
	JMP PARTE2					;pula para a segunda parte do código

 ;---------------------------------------PARTE 2 DO CÓDIGO----------------------------------------------
 ;Nesse momento, já foi criado uma senha oficial que vai ser a mesma até que a placa
;seja resetada. Então o próximo passo é aguardar senhas serem testadas e comparar
;com a senha real e realizar ações a partir do resultado dessa comparação.

PARTE2:
;É necessário zerar todas as variáveis que são os dígitos da senha, apagar os leds e 
;zerar a variável que conta se algum dígito foi errado

	MOV #0,DIGITO_1_TESTE
	MOV #0,DIGITO_2_TESTE
	MOV #0,DIGITO_3_TESTE
	MOV #0,DIGITO_4_TESTE
	MOV #0,PTCD
	MOV #0,PTBD
	MOV #0,ERROU_D

;As rotinas a seguir funcionam do mesmo modo que as rotinas de criação da senha

TESTE1:				;Sub-rotina para criar o primeiro dígito da senha teste

DIGITO_1_TESTAR:
	BRSET 0,PTAD,NAO_FAZ5		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo.
	BRCLR 0,PTCD,DIGITO_1_TESTE_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_1_TESTE_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_1_TESTE_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_1_TESTE_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_1_TESTE_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina.
	BRA DIGITO_1_TESTAR			;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado    
NAO_FAZ5: 						;Rotina que apenas retorna sem realizar
JMP DIGITO_1_TESTAR			;nenhuma ação

;--------------------------DÍGITO 1 DA SENHA TESTE É 0: ------------------------------------------ 

DIGITO_1_TESTE_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 0,DIGITO_1_TESTE			;A variável do dígito 1 da senha teste
							;tem seu bit 0 setado.
FICA21:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA21			;Até que o botão seja solto, daí
	JMP TESTE2					;pula para a criação do segundo dígito 
;de teste

;--------------------------DÍGITO 1 DA SENHA TESTE É 1: ------------------------------------------ 

DIGITO_1_TESTE_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 1,DIGITO_1_TESTE			;A variável do dígito 1 da senha teste
							;tem seu bit 1 setado.
FICA22:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA22			;Até que o botão seja solto, daí
	JMP TESTE2					;pula para a criação do segundo dígito 
;de teste

;--------------------------DÍGITO 1 DA SENHA TESTE É 2: ------------------------------------------ 

DIGITO_1_TESTE_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 2,DIGITO_1_TESTE			;A variável do dígito 1 da senha teste
							;tem seu bit 2 setado.
FICA23:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA23			;Até que o botão seja solto, daí
	JMP TESTE2					;pula para a criação do segundo dígito 
;de teste

;--------------------------DÍGITO 1 DA SENHA TESTE É 3: ------------------------------------------ 

DIGITO_1_TESTE_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 3,DIGITO_1_TESTE			;A variável do dígito 1 da senha teste
							;tem seu bit 3 setado.
FICA24:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA24			;Até que o botão seja solto, daí
	JMP TESTE2					;pula para a criação do segundo dígito 
;de teste


;--------------------------DÍGITO 1 DA SENHA TESTE É 4: ------------------------------------------ 

DIGITO_1_TESTE_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 1, PTCD				;LED branco 1 é aceso para simbolizar
							;que o primeiro dígito foi escolhido
	BSET 4,DIGITO_1_TESTE			;A variável do dígito 1 da senha teste
							;tem seu bit 4 setado.
FICA25:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA25			;Até que o botão seja solto, daí
	JMP TESTE2					;pula para a criação do segundo dígito 
;de teste

;Para o código chegar aqui, o primeiro dígito teste obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do segundo dígito de teste
	
TESTE2:				;Sub-rotina para criar o segundo dígito da senha teste

DIGITO_2_TESTAR:
BRSET 0,PTAD,NAO_FAZ6		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo. 
 	BRCLR 0,PTCD,DIGITO_2_TESTE_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
BRCLR 1,PTAD,DIGITO_2_TESTE_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
BRCLR 2,PTAD,DIGITO_2_TESTE_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
BRCLR 3,PTAD,DIGITO_2_TESTE_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
BRCLR 6,PTAD,DIGITO_2_TESTE_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina
JMP DIGITO_2_TESTAR			;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado

NAO_FAZ6:    						;Rotina que apenas retorna sem realizar 
JMP DIGITO_2_TESTAR 			;nenhuma ação
    
;--------------------------DÍGITO 2 DA SENHA TESTE É 0: ------------------------------------------ 

DIGITO_2_TESTE_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 0,DIGITO_2_TESTE			;A variável do dígito 2 da senha teste
							;tem seu bit 0 setado.
FICA26:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA26			;Até que o botão seja solto, daí
	JMP TESTE3					;pula para a criação do terceiro dígito 
;de teste

;--------------------------DÍGITO 2 DA SENHA TESTE É 1: ------------------------------------------ 

DIGITO_2_TESTE_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 1,DIGITO_2_TESTE			;A variável do dígito 2 da senha teste
							;tem seu bit 1 setado.
FICA27:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA27			;Até que o botão seja solto, daí
	JMP TESTE3					;pula para a criação do terceiro dígito 
;de teste

;--------------------------DÍGITO 2 DA SENHA TESTE É 2: ------------------------------------------ 

DIGITO_2_TESTE_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 2,DIGITO_2_TESTE			;A variável do dígito 2 da senha teste
							;tem seu bit 2 setado.
FICA28:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA28			;Até que o botão seja solto, daí
	JMP TESTE3					;pula para a criação do terceiro dígito 
;de teste

  ;--------------------------DÍGITO 2 DA SENHA TESTE É 3: ------------------------------------------ 
  
DIGITO_2_TESTE_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 3,DIGITO_2_TESTE			;A variável do dígito 2 da senha teste
							;tem seu bit 2 setado.
FICA29:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA29			;Até que o botão seja solto, daí
	JMP TESTE3					;pula para a criação do terceiro dígito 
;de teste

  ;--------------------------DÍGITO 2 DA SENHA TESTE É 4: ------------------------------------------ 
  
DIGITO_2_TESTE_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 2, PTCD				;LED branco 2 é aceso para simbolizar
							;que o segundo dígito foi escolhido
	BSET 4,DIGITO_2_TESTE			;A variável do dígito 2 da senha teste
							;tem seu bit 2 setado.
FICA30:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA30			;Até que o botão seja solto, daí
	JMP TESTE3					;pula para a criação do terceiro dígito 
;de teste


;Para o código chegar aqui, o segundo dígito teste obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do terceiro dígito de teste

TESTE3:
DIGITO_3_TESTAR:
	BRSET 0,PTAD,NAO_FAZ7		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo.
	BRCLR 0,PTCD,DIGITO_3_TESTE_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_3_TESTE_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_3_TESTE_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_3_TESTE_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_3_TESTE_16	;Caso o PTA6 for pressionado o código 
							;pulará para essa sub-rotina.
	JMP DIGITO_3_TESTAR			;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado

NAO_FAZ7:						;Rotina que apenas retorna sem realizar 
JMP DIGITO_3_TESTAR			;nenhuma ação

;--------------------------DÍGITO 3 DA SENHA TESTE É 0: ------------------------------------------ 

DIGITO_3_TESTE_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 0,DIGITO_3_TESTE			;A variável do dígito 3 da senha teste
							;tem seu bit 0 setado.
FICA31:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA31			;Até que o botão seja solto, daí
	JMP TESTE4					;pula para a criação do quarto dígito 
;de teste
 
;--------------------------DÍGITO 3 DA SENHA TESTE É 1: ------------------------------------------ 

DIGITO_3_TESTE_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 1,DIGITO_3_OFICIAL			;A variável do dígito 3 da senha teste
							;tem seu bit 1 setado.
FICA32:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA32			;Até que o botão seja solto, daí
	JMP TESTE4					;pula para a criação do quarto dígito 
;de teste
 
;--------------------------DÍGITO 3 DA SENHA TESTE É 2: ------------------------------------------ 

DIGITO_3_TESTE_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 2,DIGITO_3_TESTE			;A variável do dígito 3 da senha teste
							;tem seu bit 2 setado.
FICA33:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA33			;Até que o botão seja solto, daí
	JMP TESTE4					;pula para a criação do quarto dígito 
;de teste
 
;--------------------------DÍGITO 3 DA SENHA TESTE É 3: ------------------------------------------ 

DIGITO_3_TESTE_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 3,DIGITO_3_TESTE			;A variável do dígito 3 da senha teste
							;tem seu bit 3 setado.
FICA34:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA34			;Até que o botão seja solto, daí
	JMP TESTE4					;pula para a criação do quarto dígito 
;de teste
 
;--------------------------DÍGITO 3 DA SENHA TESTE É 4: ------------------------------------------ 

DIGITO_3_TESTE_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 3, PTCD				;LED branco 3 é aceso para simbolizar
							;que o terceiro dígito foi escolhido
	BSET 4,DIGITO_3_TESTE			;A variável do dígito 3 da senha teste
							;tem seu bit 3 setado.
FICA35:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA35			;Até que o botão seja solto, daí
	JMP TESTE4					;pula para a criação do quarto dígito 
;de teste

;Para o código chegar aqui, o terceiro dígito teste obrigatoriamente já foi escolhido
;Logo inicia-se o processo de escolha do quarto e último dígito de teste

TESTE4:				;Sub-rotina para criar o quarto dígito da senha teste

DIGITO_4_TESTAR:
	 BRSET 0,PTAD,NAO_FAZ8		;Sub-rotina que foi utilizada para 
;resolução de um Bug que estava ocorrendo. 
	BRCLR 0,PTCD,DIGITO_4_TESTE_01	;Caso o PTC0 for pressionado o código
;pulará para essa sub-rotina.
	BRCLR 1,PTAD,DIGITO_4_TESTE_02	;Caso PTA1 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 2,PTAD,DIGITO_4_TESTE_04	;Caso o PTA2 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 3,PTAD,DIGITO_4_TESTE_08	;Caso o PTA3 for pressionado o código 
							;pulará para essa sub-rotina.
	BRCLR 6,PTAD,DIGITO_4_TESTE_16	;Caso o PTA6 for pressionado o código 							;pulará para essa sub-rotina
	JMP TESTE4					;Se nenhum botão for pressionado
							;o código voltará para o início dessa 
							;sub-rotina e só sairá quando um botão
							;for acionado

NAO_FAZ8:      					;Rotina que apenas retorna sem realizar 
JMP DIGITO_4_TESTAR 			;nenhuma ação

;--------------------------DÍGITO 4 DA SENHA TESTE É 0: ------------------------------------------ 

DIGITO_4_TESTE_01:				;Quando o PTC0 for pressionado,
				;o valor  escolhido para o dígito é 0
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 0,DIGITO_4_TESTE			;A variável do dígito 4 da senha teste
							;tem seu bit 0 setado.
FICA36:						;É necessário manter-se nesta sub
BRCLR 0,PTCD, FICA36			;Até que o botão seja solto, daí
	JMP COMPARAR				;pula para sub de comparar senhas

    
;--------------------------DÍGITO 4 DA SENHA TESTE É 1: ------------------------------------------ 

DIGITO_4_TESTE_02:				;Quando o PTA1 for pressionado,
				;o valor  escolhido para o dígito é 1
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 1,DIGITO_4_TESTE			;A variável do dígito 4 da senha teste
							;tem seu bit 1 setado
FICA37:						;É necessário manter-se nesta sub
BRCLR 1,PTAD, FICA37			;Até que o botão seja solto, daí
	JMP COMPARAR				;pula para sub de comparar senhas

    
;--------------------------DÍGITO 4 DA SENHA TESTE É 2: ------------------------------------------ 

DIGITO_4_TESTE_04:				;Quando o PTA2 for pressionado,
				;o valor  escolhido para o dígito é 2
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 2,DIGITO_4_TESTE			;A variável do dígito 4 da senha teste
							;tem seu bit 2 setado
FICA38:						;É necessário manter-se nesta sub
BRCLR 2,PTAD, FICA38			;Até que o botão seja solto, daí
	JMP COMPARAR				;pula para sub de comparar senhas

    ;--------------------------DÍGITO 4 DA SENHA TESTE É 3: ------------------------------------------ 

DIGITO_4_TESTE_08:				;Quando o PTA3 for pressionado,
				;o valor  escolhido para o dígito é 3
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
	BSET 3,DIGITO_4_TESTE			;A variável do dígito 4 da senha teste
							;tem seu bit 3 setado
FICA39:						;É necessário manter-se nesta sub
BRCLR 3,PTAD, FICA39			;Até que o botão seja solto, daí
	JMP COMPARAR				;pula para sub de comparar senhas

;--------------------------DÍGITO 4 DA SENHA TESTE É 4: ------------------------------------------ 

DIGITO_4_TESTE_16:				;Quando o PTA6 for pressionado,
				;o valor  escolhido para o dígito é 4
BSET 5, PTCD				;LED branco 4 é aceso para simbolizar
							;que o quarto dígito foi escolhido
 	BSET 4,DIGITO_4_TESTE			;A variável do dígito 4 da senha teste
							;tem seu bit 3 setado
FICA40:						;É necessário manter-se nesta sub
BRCLR 6,PTAD, FICA40			;Até que o botão seja solto, daí
	JMP COMPARAR				;pula para sub de comparar senhas

;-------------------------------------COMPARAR AS SENHAS--------------------------------------------
;Ao chegar nessa rotina, já se tem todos os dígitos da senha oficial da da senha teste
;Resta comparar dígito a dígito e ver se está correto.

COMPARAR:
 
 COMPARA_1:				;Sub rotina que compara os primeiros dígitos
	LDA DIGITO_1_OFICIAL		;Carrega valor do dígito 1 oficial
	CMP DIGITO_1_TESTE		;Compara com o dígito 1 de teste
	BNE ERROU_DIGITO1; 		;Se não for igual, desvia

COMPARA_2:				;Sub rotina que compara os segundos dígitos

	LDA DIGITO_2_OFICIAL		;Carrega valor do dígito 2 oficial
	CMP DIGITO_2_TESTE		;Compara com o dígito 2 de teste
	BNE ERROU_DIGITO2		;Se não for igual, desvia

COMPARA_3:
	LDA DIGITO_3_OFICIAL		;Carrega valor do dígito 3 oficial
	CMP DIGITO_3_TESTE		;Compara com o dígito 3 de teste
	BNE ERROU_DIGITO3		;Se não for igual, desvia
    
COMPARA_4:
	LDA DIGITO_4_OFICIAL		;Carrega valor do dígito 4 oficial
	CMP DIGITO_4_TESTE		;Compara com o dígito 4 de teste
	BNE ERROU_DIGITO4		;Se não for igual, desvia
    
JMP COMPARAR_FINAL		;Vai para a rotina de comparação final

ERROU_DIGITO1:				;Vem para essa rotina se a comparação não 
;deu igual
INC ERROU_D			;incrementa variável que controla se houve erro
	JMP COMPARA_2			;Pula para a comparação do próximo dígito

ERROU_DIGITO2:				;Vem para essa rotina se a comparação não 
;deu igual
INC ERROU_D			;incrementa variável que controla se houve erro
	JMP COMPARA_3			;Pula para a comparação do próximo dígito

ERROU_DIGITO3::				;Vem para essa rotina se a comparação não 
;deu igual
INC ERROU_D			;incrementa variável que controla se houve erro
	JMP COMPARA_4			;Pula para a comparação do próximo dígito

 ERROU_DIGITO4::				;Vem para essa rotina se a comparação não 
;deu igual
INC ERROU_D			;incrementa variável que controla se houve erro
	JMP COMPARAR_FINAL		;Pula para a comparação final
    
COMPARAR_FINAL:				;Realiza a comparação final
LDA ERROU_D			;Carrega valor da variável que contém o 
					;número de erros
	CMP #0				;Compara com zero
	BEQ ACERTOU			;Se for igual, desvia para acertou, caso 
;contrário, segue a sequência do algoritmo

ERROU:					;sub-rotina caso usuário erre a senha
BSET 2,PTBD				;Acende LED vermelho
INC N_ERROS			;Incrementa quantas variável que conta
					;quantas vezes a senha foi dada como errada
					;na comparação final
MOV #0, tempo			;zera variável de tempo
    
PRENDE:					;sub-rotina que deixa o LED ligado por 5s
LDA tempo				;Carrega o valor do tempo
CMP #5				;Compara com 5 (segundos)
BLO PRENDE				;Se tempo<5, permanece na rotina
					;Caso contrário, segue o código
BCLR 3,PTBD				;Quando atingir 5s, apaga o LED vermelho
    
QUANTAS_ERROU:		;Rotina que testa quantas vezes consecutivas o usuário errou

LDA N_ERROS		;Carrega variável que conta o número de erros na 
;comparação final
CMP MAXIMO_ERRO	;Compara com o número máximo de erros (3)
BLO PULA_PARTE2		;Se for menor, permite outra tentativa para o usuário
BHS TRAVA			;Se maior ou igual, trava o programa e não permite
				;outra tentativa
    
PULA_PARTE2:			;É necessário criar essa rotina pois o BLO não
JMP PARTE2			;não atinge lugares tão distantes no código,
				;então primeiro realiza o teste e depois utiliza um jump

ACERTOU:			;Sub-rotina caso usuário acerte a senha na comparação final

INC QUANTAS_COMEMOROU 	;Incrementa variável que controla quantas 
;vezes já comemorou 				
MOV #0,tempo			;zera o tempo
MOV #0, N_ERROS			;zera o número de erros da comparação final
MOV #0, ERROU_D			;zera variável que conta quando dígitos estão 
;errados
LDA QUANTAS_COMEMOROU	;Carrega valor de quantas vezes já comemorou
	CMP COMEMORA			;Compara com comemora, que é o número de 
;vezes que vai comemorar
	BHI INTERROMPE			;Se for maior, já comemorou o número de vezes 
;definido e interrompe a comemoração 
;Caso contrário, segue o código

    ;As próximas duas rotinas é para fazer o LED verde piscar ao acertar
    liga_verde:					;Rotina para deixar o LED ligado por 1s

 	BSET 3,PTBD				;Liga LED verde
	LDA tempo				;Carrega valor do tempo
	CMP #1				;Compara com 1 (segundo)
	BHI desliga_verde			;Se for maior, apaga
	BRA liga_verde			;Caso contrário, se mantém na rotina
       	 
desliga_verde:				;Rotina para deixar o LED apagado por 2s

	BCLR 3,PTBD			;Apaga LED verde
	LDA tempo			;Carrega valor do tempo
	CMP #3			;Compara com 1 (segundo)			
	BLO desliga_verde		;Se for menor, permanece na rotina
	BRA ACERTOU		;Caso contrário, vai para acertou

;Permanece piscando até atingir o número de comemorações definido
;Quando passar desse valor, interrompe a comemoração

INTERROMPE:			;Rotina que interrompe a comemoração
BSET 3,PTBD			;Mantém LED verde aceso
BRSET 6,PTDD, INTERROMPE 	;Enquanto o botão PTD6 não for pressionado
					;se mantém nesse estágio. O botão simboliza
					;o fechamento do cofre.

;Quando o botão for pressionado, continua o código para poder testar uma senha
;novamente, para isso é necessário zerar os dígitos de teste:
MOV #0,DIGITO_1_TESTE
	MOV #0,DIGITO_2_TESTE
	MOV #0,DIGITO_3_TESTE
	MOV #0,DIGITO_4_TESTE
	MOV #0,PTCD 			;Apaga os LEDs brancos
	MOV #0,PTBD			;Apaga os LEDs vermelho e verde
MOV #0,QUANTAS_COMEMOROU	;Zera variáveis que conta as comemorações JMP TESTE1				;Pula para realizar o teste de uma nova senha

;Quando o usuário erra três vezes consecutivas, o programa trava

TRAVA:    					;Rotina que realiza o travamento
MOV #0,tempo			;Zera o tempo
;As duas rotinas a seguir, são responsáveis por fazer os LEDs vermelho e verde, piscarem
;de forma alternada e o BUZZER tocar de forma intermitente

liga_buzzer:					

BCLR 3,PTBD  			;Apaga LED verde
BCLR 7,PTAD				;Desliga o BUZZER 
	BSET 2,PTBD				;Liga LED vermelho
	LDA tempo				;Carrega o tempo
	CMP #1				;Compara com 1s
	BHI desliga_buzzer			;Se maior, vai pra rotina seguinte
	BRA liga_buzzer			;Caso contrário volta para o início dessa rotina
       	 
desliga_buzzer:
BCLR 2,PTBD   			;Apaga LED vermelho  
	BSET 3,PTBD				;Liga LED verde
	BSET 7,PTAD				;Liga BUZZER	
	LDA tempo				;Carrega o tempo
	CMP #3				;Compara com 3s
	BLO desliga_buzzer			;Se menor, permanece na rotina
	JMP TRAVA				;Se maior, volta para rotina trava
    
;O código ficará preso nessas rotinas de travamento, só sendo possível parar quando
;resetar a placa e iniciar o processo da primeira etapa de definição de senha real

;Rotina de tratamento de interrupção em tempo real
TRTRC:         	 
	LDA RTCSC
	ORA #$80
	STA RTCSC			;Escreve1 no RTIACK para resetar o RTIF
	INC tempo			;Onde o tempo é incrementado
	RTI


;Vetores de interrupção    
	ORG $FFFE
RESET:	DC.W INICIO

	ORG $FFCE
	DC.W TRTRC
