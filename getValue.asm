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
    
    mov di, get_input_buffer
    call get_input
    mov si, VALUE_newline
    call print_log

    ;call print_test

    call convert_user_input
    call prep_convert
    mov ax, [User_base_val]
    call convert_int_to_str
    mov si, VALUE_int_to_str_buffer
    call print_log

    mov si, VALUE_newline
    call print_log
    mov ax, [User_base_val]
    mov [Convert_base_val], ax
    call print_test

;{CODE}

   jmp $

print_log:
   mov ah, 0x0E
.loop:
   lodsb
   cmp al, 0
   je .done
   int 0x10
   jmp .loop
.done:
   ret

get_input:
   xor cx, cx
.loop:
    mov ah, 0
    int 0x16
    cmp al, 0x0D
    je .done
    stosb   
    inc cx  
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    mov byte [di], 0 
    ret

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
    mov [VALUE_add], ax
.cont:
    mov bx, [VALUE_add]
    mov al, byte [Convert_str_to_base_buffer + bx]
    cmp ax, 0
    jle .skip
    call print_one
.skip:
    inc word [VALUE_add]
    mov dx,  [VALUE_buffer_len]
    cmp word [VALUE_add], dx
    jle .cont
    ret

convert_user_input:
    xor ax, ax
    mov word [VALUE_add], 0x0000
    mov word [User_base_val], 0x0000
.cont:
    mov bx, [VALUE_add]
    mov bl, byte [get_input_buffer + bx]
    cmp bl, 0
    jle .skip
    sub bl, '0'
    mov ax, [User_base_val]
    mov cx, 10
    mul cx
    mov word [User_base_val], ax
    add byte [User_base_val], bl
.skip:
    inc word [VALUE_add]
    mov dx,  [VALUE_buffer_len]
    cmp word [VALUE_add], dx
    jle .cont
.done:
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

prep_convert:
   mov cl, 0
   mov [VALUE_int_to_str_index], cl
   ret
convert_int_to_str:
   cmp eax, 10
   jge .div_num

   jmp .store_value
.div_num:
   xor edx, edx
   mov ebx, 10
   div ebx
   push edx
   call convert_int_to_str
   pop edx
   mov al, dl

.store_value:
   add al, '0' 

   push ebx 
   mov ebx, VALUE_int_to_str_buffer
   mov cl, [VALUE_int_to_str_index]
   add ebx, ecx
   mov byte [ebx], al
   inc cl
   mov [VALUE_int_to_str_index], cl
   pop ebx
    
.done:
   mov ebx, VALUE_int_to_str_buffer
   mov cl, [VALUE_int_to_str_index]
   add ebx, ecx
   mov byte [ebx], 0
   ret

VALUE_Start dw 0
VALUE_add dw 0
VALUE_hello db 'Hello, World!',13,10,'',0
VALUE_newline db '',13,10,'',0
VALUE_int_to_str_buffer db 0,0,0,0,0,0,0,0,0,0,0
VALUE_int_to_str_index db 0

get_input_buffer times 11 db 0
Convert_str_to_base_buffer times 11 db 0
VALUE_buffer_depth dw 10
VALUE_buffer_len dw 10

Convert_base_val dw 2
User_base_val dw 10

Convert_str_to_base_values db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'
;{VARIABLE}
times 510-($-$$) db 0
dw 0xaa55
