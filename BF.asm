.model tiny
.code
;org 100h
filename db "text.txt", 0
buffer db 10000 dup(0)
start:
    mov ah, 3dh         ; Open file function
    mov al, 0           ; Open file for reading
    lea dx, filename    ; Load filename into DX
    int 21h             ; Call DOS interrupt
    mov bx, ax          ; Store file handle in BX

read_loop:
    mov ah, 3fh         ; Read from file function
    mov bx, ax          ; File handle
    lea dx, buffer      ; Buffer to read into
    mov cx, 1         ; Number of bytes to read
    int 21h             ; Call DOS interrupt

    cmp ax, 0           ; Check if end of file
    je close_file       ; If so, exit loop

    mov ah, 40h         ; Write to stdout function
    mov bx, 1           ; File handle for stdout
    lea dx, buffer      ; Buffer to write from
    int 21h             ; Call DOS interrupt

    jmp read_loop       ; Continue reading

close_file:
    mov ah, 3eh         ; Close file function
    int 21h             ; Call DOS interrupt

    mov ah, 4ch         ; Exit program function
    int 21h             ; Call DOS interrupt
end start