section .bss
  buffer resb 12

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

%macro llamarAlSistema 4
  mov eax, %1
  mov ebx, %2
  mov ecx, %3
  mov edx, %4
  int 0x80
%endmacro

convertirAEentero:
  xor eax, eax
  xor ebx, ebx
  xor edx, edx
  mov ebx, 10
.parseLoop:
  movzx ecx, byte [esi + edx]
  test cl, cl
  jz .done
  cmp cl, 0xA
  je .done
  sub ecx, '0'
  imul eax, ebx
  add eax, ecx
  inc edx
  jmp .parseLoop
.done:
  ret

convertirACadena:
  mov ebx, 10
  mov ecx, resultado + 10
  mov byte [ecx], 0
  dec ecx
.bucleConversion:
  xor edx, edx
  div ebx
  add dl, '0'
  mov [ecx], dl
  dec ecx
  test eax, eax
  jnz .bucleConversion
  inc ecx
  ret

validarRango:
  cmp eax, 1
  jl .fueraDeRango
  cmp eax, 99
  jg .fueraDeRango
  ret
.fueraDeRango:
  llamarAlSistema 4, 1, mensajeError, mensajeErrorLongitud
  jmp _start

_start:
  llamarAlSistema 4, 1, mensajeNumero1, mensajeNumero1Longitud
  llamarAlSistema 3, 0, buffer, 12
  mov esi, buffer
  call convertirAEentero
  call validarRango
  mov [numero1], eax

  llamarAlSistema 4, 1, mensajeNumero2, mensajeNumero2Longitud
  llamarAlSistema 3, 0, buffer, 12
  mov esi, buffer
  call convertirAEentero
  call validarRango
  mov [numero2], eax

  mov eax, [numero1]
  mov ebx, [numero2]
  imul eax, ebx
  mov [resultado], eax

  llamarAlSistema 4, 1, mensajeResultado, mensajeLongitud

  mov eax, [resultado]
  call convertirACadena

  mov edi, resultado + 10
  sub edi, ecx
  mov edx, edi

  llamarAlSistema 4, 1, ecx, edx

  llamarAlSistema 1, 0, 0, 0

