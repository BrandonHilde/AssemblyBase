ORG 0x7c00

;{CONSTANTS}
;
;  100
;  100 > 16
;  100 / 16  al = 6  dl = 4
;
;

start:
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7c00

   call print_test

;{CODE}

   jmp $

print_test:
   mov ebx, 0x00000000
   mov eax, 0x00000000
   mov ax, 0x7FFF           ; max signed value
   call convert_to_base
   call print_all
   ret

print_all:
   mov ebx, 0x00000000
   mov eax, 0x00000000


.cont:
   mov bx, [VALUE_add]
   mov al, byte [Convert_str_to_base_buffer + bx]
   cmp ax, 0
   jle .skip
   call print_one
.skip:
   add word [VALUE_add], 1
   mov dx,  [VALUE_buffer_len]
   cmp word [VALUE_add], dx
   jle .cont
   ret

convert_to_base:
   cmp word [Convert_base_val], 2
   jl .done
.check_max:
   cmp word [Convert_base_val], 64
   jg .done
.check:
   cmp ax, word [Convert_base_val]
   jl .mov_bx
.div_num:
   xor dx, dx
   div word [Convert_base_val]
   call .mov_dl
   jmp .check
   jmp .mov_bx
.mov_dl:
   xor bx, bx
   mov bx, dx
   jmp .to_buffer
.mov_bx:
   xor bx, bx
   mov bx, ax
.to_buffer:
   mov cl, [Convert_str_to_base_values + bx]
   mov bx, word [VALUE_buffer_depth]
   mov byte [Convert_str_to_base_buffer + bx], cl
   sub bx, 1
   mov word [VALUE_buffer_depth], bx
.done:
    ret

print_one:
   mov ah, 0x0E
   int 0x10
   ret

; mov_al:
;    mov bx, ax
;    mov al, [Convert_str_to_base_values + bx]
;    call print_one
;    ret

; mov_dl:
;    mov bx, dx
;    mov al, [Convert_str_to_base_values + bx]
;    call print_one
;    ret

VALUE_Start dw 0
VALUE_add dw 0
VALUE_hello db 'Hello, World!',13,10,'',0
VALUE_newline db '',13,10,'',0
VALUE_0 db 'Press any key to continue...',0
hexdecimalVals db '0123456789ABCDEF'
Value_output db 0,0
Convert_str_int_buffer db 0,0,0,0,0,0,0,0,0,0
Convert_str_to_base_buffer db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
VALUE_buffer_depth dw 40
VALUE_buffer_len dw 40

Convert_base_val dw 16
Convert_str_to_base_values db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'
;{VARIABLE}
times 510-($-$$) db 0
dw 0xaa55
