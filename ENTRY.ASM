.model tiny
.data
  swich db 0
  fileName db 128 dup(?)
  fileBuffer db 10000 dup(?)
  ;inputBuffer db 10000 dup(?)
  buffer dw 10000 dup(?)
  handle db ? ; byte variable for file handle
  charBuffer dw ?
  ;disabledAt dw ?
.code   
ORG 0100h
start:
  ;pop ax
  call readFileName
  mov di,offset buffer
  mov cx,10000
  mov ax, 0       ; Set accumulator (EAX) to zero (represents two zeros for dword)
  mov si,offset buffer
  clear:
    mov [si], ax    ; Store zero in current array element (dword)
    dec cx
    add si, 2       ; Move to next element
    loop clear      ; Loop until counter reaches zero (CX)
  openFile:
    mov dx, offset fileName ; Address filename with ds:dx 
    mov ah, 3Dh ; DOS Open-File function number 
    mov al, 0 ; 0 = Read-only access
    int 21h ; Call DOS to open file
    mov [handle], al;store handle
    mov dx,0
  readCodeFile:
    mov ah,3Fh ;read file directive
    mov bl,[handle];give bx the file hendle
    mov dx, offset fileBuffer;buffer
    mov cx,10000;one byte to read
    int 21h
    mov si,ax
    mov [fileBuffer+si],0
    mov si,-1
    mov di,0
    mov cx,0
  mainSwitch:
    inc si
    mov al,[fileBuffer+si]
    call printChar

    mov ah,[swich]
    ;xchg al,ah
    ;call printChar
    ;xchg al,ah
    cmp al,0
    jne plus
    jmp cont
    plus:
        cmp ax, 2Bh ; +
        jne minus
        mov ax,[buffer+di]
        inc ax
        mov [buffer+di],ax
        jmp mainSwitch
    minus:
        cmp ax, 2Dh ; -
        jne next
        mov ax,[buffer+di]
        dec ax
        mov [buffer+di],ax
        jmp mainSwitch
    next:
        cmp ax, 3Eh ; >
        jne prev
        inc di
        inc di
        jmp mainSwitch
    prev:
        cmp ax, 3Ch ; <
        jne loops
        dec di
        dec di
        jmp mainSwitch
    loops:
        cmp al, 5Bh ; [
        jne loopend
        ;inc cx
        cmp[buffer+di],0
        jne valid
        inc [swich]
        jmp mainSwitch
        valid:
        push si
        jmp mainSwitch
    loopend:
        cmp al, 5Dh ; ]
        jne print
        mov ax,[buffer+di]
        ;xchg al,ah
        ;call printChar;print test
        ;xchg al,ah
        ;call printChar
        ;mov ax,[buffer+di]
        cmp al,0
        jne validd
        ;pop cx
        cmp [swich],0
        je ok
        dec [swich]
        ok:
        jmp mainSwitch
        validd:
        pop si
        dec si
        jmp mainSwitch
    print:
        cmp ax, 2Eh ; .
        jne readd
        mov ax, [buffer+di]
        call printChar
        jmp mainSwitch
    readd:
        cmp ax, 2Ch ; ,
        jne toStart
        call readChar
        ;mov [buffer+di], ax
    toStart:
        jmp mainSwitch
    cont:
        mov ax, 4C00h ; end program code
        int 21h ; end program
  

readFileName proc
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
  ret
readFileName endp

readChar proc
    ;push cx
    char:
    mov ah,3Fh ;read file directive
    mov bl,0;give bx the file hendle
    mov dx, offset charBuffer;buffer
    mov cx,1;one byte to read
    int 21h
    cmp ax,0
    jne c
        mov word [buffer+di],0FFFFh
        ret
    c:
    cmp [charBuffer],0Dh
    jne d
    jmp char
    d:
    mov ax,[charBuffer]
    mov ah,0
    mov word [buffer+di],ax
    mov ax,word [buffer+di]
        ;xchg al,ah
        ;call printChar;print test
        ;xchg al,ah
        ;call printChar
    ret
readChar endp

printChar proc
  push ax
  mov ah, 2 ; Specify DOS "character Output" function 
  mov dl, al ; Move character into dl 
  int 21h ; Call DOS
  pop ax
  ret
printChar endp
end start