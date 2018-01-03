List P = 16F84A
Include <P16F84A.inc>

org 0
;************* Variables ******************************
		horas EQU 0ch
		minutos EQU 0dh
		segundos EQU 0eh
		timer EQU 0fh
		condicion EQU 1ah
;******************************************************		
;************** Configuracion *************************		
		bsf STATUS, RP0
		clrf TRISB
		bcf TRISA, 0
		bcf TRISA, 1
		bcf TRISA, 2
		clrf OPTION_REG
		; su prescales es 256
		bsf OPTION_REG, 0
		bsf OPTION_REG, 1
		bsf OPTION_REG, 2			
		bcf STATUS, RP0
;*****************************************************
;************* Inicializacion ************************		
Inicio	bsf PORTA, 0
		bsf PORTA, 1
		bsf PORTA, 2
		movlw d'7'
		movwf condicion ; condicion va a valer 7 siempre, es el valor clave para que se cumpla una condicion futura
		movlw d'24'
		movwf horas
		movlw 0
		movwf minutos
		movlw 0
		movwf segundos
;*****************************************************
;************ Programa Principal *********************
Ciclo	btfsc PORTA, 3
		goto Less ; Less indica que va a haber menos tiempo despues de la rutina
		call Retraso
		call Retraso
		call Retraso
		call Retraso
		call Retraso
		btfsc PORTA, 3 ; lo coloco aqui otra vez por tiempo de respuesta del boton, la idea es que fuera una interrupcion pero ya estan tomados esos pines
		goto Less
		call Retraso
		call Retraso
		call Retraso
		call Retraso
		call Retraso
		btfsc PORTA, 3 ; Otra vez
		goto Less
		call Retraso
		call Retraso
		call Retraso
		call Retraso
		call Retraso
	
	 	decf segundos
		movlw d'255'
		subwf segundos, 0
		btfsc STATUS, 2
		goto Tiempo ; Tiempo se encarga de verificar si los demas registros son 0 tambien y si lo son entonces decrementa y le pone los valores a los registros respectivos 
		goto Ciclo 
;*****************************************************		
;******************* Rutinas *************************

Tiempo	incf segundos ; dado que segundos en antes de esta instruccion es 255
		call isFinal
		subwf condicion, 0
		btfsc STATUS, 2 ; si es 0 significa que horas es != 0 y ya que esta en Tiempo, segundos es menor a 0 entonces minutos tiene que decrementar a juro ya que horas > 0
		goto Final
		call SETSEG ;en este punto no se si las horas o minutos es diferente a 0, es uno de los dos pero no ambos, empiezo preguntando por los minutos
		movlw 0
		subwf minutos, 0 ; si minutos != 0 entonces horas == 0, por lo tanto minutos se decrementa como usual
						 ; si minutos == 0 entonces horas != 0, por lo tanto minutos se pone en 59 y se decrementa las horas
		btfss STATUS, 2
  ;******************************************************
		goto DecMin ; dentro de este goto decrementa minutos y se va a Ciclo 
    ;*****(decf minutos) ya que los minutos no son 0 y los segundos son < 0******
  ;******************************************************
		goto DecHora ; dentro de este goto decrementa horas, pone minutos en 59 y se va Ciclo  
	;******(decf horas) y (SETMIN), ya que los minutos son 0, los segundos son < 0 y horas > 0  		

;*************************

;Retraso es simplemente el temporizador en accion para los segundos
Retraso	movlw d'0'
		movwf TMR0
		bcf INTCON, T0IF
Regresa	btfsc INTCON, T0IF ;se desbordo?
		return
		call Display
		goto Regresa

;*************************

Less	call isFinal
		subwf condicion, 0
		btfsc STATUS, 2
		goto Final
		call Display ; primer display de todos, es para visualizar el cambio
		movlw 0
		subwf minutos, 0 ; minutos == 0? si minutos != 0 se le restan los minutos, si es == 0 entonces pregunto por las horas
		btfss STATUS, 2
		goto DcMin ; si minutos es mayor a 0 se le resta y se pregunta si se desea seguir Less
		call Display
		movlw 0
		subwf horas, 0
		btfss STATUS, 2
		goto DcHora ; si horas es mayor a 0 y minutos es 0, horas decrementa y minutos es 59
		call SetMin ; si horas es 0 y minutos es 0, minutos se mantiene en 0
		
Seguir?	call Display ; estos displays son para generar retardo y mostrar la imagen en los displays al mismo tiempo
		call D1
		call Display
		call D1
		call Display
		call D1
		btfsc PORTA, 3
		goto Less
		goto Ciclo

;*************************

ChckHor movlw 0
		subwf horas, 0
		btfss STATUS, 2
		call DecHora ; cuando horas != 0 le resto horas, pongo 59 en minutos y regreso a Ciclo
		movlw 0 ; cuando hora == 0 y minutos <= 0 (el cual es el caso, minutos = 255 especificamente), entonces minutos no puede seguir disminuyendo y se pone en 0
		movwf minutos
		goto Ciclo 

;*************************

DecMin  decf minutos ; este se utiliza para Tiempo
		goto Ciclo

;*************************

DcMin	decf minutos ; este se utiliza para Les
		goto Seguir?

;*************************

DecHora decf horas ; este se utiliza para Tiempo
		call SETMIN
		goto Ciclo

;*************************

DcHora  decf horas ; este se utiliza para Less
		call SETMIN
		goto Seguir?

;*************************

SETSEG 	movlw d'59'
		movwf segundos
		return

;*************************

SETMIN	movlw d'59' ; se utiliza dentro de DecHora y DcHora
		movwf minutos
		return

;*************************

SetMin	movlw 0 ; este es para Less
		movwf minutos
		return

;*************************

isFinal movlw 0
		subwf horas, 0
		btfss STATUS, 2
		retlw 0 ; retorna 0, la condicion no se cumplira

		movlw 0
		subwf minutos, 0
		btfss STATUS, 2
		retlw 0 ; retorna 0, la condicion no se cumplira

		movlw 0
		subwf segundos, 0
		btfss STATUS, 2
		retlw 0 ; retorna 0, la condicion no se cumplira
		retlw d'7' ; si llega a esto, significa que horas, minutos y segundos son 0

;*************************
;aqui va la habilitacion del pulsador y el reloj parpadeante con la alarma
Final   
Atras	bsf PORTA, 0
		bsf PORTA, 1
		bsf PORTA, 2
		bsf PORTB, 6
		call Delay
		bcf PORTB, 6
		call Delay
		bsf PORTB, 6

		btfsc PORTA, 4
		goto Inicio

		bcf PORTB, 6
		call Delay
		bsf PORTB, 6
		call Delay
		bcf PORTA, 0
		bcf PORTA, 1
		bcf PORTA, 2
		bcf PORTB, 6
		call Delay
		bsf PORTB, 6
		call Delay

		btfsc PORTA, 4
		goto Inicio

		bcf PORTB, 6
		call Delay
		bsf PORTB, 6
		call Delay
		goto Atras

;*************************

;Display se encarga de mostrar el valor de cada registro en su display respectivo
Display movf horas, 0
		movwf PORTB ; justo despues de apagar el display cambio su valor
		bcf PORTA, 0 ; prendo el display que me muestra las horas
		call D1 ; necesito esto para que el CPU no se sobrecargue, tambien para que se quede un corto tiempo la imagen en el display
		
		movf minutos, 0
		bsf PORTA, 0
		movwf PORTB
		bcf PORTA, 1
		call D1

		movf segundos, 0
		bsf PORTA, 1
		movwf PORTB
		bcf PORTA, 2
		call D1
		bsf PORTA, 2
		return

;*************************

;Delay es otro retraso designado para el estado Final
Delay   movlw 0
		movwf TMR0
		bcf INTCON, T0IF
Vuelta	btfss INTCON, T0IF
		goto Vuelta
		return

;*************************

;D1 es un ligero retardo para darle suficiente tiempo al display para mostrar el valor del registro
D1		movlw 255
		movwf timer
Dec		decfsz timer
		goto Dec
		return

;*************************
end