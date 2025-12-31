bits 16
org 0x7C00

start:
    mov si, msg
.print:
    lodsb
    cmp al, 0
    je load_stage2
    mov ah, 0x0E
    int 0x10
    jmp .print

load_stage2:
    mov bx, 0x1000        ; load address
    mov ah, 0x02          ; BIOS read
    mov al, 1             ; sectors to read
    mov ch, 0
    mov cl, 2             ; sector 2
    mov dh, 0
    mov dl, 0x00          ; floppy
    int 0x13

    jmp 0x0000:0x1000     ; jump to stage 2

msg db "Stage 1 OK -> Loading Stage 2", 0

times 510 - ($ - $$) db 0
dw 0xAA55

%if ($ - $$) > 512
    %error "Boot sector exceeds 512 bytes"
%endif
