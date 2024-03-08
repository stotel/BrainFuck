.model tiny

.data
    fileName db 128 dup(?)
.code
	org 100h
start:
    mov di, -1
    mov si, 0082h         ; DS:DX -> data to write (command line)
    read:
        lodsb
        inc di
        cmp al,0Dh
        je cont1
        mov [fileName+di],al
        jmp read
    cont1:
    mov [fileName+di],0
    mov si,offset fileName
    printName:
        lodsb 
        cmp al,0
        je cont2
        mov ah, 2 ; Specify DOS "character Output" function 
        mov dl, al ; Move character into dl 
        int 21h ; Call DOS
        jmp printName
    cont2:    
    mov ax, 4C00h       ; AH=4Ch, AL=00h -> exit (0)
    int 21h             ; Call MSDOS
end start

	; http://www.ctyme.com/intr/rb-2791.htm
    ;mov ah, 40h         ; DOS 2+ - WRITE - WRITE TO FILE OR DEVICE
    ;mov bx, 1           ; File handle = STDOUT
    ;xor ch, ch
    ;mov cl, ds:[0080h]  ; CX: number of bytes to write
    ;mov dx, 81h         ; DS:DX -> data to write (command line)
    ;int 21h             ; Call MSDOS

    ; http://www.ctyme.com/intr/rb-2974.htm
    ;mov ax, 4C00h       ; AH=4Ch, AL=00h -> exit (0)
    ;int 21h             ; Call MSDOS