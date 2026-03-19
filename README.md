Projeto de um cofre feito em Assembly.

# Video com demonstração

https://drive.google.com/file/d/1zx_xDY-X5udxlr34F7IPF1O2Aoz4FSsq/view?usp=sharing

# Funcionamento
O cofre possui uma senha de quatro dígitos.
Essa senha deve ser definida ao iniciar o funcionamento do código.
Existem cinco opções de algarismos para essa senha, esses cinco dígitos estão dispostos em cinco botões:
- PTC0 é o algarismo 0,
- PTA1 é o algarismo 1,
- PTA2 é o algarismo 2,
- PTA3 é o algarismo 3,
- PTA6 é o algarismo 4.

Ao definir uma senha, o programa aguardará que outra senha seja comparada com a  definida anteriormente. Cada dígito é comparado, então tanto o algarismo quanto
a ordem que foi utilizado deve ser a mesma. 

Caso o usuário acerte, o LED verde irá piscar, depois o cofre pode ser fechado pressionando o botão PTD6, e o programa aguardará outro teste.
Caso o usuário erre, o LED vermelho acenderá, se o usuário errar três vezes consecutivas o programa irá ser bloqueado, piscando os LEDs verde e vermelho de forma alternada e 
acionando o BUZZER de forma intermitente. 

O programa deverá ser resetado pelo botão da placa.
