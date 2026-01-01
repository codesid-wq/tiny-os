; Tell NASM this code starts in 16-bit real mode
bits 16

; This code is loaded by Stage 1 at address 0x1000
org 0x1000

start:
    cli                     ; Disable interrupts (no IDT yet, safety)

    lgdt [gdt_descriptor]   ; Load the Global Descriptor Table

    mov eax, cr0            ; Read control register CR0
    or eax, 1               ; Set bit 0 (enable protected mode)
    mov cr0, eax            ; Write back to CR0

    ; Far jump clears prefetch queue and enters 32-bit mode
    jmp CODE_SEG:pm_entry

; ================================
; 32-BIT PROTECTED MODE CODE
; ================================

bits 32

pm_entry:
    mov ax, DATA_SEG        ; Load data segment selector
    mov ds, ax              ; Set DS
    mov es, ax              ; Set ES
    mov fs, ax              ; Set FS
    mov gs, ax              ; Set GS
    mov ss, ax              ; Set SS

    mov esp, 0x90000        ; Set up stack pointer (safe memory)

    mov esi, message - $$ + 0x1000 ; ESI points to our string
    mov edi, 0xB8000        ; EDI points to VGA text memory

print_loop:
    lodsb                   ; Load byte from [ESI] into AL, ESI++
    cmp al, 0               ; Check for null terminator
    je done                 ; If 0, string is finished

    mov ah, 0x0F            ; White text on black background
    stosw                   ; Store AX to [EDI], EDI += 2
    jmp print_loop          ; Repeat for next character

done:
    cli                     ; Disable interrupts
    hlt                     ; Halt CPU
    jmp done                ; Safety loop (never exit)

; ================================
; DATA SECTION
; ================================

message:
    db "Hello from the protected-mode kernel!", 0

; ================================
; GLOBAL DESCRIPTOR TABLE (GDT)
; ================================

gdt_start:
    dq 0x0000000000000000   ; Null descriptor (required)

    dq 0x00CF9A000000FFFF   ; Code segment (base=0, limit=4GB)
    dq 0x00CF92000000FFFF   ; Data segment (base=0, limit=4GB)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Address of GDT

; Segment selector offsets
CODE_SEG equ 0x08
DATA_SEG equ 0x10
