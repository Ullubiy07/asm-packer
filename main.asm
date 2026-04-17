section .data
    msg1           db "_factor(5) = ", 0
    msg2           db "_fibb(9) = ", 0

    file_name      db "main_packed", 0
    open_mode      db "rb+", 0

    ksize          dd 512
    text_addr      dd 0x08049090
    payload_offset dd 0x0bcf2c


section .text
    extern io_print_string, io_print_dec, io_print_char, io_print_hex, io_newline, fopen, fseek, fwrite, fclose
    global main
main:
    mov    esi, payload_end
    sub    esi, payload_start    ; esi = payload size (required)

    mov    ecx, [esp + 4]        ; ecx = argc
    cmp    ecx, 1
    je     unpack
   
    call   _pack
    jmp    main_done

unpack:
    call   _unpack

    mov    eax, msg1
    call   io_print_string
    push   5
    call   _factor
    add    esp, 4
    call   io_print_dec
    call   io_newline

    mov    eax, msg2
    call   io_print_string
    push   9
    call   _fibb
    add    esp, 4
    call   io_print_dec
    call   io_newline

main_done:
    xor    eax, eax
    ret


_pack:
    push   ebp
    mov    ebp, esp

    push   dword [ksize]
    push   dword [text_addr]
    push   esi
    push   payload_start
    call   _xor
    add    esp, 16

    call   _write_payload
   
    pop    ebp
    ret

_unpack:
    push   ebp
    mov    ebp, esp

    push   dword [ksize]
    push   dword [text_addr]
    push   esi
    push   payload_start
    call   _xor
    add    esp, 16

    pop    ebp
    ret


; xor cipher
_xor:
    push   ebp
    mov    ebp, esp
    push   ebx
    push   esi
    push   edi

    mov    esi, [ebp + 8]  ; esi = char* buffer
    mov    edi, [ebp + 16] ; edi = char* key

    mov    ecx, 0          ; ecx - buffer index counter
    mov    edx, 0          ; edx - key index counter
loop_buf:
    cmp    ecx, dword [ebp + 12]  
    je     buf_done

    cmp    edx, dword [ebp + 20]
    jne    else

    mov    edx, 0
    mov    edi, [ebp + 16]

else:
    
    movsx  ebx, byte [esi]    ; ebx = *buffer
    xor    bl, byte [edi]     ; ebx ^= *key
    mov    byte [esi], bl     ; *buffer ^= *key

    inc    esi                ; buffer++
    inc    edi                ; key++
    inc    ecx
    inc    edx
    jmp    loop_buf
buf_done:
    mov    eax, [ebp + 8]

    pop    edi
    pop    esi
    pop    ebx
    mov    esp, ebp
    pop    ebp
    ret


; write the encrypted payload into [file_name] from memory
_write_payload:
    push   ebp
    mov    ebp, esp
    push   ebx

    push   open_mode
    push   file_name
    call   fopen        ; FILE* ebx = fopen("main", "w")
    add    esp, 8
    mov    ebx, eax

    cmp    ebx, 0
    je     file_error

    push   0
    push   dword [payload_offset]
    push   ebx
    call   fseek        ; fseek(f, payload_offset, 0)
    add    esp, 12

    push   ebx
    push   esi
    push   1
    push   payload_start  ; fwrite(payload_start, 1, payload_size, f)
    call   fwrite
    add    esp, 16
    
    push   ebx
    call   fclose         ; fclose(f)
    add    esp, 4

file_error:
    pop    ebx
    pop    ebp
    ret


; print payload bytes
_print_payload:
    push   ebp
    mov    ebp, esp
    push   ebx
    push   edi

    mov    ebx, 0
    mov    edi, payload_start
print:
    cmp    ebx, esi
    jge    print_done
    
    movzx  eax, byte [edi]
    call   io_print_hex
    mov    eax, ' '
    call   io_print_char

    inc    ebx
    inc    edi
    jmp    print
print_done:
    call   io_newline

    pop    edi
    pop    ebx
    pop    ebp
    ret




section .payload exec write ; Exercise 3
payload_start:
_factor:
    push   ebp
    mov    ebp, esp

    mov    eax, 1
    mov    ecx, 1

    cmp    dword [ebp + 8], 0
    je     fact_done
loop_fact:
    cmp    ecx, [ebp + 8]
    jg     fact_done

    imul   eax, ecx

    inc    ecx
    jmp    loop_fact
fact_done:
    mov    esp, ebp
    pop    ebp
    ret


_fibb:
    push   ebp
    mov    ebp, esp
    push   ebx

    mov    eax, 0     ; a = 0
    mov    ecx, 1     ; b = 1
    mov    ebx, 1

    cmp    dword [ebp + 8], 1
    jne    loop_fib

    mov    eax, 1
    jmp    fib_done

loop_fib:
    cmp    ebx, [ebp + 8]
    jg     fib_done

    mov    edx, ecx    ; tmp = b
    add    ecx, eax    ; b += a

    xor    edx, eax
    xor    eax, edx
    xor    edx, eax   ; swap(a, tmp)

    inc    ebx
    jmp    loop_fib
fib_done:
    pop    ebx
    mov    esp, ebp
    pop    ebp
    ret
payload_end:
    