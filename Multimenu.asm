section .bss
  buffer resb 12  ; Espacio para almacenar la entrada del usuario

section .data
  numero1 dd 0
  numero2 dd 0
  resultado dd 0
  mensajeResultado db 'El resultado de la multiplicacion es: ', 0
  mensajeLongitud equ $ - mensajeResultado
  mensajeNumero1 db 'Introduce el primer numero (1-99): ', 0
  mensajeNumero1Longitud equ $ - mensajeNumero1
  mensajeNumero2 db 'Introduce el segundo numero (1-99): ', 0
  mensajeNumero2Longitud equ $ - mensajeNumero2
  mensajeError db 'Numero fuera de rango. Intenta de nuevo.', 0xA, 0
  mensajeErrorLongitud equ $ - mensajeError

section .text
  global _start

; Macros para llamadas al sistema
; Recibe cuatro argumentos que corresponden a los registros que se necesitan configurar
%macro llamarAlSistema 4
  mov eax, %1  ; número de la llamada al sistema en EAX
  mov ebx, %2  ; primer argumento de la llamada al sistema en EBX
  mov ecx, %3  ; segundo argumento de la llamada al sistema en ECX
  mov edx, %4  ; tercer argumento de la llamada al sistema en EDX
  int 0x80     ; interrumpe el sistema
%endmacro

; Etiqueta para la conversión de cadena a entero
convertirAEentero:
  xor eax, eax  ; Inicializa EAX a 0 (donde se almacenará el valor convertido)
  xor ebx, ebx  ; Inicializa EBX a 0 
  xor edx, edx  ; Inicializa EDX a 0  ->contador de posición de caracteres
  mov ebx, 10   ; EBX contiene la base decimal
.parseLoop:
  movzx ecx, byte [esi + edx]  ; Carga el siguiente byte de la cadena en ECX
  test cl, cl  ; Comprueba si es el fin de la cadena
  jz .done     ; Si es NULL se sale del bucle
  cmp cl, 0xA  ; Comprueba si es el carácter de nueva línea
  je .done     ; Si es nueva línea se sale del bucle
  sub ecx, '0' ; Convierte el carácter ASCII a su valor numérico
  imul eax, ebx ; Multiplica el valor actual de EAX por 10
  add eax, ecx ; Añade el valor del dígito actual a EAX
  inc edx      ; Incrementa el contador de posición
  jmp .parseLoop    ; Repite el bucle para el siguiente carácter
.done:
  ret   ; Retorna el valor entero en EAX

; Etiqueta para la conversión de entero a cadena
; El entero se encuentra en EAX y la cadena resultante se almacena en el buffer apuntado por ECX.
convertirACadena:
  mov ebx, 10    ; contiene la base (decimal)
  mov ecx, resultado + 10   ; Apunta ECX al final del espacio reservado para el resultado
  mov byte [ecx], 0 ; Coloca un terminador nulo al final de la cadena
  dec ecx    ; Mueve el puntero una posición hacia atrás
.bucleConversion:
  xor edx, edx   ; Limpia EDX para la división
  div ebx        ; Divide EAX por 10, cociente en EAX, resto en EDX
  add dl, '0'    ; Convierte el resto en carácter ASCII
  mov [ecx], dl  ; Almacena el carácter en la posición actual
  dec ecx        ; Mueve el puntero una posición hacia atrás
  test eax, eax  ; Comprueba si el cociente es cero
  jnz .bucleConversion   ; si el cociente no es cero, repite el bucle
  inc ecx   ; Mueve el puntero una posición hacia adelante al primer dígito
  ret       ; Retorna con ECX apuntando al inicio de la cadena

; para validar que el número esté en el rango de 1-99 sino muestra un mensaje de error y reinicia la entrada del usuario.
validarRango:
  cmp eax, 1    ; Compara EAX con 1
  jl .fueraDeRango ; Si EAX es menor que 1, salta a fueraDeRango
  cmp eax, 99  ; Compara EAX con 99
  jg .fueraDeRango ; Si EAX es mayor que 99, salta a fueraDeRango
  ret ; Si el valor está en el rango, retorna
.fueraDeRango:
  llamarAlSistema 4, 1, mensajeError, mensajeErrorLongitud ; escribir, mostrar, mensaje, longitud
  jmp _start                  ; Reinicia la entrada del usuario

_start:
  ; Pedir primer número
  llamarAlSistema 4, 1, mensajeNumero1, mensajeNumero1Longitud ; escribir, mostrar, mensaje, longitud, numero 1
  llamarAlSistema 3, 0, buffer, 12 ; lee, leer desde stdin, area reservada, numero bytes a leer
  mov esi, buffer   ; almacena en el buffer
  call convertirAEentero  ; Convierte la cadena a entero
  call validarRango   ; Valida que el número esté en el rango 1-99
  mov [numero1], eax  ; Almacena el valor convertido en numero1

  ; Pedir segundo número
  llamarAlSistema 4, 1, mensajeNumero2, mensajeNumero2Longitud ; escribir, mostrar, mensaje, longitud, numero 1
  llamarAlSistema 3, 0, buffer, 12    ; lee, leer desde stdin, area reservada, numero bytes a leer
  mov esi, buffer                     ; almacena en el buffer
  call convertirAEentero              ; Convierte la cadena a entero
  call validarRango                   ; Valida que el número esté en el rango 1-99
  mov [numero2], eax                  ; Almacena el valor convertido en numero2

  ; Multiplicación
  mov eax, [numero1]       ; Carga el primer número en EAX
  mov ebx, [numero2]       ; Carga el segundo número en EBX
  imul eax, ebx            ; Multiplica EAX por EBX
  mov [resultado], eax     ; Almacena el resultado de la multiplicación

  ; Mostrar mensaje inicial
  llamarAlSistema 4, 1, mensajeResultado, mensajeLongitud    ; escribir, mostrar, mensaje, longitud

  ; Convertir resultado a cadena
  mov eax, [resultado]   ; Carga el resultado en EAX
  call convertirACadena   ; Convierte el resultado a cadena

  ; Calcular longitud de la cadena resultante
  mov edi, resultado + 10  ; Apunta EDI al final del espacio reservado para el resultado
  sub edi, ecx  ; Resta la posición actual de ECX para obtener la longitud
  mov edx, edi  ; Mueve la longitud de la cadena a EDX

  ; Mostrar resultado
  llamarAlSistema 4, 1, ecx, edx ; mostrar la cadena que comienza en la dirección de memoria indicada por ECX

  ; Salir del programa
  llamarAlSistema 1, 0, 0, 0  ; Termina el programa


