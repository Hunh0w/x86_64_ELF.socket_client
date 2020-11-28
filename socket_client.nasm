BITS 64

%define SOCK_STREAM 1

struc sockaddr_in
    .sin_family resw 1
    .sin_port resw 1
    .sin_addr resd 1
    .sin_zero resb 8
endstruc

section .text

global _start

_start:
jmp _socks

_socks:
mov rax, 0x29
mov rdi, 2
mov rsi, SOCK_STREAM
mov rdx, 0
syscall
cmp rax, 0
jl _error
mov [sockfd], rax
jmp _connect

_connect:
mov rax, 0x2a
mov rdi, [sockfd]
mov rsi, srvstruct
mov rdx, srvstruct_len
syscall
cmp rax, 0
jl _error
jmp _read

_read:
xor rax, rax
mov rdi, [sockfd]
mov rsi, buffer
mov rdx, buffer_len
syscall
jmp _printmsg

_printmsg:
mov rax, 1
mov rdi, 1
mov rsi, buffer
mov rdx, buffer_len
syscall
mov r9w, word [buffer_len]
jmp _clearbuffer

_clearbuffer:
cmp r9w, 0
jle _read
dec r9w
mov r10, buffer
add r10w, r9w
mov [r10], word 0x0
jmp _clearbuffer

_error:
neg rax
mov r8, rax
mov r9, 100
xor rdx, rdx
idiv r9
add rax, '0'
mov [number], rax
sub rax, '0'

mov r10, r8
xor rdx, rdx
mul r9
mov r9, 10
sub r10, rax
mov rax, r10
xor rdx, rdx
idiv r9
add rax, '0'
mov [number+1], rax
sub rax, '0'

xor rdx, rdx
mul r9
sub r10, rax
add r10, '0'
mov [number+2], r10
sub r10, '0'

mov [number+3], byte 0xA

mov rax, 1
mov rdi, 1
mov rsi, errmsg
mov rdx, errmsg_len
syscall
mov rax, 1
mov rdi, 1
mov rsi, number
mov rdx, 4
syscall
jmp _exit

_exit:
mov rax, 60
xor rdi, rdi
syscall

section .data

errmsg db "Erreur code: "
errmsg_len equ $-errmsg

srvstruct istruc sockaddr_in
    at sockaddr_in.sin_family, dw 2           ; AF_INET
    at sockaddr_in.sin_port, dw 0x1A24        ; port 9242 --> 0x1A24
    at sockaddr_in.sin_addr, dd 0x0           ; 0 = localhost - INADDR_ANY
    at sockaddr_in.sin_zero, dd 0,0
iend
srvstruct_len equ $-srvstruct
buffer_len dw 500

section .bss

sockfd resd 1
buffer resb 500
number resb 4
