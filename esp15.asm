; ----------------------------------------------------------------------------------------
; Analisi dati della esperienza 15. Linux 64 bit
; 
;Assembla ed esegue:
;     nasm -felf64 esp15.asm && gcc esp15.o && ./a.out
; ----------------------------------------------------------------------------------------
        global  main
        extern  printf


        section .data

msg1: 
        db "Dati Laser rosso",10, 0     
msg2: 
        db "Dati Laser arancione", 10,0
msg3: 
        db "Concentrazioni", 10,0 
msg4:
        db "Logaritmo laser rosso",10,0 
msg5:
        db "Logaritmo laser arancione:",10,0 
k_red:
        db "Costante k per il laser rosso: %lf",10,0
k_orange:
        db "Costante k per il laser arancione: %lf",10,0
fmt:
        db "%lf",10, 0          ; The printf format, "\n",'0'
stampa_a_b:
        db "a,b = %lf %lf",10,0
concentrazioni:
        dq 0.0, 0.062, 0.125, 0.25, 0.5, 0.6, 0.8, 1.0
red_laser:
        dq 2127.1,1031.1,662.1,269.1,44.6,15.1,6.25, 1.17
orange_laser:
        dq 1388.6,1111.6,879.6,656.6,336.6,196.6,136.6,90.6
log_e2:
        dq 0.6931471805599453
eight:
        dq 8.0
zero:
        dq 0.0
L:
        dq 0.0104
minus_one:
        dq -1.0

;section .bss
;   result: resq 1     ;quadword per i risultati


        section .text

;Print array routine, first argument in rdi, pointer to array base
print_array:
        push    rbp
        push    rcx
        
        xor     rcx, rcx                ; rcx fa da contatore, azzeriamolo
        mov     r12,rdi   

print_loop:
        push    rcx                     ; salviamo il registro

        ;chiamata a printf
        mov     rdi, fmt                ; formato
        movq    xmm0, [r12+8*rcx]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
        call    printf                  

        pop     rcx                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     print_loop                 ; jump se ecx<8


        pop     rcx
        pop     rbp
        ret
;---------------------------------------------------------------------

;Log of array routine, first argument in rdi, pointer to array base
log:
        push    rbp
        push    rcx

        xor     ecx,ecx
        mov     r12,rdi 

log_loop:
        ;logaritmo in base e 
        fld qword [log_e2]              ;st0 = ln2
        fld qword [r12+rcx*8]     ;st0 = x st1 = ln2
        fyl2x                           ;st0 = ln2*log_2(x)        
        fstp qword [r12+rcx*8]

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     log_loop            ; jump se ecx<8

        pop     rcx
        pop     rbp
        ret
;--------------------------------------------------------------------

;Linear fitting y=a+bx, y value in rdi, a in xmm0, b in xmm1
linear_regression:
        push    rbp
        push    rcx

        mov     r12,rdi
        movsd xmm1, [eight]                  ;sum(w)

        xor ecx,ecx
        movsd xmm0,[zero]                   ;somma parziale

sum_x_2:
        movsd xmm2,[concentrazioni+ecx*8]
        mulsd xmm2,xmm2                 ;x^2  
        addsd xmm0,xmm2                 ;xxm0+=x^2

        inc ecx
        cmp ecx,8
        jb sum_x_2

        ;xmm1 = sum(w),xmm0 = sum(x^2)

        xor ecx,ecx
        movsd xmm3,[zero]             ;somma parziale
sum_x:
        movsd xmm2,[concentrazioni+ecx*8]
        addsd xmm3,xmm2                 ;xxm0+=x^2
        inc ecx
        cmp ecx,8
        jb sum_x

        ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x)

        movq xmm4,xmm0                  ;xmm4= sum(x^2) 
        mulsd xmm4,xmm1                 ;xmm4= sum(w)*sum(x^2) 
        movq xmm8,xmm3
        mulsd xmm8,xmm3                 ;xmm3 = sum(x)^2
        subsd xmm4,xmm8                 ;xmm4= sum(w)*sum(x^2) -sum(x)^2

        ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla

        xor ecx,ecx
        movsd xmm5,[zero]             ;somma parziale
sum:
        movsd xmm2,[r12+rcx*8]
        addsd xmm5,xmm2
        inc ecx
        cmp ecx,8
        jb sum

        ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla xmm5 = sum(y)

        xor ecx,ecx
        movsd xmm6,[zero]
sum_x_y:
        movsd xmm2,[r12+rcx*8]
        movsd xmm7,[concentrazioni+ecx*8]
        mulsd xmm2,xmm7
        addsd xmm6,xmm2
        inc ecx
        cmp ecx,8
        jb sum_x_y

        ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla xmm5 = sum(y) xmm6 = sum(xy)

        movq xmm7,xmm0
        mulsd xmm7,xmm5
        movq xmm8,xmm3
        mulsd xmm8,xmm6
        subsd xmm7,xmm8
        divsd xmm7,xmm4

        ; xmm7 = a! ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla xmm5 = sum(y) xmm6 = sum(xy)

        movq xmm8,xmm1
        mulsd xmm8,xmm6
        movq xmm9,xmm5
        mulsd xmm9,xmm3
        subsd xmm8,xmm9
        divsd xmm8,xmm4

        ;xmm8 = b!  xmm7 = a! ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla xmm5 = sum(y) xmm6 = sum(xy)

        movq xmm0,xmm7
        movq xmm1,xmm8

        pop     rcx
        pop     rbp
        ret
;-------------------------------------------------------------------------------------------------------------

main:
        push    rbx                     ; salviamo nello stack rbx
        jmp     analisi                 ; se si vogoliono saltare la stampa dei dati


print_debug_message:
        ;printa il primo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg1               
        mov     rdx, 18                 ; byte della stringa
        syscall                         ; system call

        ;print array
        lea     rdi,[red_laser]
        call print_array
        
        ;printa il secondo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg2          
        mov     rdx, 21                 ; byte della stringa
        syscall                         ; system call

        ;print array
        lea     rdi,[orange_laser]
        call    print_array

        ;printa il terzo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg3         
        mov     rdx, 15                 ; byte della stringa
        syscall                         ; system call

        ;print array
        lea     rdi,[concentrazioni]
        call    print_array

        
analisi:
; calcoli del logaritmo
        ;red laser
        lea rdi,[red_laser]
        call log

        ;print array
        ;lea     rdi,[red_laser]
        ;call print_array

        ;orange laser
        lea rdi,[orange_laser]
        call log

        ;print array
        ;lea     rdi,[orange_laser]
        ;call print_array

;linear regression
        ;laser rosso
        lea     rdi,[red_laser]
        call linear_regression


        ;calcolo di k
        divsd   xmm1,[L]        ;k_red = abs(m_red / L)  
        mulsd   xmm1,[minus_one] 
        mov     rdi, k_red          
        movq    xmm0,xmm1
        mov     rax, 1
        call    printf         
        
        ;orange laser
        lea     rdi,[orange_laser]
        call    linear_regression


        ;calcolo di k
        divsd   xmm1,[L]        ;k_red = abs(m_red / L)  
        mulsd   xmm1,[minus_one] 
        mov     rdi, k_red          
        movq    xmm0,xmm1
        mov     rax, 1
        call    printf 


        pop     rbx                     ; ripristino rbx
        ret

