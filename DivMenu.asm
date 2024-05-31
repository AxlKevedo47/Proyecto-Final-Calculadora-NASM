section .bss
  buffer resb 12  ; Espacio para almacenar la entrada del usuario
  resultado resb 12  ; Espacio para almacenar el resultado de la conversión a cadena

section .data
  numero1 dd 0       ; Variable para almacenar el primer número ingresado por el usuario
  numero2 dd 0       ; Variable para almacenar el segundo número ingresado por el usuario
  parte_entera dd 0  ; Parte entera del resultado
  parte_decimal dd 0 ; Parte decimal del resultado
  mensajeResultado db 'El resultado de la division es: ', 0  ; Mensaje de resultado
  mensajeLongitud equ $ - mensajeResultado  ; Longitud del mensaje de resultado
  mensajeNumero1 db 'Introduce el primer numero (1-99): ', 0  ; Mensaje para el primer número
  mensajeNumero1Longitud equ $ - mensajeNumero1  ; Longitud del mensaje para el primer número
  mensajeNumero2 db 'Introduce el segundo numero (1-99): ', 0  ; Mensaje para el segundo número
  mensajeNumero2Longitud equ $ - mensajeNumero2  ; Longitud del mensaje para el segundo número
  mensajeError db 'Numero fuera de rango. Intenta de nuevo.', 0xA, 0  ; Mensaje de error
  mensajeErrorLongitud equ $ - mensajeError  ; Longitud del mensaje de error

section .text
  global _start

; Macro para realizar llamadas al sistema
%macro llamarAlSistema 4
  mov eax, %1        ; Número de la llamada al sistema en EAX
  mov ebx, %2        ; Primer argumento de la llamada al sistema en EBX
  mov ecx, %3        ; Segundo argumento de la llamada al sistema en ECX
  mov edx, %4        ; Tercer argumento de la llamada al sistema en EDX
  int 0x80           ; Interrupción para llamar al sistema
%endmacro

; Convierte una cadena de caracteres a un entero
convertirAEentero:
  xor eax, eax  ; Inicializa EAX a 0
  xor ebx, ebx  ; Inicializa EBX a 0
  xor edx, edx  ; Inicializa EDX a 0
  mov ebx, 10  ; Base decimal
.parseLoop:
  movzx ecx, byte [esi + edx]  ; Carga el siguiente byte de la cadena en ECX
  test cl, cl  ; Comprueba si es el fin de la cadena
  jz .done  ; Si es NULL, termina
  cmp cl, 0xA  ; Comprueba si es el carácter de nueva línea
  je .done  ; Si es nueva línea, termina
  sub ecx, '0'  ; Convierte el carácter ASCII a su valor numérico
  imul eax, ebx  ; Multiplica EAX por 10 (para desplazar el dígito anterior)
  add eax, ecx  ; Añade el valor del dígito actual a EAX
  inc edx  ; Incrementa el contador de posición
  jmp .parseLoop  ; Repite el bucle para el siguiente carácter
.done:
  ret  ; Retorna con el valor convertido en EAX

; Convierte un entero a una cadena de caracteres
convertirACadena:
  mov ebx, 10  ; Base decimal
  mov ecx, resultado + 10  ; Apunta ECX al final del buffer para el resultado
  mov byte [ecx], 0  ; Coloca un terminador nulo al final de la cadena
  dec ecx  ; Mueve el puntero una posición hacia atrás
.bucleConversion:
  xor edx, edx  ; Limpia EDX para la división
  div ebx  ; Divide EAX por 10, cociente en EAX, resto en EDX
  add dl, '0'  ; Convierte el resto en carácter ASCII
  mov [ecx], dl  ; Almacena el carácter en la posición actual
  dec ecx  ; Mueve el puntero una posición hacia atrás
  test eax, eax  ; Comprueba si el cociente es cero
  jnz .bucleConversion  ; Si el cociente no es cero, repite el bucle
  inc ecx  ; Mueve el puntero una posición hacia adelante al primer dígito
  ret  ; Retorna con ECX apuntando al inicio de la cadena

; Convierte la parte decimal de un número a una cadena de caracteres
convertirParteDecimal:
  mov ebx, 10  ; Base decimal
  mov ecx, resultado + 10  ; Apunta ECX al final del buffer para el resultado
  mov byte [ecx], 0  ; Coloca un terminador nulo al final de la cadena
  dec ecx  ; Mueve el puntero una posición hacia atrás
.bucleDecimal:
  xor edx, edx  ; Limpia EDX para la división
  div ebx  ; Divide EAX por 10, cociente en EAX, resto en EDX
  add dl, '0'  ; Convierte el resto en carácter ASCII
  mov [ecx], dl  ; Almacena el carácter en la posición actual
  dec ecx  ; Mueve el puntero una posición hacia atrás
  test eax, eax  ; Comprueba si el cociente es cero
  jnz .bucleDecimal  ; Si el cociente no es cero, repite el bucle
  inc ecx  ; Mueve el puntero una posición hacia adelante al primer dígito
  ret  ; Retorna con ECX apuntando al inicio de la cadena

; Valida que un número esté en el rango de 1 a 99
validarRango:
  cmp eax, 1  ; Compara EAX con 1
  jl .fueraDeRango  ; Si EAX es menor que 1, salta a fueraDeRango
  cmp eax, 99  ; Compara EAX con 99
  jg .fueraDeRango  ; Si EAX es mayor que 99, salta a fueraDeRango
  ret  ; Si el valor está en el rango, retorna
.fueraDeRango:
  llamarAlSistema 4, 1, mensajeError, mensajeErrorLongitud  ; Muestra mensaje de error
  jmp _start  ; Reinicia la entrada del usuario

_start:
  ; Solicita el primer número
  llamarAlSistema 4, 1, mensajeNumero1, mensajeNumero1Longitud
  llamarAlSistema 3, 0, buffer, 12  ; Lee el primer número
  mov esi, buffer  ; Apunta ESI al buffer
  call convertirAEentero  ; Convierte la cadena a entero
  call validarRango  ; Valida que el número esté en el rango de 1-99
  mov [numero1], eax  ; Almacena el valor convertido en numero1

  ; Solicita el segundo número
  llamarAlSistema 4, 1, mensajeNumero2, mensajeNumero2Longitud
  llamarAlSistema 3, 0, buffer, 12  ; Lee el segundo número
  mov esi, buffer  ; Apunta ESI al buffer
  call convertirAEentero  ; Convierte la cadena a entero
  call validarRango  ; Valida que el número esté en el rango de 1-99
  mov [numero2], eax  ; Almacena el valor convertido en numero2

  ; Realiza la división
  mov eax, [numero1]  ; Carga el primer número en EAX
  mov ebx, [numero2]  ; Carga el segundo número en EBX
  cdq  ; Extiende el signo de EAX a EDX:EAX para la división
  div ebx  ; Divide EDX:EAX entre EBX
  mov [parte_entera], eax  ; Almacena el resultado entero de la división en parte_entera

  ; Calcula la parte decimal
  mov eax, edx  ; Carga el resto de la división en EAX
  imul eax, 100  ; Multiplica el resto por 100
  cdq  ; Extiende el signo
  div ebx  ; Divide el producto por el divisor original
  mov [parte_decimal], eax  ; Almacena el resultado decimal en parte_decimal

  ; Muestra el mensaje inicial
  llamarAlSistema 4, 1, mensajeResultado, mensajeLongitud

  ; Convierte la parte entera a cadena
  mov eax, [parte_entera]
  call convertirACadena
  mov edi, resultado + 10
  sub edi, ecx
  mov edx, edi
  llamarAlSistema 4, 1, ecx, edx  ; Muestra la cadena de la parte entera

  ; Muestra el punto decimal
  mov eax, '.'
  mov [resultado + 10], al
  llamarAlSistema 4, 1, resultado + 10, 1

  ; Convierte la parte decimal a cadena
  mov eax, [parte_decimal]
  call convertirParteDecimal
  mov edi, resultado + 10
  sub edi, ecx
  mov edx, edi
  llamarAlSistema 4, 1, ecx, edx  ; Muestra la cadena de la parte decimal

  ; Termina el programa
  llamarAlSistema 1, 0, 0, 0

