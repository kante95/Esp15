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
log_2e:
        dq 1.4425454561053044
log_e2:
        dq 0.6931471805599453
eight:
        dq 8.0
zero:
        dq 0.0

;section .bss
;   result: resq 1     ;quadword per i risultati


        section .text
main:
        push    rbx                     ; salviamo nello stack rbx


        ;printa il primo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg1               
        mov     rdx, 18                 ; byte della stringa
        syscall                         ; system call

        xor     ecx, ecx                ; ecx fa da contatore, azzeriamolo

print_red:
        push    rax                     ; salviamo il registro
        push    rcx                     ; salviamo il registro

        ;chiamata a printf
        mov     rdi, fmt                ; formato
        movq    xmm0, qword [red_laser+8*ecx]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
        call    printf                  

        pop     rcx                     ; ripristiniamo il registro
        pop     rax                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     print_red                  ; jump se ecx<8

        ;printa il secondo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg2          
        mov     rdx, 21                 ; byte della stringa
        syscall                         ; system call

        xor     ecx, ecx                 ; ecx fa da contatore, azzeriamolo


print_orange:
        push    rax                     ; salviamo il registro
        push    rcx                     ; salviamo il registro

        ;chiamata a printf
        mov     rdi, fmt                ; formato
        movq    xmm0, qword [orange_laser+8*ecx]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
        call    printf                  

        pop     rcx                     ; ripristiniamo il registro
        pop     rax                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     print_orange             ; jump se ecx<8

        ;printa il terzo messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg3         
        mov     rdx, 15                 ; byte della stringa
        syscall                         ; system call

        xor     ecx,ecx

print_conc:
        push    rax                     ; salviamo il registro
        push    rcx                     ; salviamo il registro

        ;chiamata a printf
        mov     rdi, fmt                ; formato
        movq    xmm0, qword [concentrazioni+8*ecx]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
        call    printf                  

        pop     rcx                     ; ripristiniamo il registro
        pop     rax                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     print_conc             ; jump se ecx<8


; calcoli con la fpu
        ;printa il quarto messaggio
        mov     rax, 1                  ; system call write
        mov     rdi, 1                  ; standard output
        mov     rsi, msg4         
        mov     rdx, 22                 ; byte della stringa
        syscall                         ; system call

        xor     ecx,ecx
log_loop_red:
        ;logaritmo in base e 
        fld qword [log_e2]              ;st0 = ln2
        fld qword [red_laser+ecx*8]     ;st0 = x st1 = ln2
        fyl2x                           ;st0 = ln2*log_2(x)        
        fstp qword [red_laser+ecx*8]
        ;fstp                            ;puliamo lo stack della fpu

        push    rax                     ; salviamo il registro
        push    rcx                     ; salviamo il registro

        ;stampa il risultato
        mov     rdi, fmt                ; formato
        movq    xmm0, qword [red_laser+ecx*8]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
        call    printf                  

        pop     rcx                     ; ripristiniamo il registro
        pop     rax                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     log_loop_red            ; jump se ecx<8

;printa il quinto messaggio
        ;mov     rax, 1                  ; system call write
        ;mov     rdi, 1                  ; standard output
        ;mov     rsi, msg5         
        ;mov     rdx, 27                 ; byte della stringa
        ;syscall                         ; system call

        xor     ecx,ecx
log_loop_orange:
        ;logaritmo in base e 
        fld qword [log_e2]              ;st0 = 1
        fld qword [orange_laser+ecx*8]  ;st0 = x st1 = 1
        fyl2x                           ;st0 = log_2(x)        
        fstp qword [orange_laser+ecx*8]
        ;fstp                            ;puliamo lo stack della fpu

        push    rax                     ; salviamo il registro
        push    rcx                     ; salviamo il registro

        ;stampa il risultato
        mov     rdi, fmt                ; formato
        movq    xmm0, qword [orange_laser+ecx*8]; numero
        mov     rax, 1                  ;abbiamo usato un reistro xmm
;        call    printf                  

        pop     rcx                     ; ripristiniamo il registro
        pop     rax                     ; ripristiniamo il registro

        inc     ecx                     ; incrementiamo il contatore
        cmp     ecx,8                   ; loop su 8 elementi
        jb     log_loop_orange            ; jump se ecx<8

;Linear Fitting!!!!!!

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
sum_red:
        movsd xmm2,[red_laser+ecx*8]
        addsd xmm5,xmm2
        inc ecx
        cmp ecx,8
        jb sum_red

        ;xmm1 = sum(w),xmm0 = sum(x^2), xmm3 = sum(x), xmm4 = nabla xmm5 = sum(y)

        xor ecx,ecx
        movsd xmm6,[zero]
sum_x_y:
        movsd xmm2,[red_laser+ecx*8]
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

        ;stampa il risultato
        mov     rdi, stampa_a_b               
        movq    xmm0,xmm7
        movq    xmm1,xmm8
        mov     rax, 2                  ;abbiamo usato due registri xmm
        call    printf         

        pop     rbx                     ; ripristino rbx
        ret

