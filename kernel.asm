bits 16
org 0x1000

start:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:pm_entry   ; FAR jump

; -------------------------
; PROTECTED MODE
; -------------------------
bits 32
pm_entry:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000       ; stack

    mov word [0xB8000], 0x0F4B   ; 'K'

    cli
    hlt

; -------------------------
; GDT
; -------------------------
gdt_start:
    dq 0x0000000000000000

    dq 0x00CF9A000000FFFF  ; CODE
    dq 0x00CF92000000FFFF  ; DATA

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10
