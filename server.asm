section .text
	global _start

_start:
get_pid:
	mov rax, 39
	syscall
	mov dword [pid], eax
socket:
	mov edx, 0	 ; IPPROTO_IP
	mov esi, 1	 ; SOCK_STREAM
	mov edi, 2	 ; AF_INET
	mov rax, 41	; socket
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
	mov qword [server_fd], rax
setsockopt:
	mov rax, 54
	mov rdi, qword [server_fd]
	mov rsi, 1	; SOL_SOCKET
	mov rdx, 2	; SO_REUSEADDR
	mov rcx, opt ;*opt
	mov r8, 4	; len(opt)
	endbr64
	mov r10,rcx
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
bind:
	mov rax, 49
	mov rdi, qword [server_fd] ; sockfd
	mov rsi, sockaddr
	mov rdx, 16
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
listen:
	mov rax,50
	mov rdi, qword [server_fd]
	mov rsi, 2
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
loop:
accept:
	mov rax, 43
	mov rdi, qword [server_fd]
	xor rsi, rsi
	xor rdx,rdx
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
fork:
	mov rax, 57
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
fork_ppid:
	mov rax, 110
	syscall
	cmp dword [pid], eax
	jne continue
	call client
	jmp exit
continue:
	mov rax, 3
	mov rdi, 4
	syscall
	cmp rax, 0xffffffffffffffff
	jle exit
	jmp loop
exit:
	mov rax, 60
	mov rdi, 0
	syscall

client:
init_ok:
	mov rdx, len_success
	mov rdi, buffer_resp
	mov rsi, str_success
init_ok_loop:
	mov rcx, [rsi]
	mov byte [rdi], cl
	inc rdi
	inc rsi
	dec rdx
	cmp rdx, 0
	jnz init_ok_loop
read_url:
	mov rax, 0
	mov rdi, 4
	mov rsi, buffer_url
	mov rdx, 0x400
	syscall
	mov rdx, 0
check_url:
	mov dil, [str_url+rdx]
	cmp byte [rsi+rdx], dil
	jne out_check_url
	inc rdx
	jmp check_url
out_check_url:
	cmp byte [str_url+rdx], 0
	je url_ok
failure:
	mov rax, 1
	mov rdi, 4
	mov rsi, str_failure
	mov rdx, len_failure
	syscall
	ret
url_ok:
	cmp byte [rsi+rdx], 0xd
	jne	comp_eos
sanitize_CR:
	mov byte [rsi+rdx], 0
comp_eos:
	cmp byte [rsi+rdx], 0
	je open_file
	inc rdx
	jmp url_ok
open_file:
	mov rax, 2
	mov rdi, rsi
	add rdi, len_prot_dom
	mov rsi, 0
	syscall
	cmp rax, 0
	jle failure
success:
	mov rdi, rax
	mov rax, 0
	mov rsi, buffer_resp
	add rsi, len_success
	mov rdx, 0x400
	syscall		; write
	mov rdx, rax
	mov rax, 3
	mov rdi, 5
	syscall		; close
	add rdx, len_success
	mov rax, 1
	mov rdi, 4
	mov rsi, buffer_resp
	syscall
	ret
	
read_file:
	jmp failure

section .data
pid DD 0
opt DD 0
sockaddr DW 2,0xb822,0,0,0,0,0,0
server_fd DQ 0

str_url:
DB "gemini://"
DB domain
end_dom:
DB filespath,0
len_prot_dom equ end_dom - str_url

str_success:
DB "20 text/gemini",0xd,0x0a,0
len_success equ $ - str_success

str_failure:
DB "30 gemini://"
DB domain
DB redirpath,0xd,0x0a,0
len_failure equ $ - str_failure

section .bss
buffer_url: resb 0x500
buffer_resp:
resb len_success
resb pagelength
