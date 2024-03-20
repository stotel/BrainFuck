.model tiny
.data
  swich db 0
  enterBuf db 0Dh,0Ah,'$'
  fileBuffer db 10000 dup(?)
  buffer dw 10000 dup(?)
  charBuffer db ?
.code   
ORG 0100h
start:

  findNameEnd:;put 0 at the end of command line args
    mov cl, ds:[80h]
    mov bx, 81h
    add bx, cx
    mov byte ptr [bx], 0
  openFile:
    mov dx, 82h ; Address filename with ds:dx 
    mov ah, 3Dh ; DOS Open-File function number 
    mov al, 0 ; 0 = Read-only access
    int 21h ; Call DOS to open file
  readCodeFile:
    mov ah,3Fh ;read file directive
    mov bl,al;give bx the file hendle
    mov dx, offset fileBuffer;buffer
    mov cx,10000;10000 byte to read
    int 21h
    mov si,ax
    mov [fileBuffer+si],0
  mov di,offset buffer
  mov si,offset buffer
  clear:
    mov word [si], 0    ; Store zero in current array element (dword)
    ;dec cx
    inc si
    inc si       ; Move to next element
    loop clear      ; Loop until counter reaches zero (CX)
  mov si,-1
  mainSwitch:
    inc si
    mov al,[fileBuffer+si]
    mov ah,[swich]
    cmp ax,0
    jne plus
    jmp cont
    plus:
        cmp ax, 2Bh ; +
        jne minus
        inc word [di]
        ;jmp mainSwitch
    minus:
        cmp ax, 2Dh ; -
        jne next
        dec word [di]
        ;jmp mainSwitch
    next:
        cmp ax, 3Eh ; >
        jne prev
        inc di
        inc di
        ;jmp mainSwitch
    prev:
        cmp ax, 3Ch ; <
        jne loopstart
        dec di
        dec di
        ;jmp mainSwitch
    loopstart:
        cmp al, 5Bh ; [
        jne loopend
        push si
        cmp word[di],0
        jne valid
        inc [swich]
        ;jmp mainSwitch
        valid:
        jmp mainSwitch
    loopend:
        cmp al, 5Dh ; ]
        jne print
        pop ax
        cmp word [di],0
        jne validd
        cmp [swich],0
        je ok
        dec [swich]
        ok:
        jmp mainSwitch
        validd:
        mov si,ax
        dec si
        jmp mainSwitch
    print:
        cmp ax, 2Eh ; .
        jne readd
        mov ax, word [di]
        cmp al,0Ah
        jne pr
        mov ah, 09h             ; DOS Interrupt ah=9h print $ terminated string
        mov dx, offset enterBuf      ; Address of msg 
        int 21h                 ; Int 21h/ah=9h Print msg 
        jmp mainSwitch
        pr:
        mov ah, 2 ; Specify DOS "character Output" function 
        mov dl, al ; Move character into dl 
        int 21h ; Call DOS
        ;jmp mainSwitch
    readd:
        cmp ax, 2Ch ; ,
        jne toStart
        char:
          mov ah,3Fh ;read file directive
          mov bx,0;give bx the file hendle
          mov dx,offset charBuffer;buffer
          mov cx,1;one byte to read
          int 21h
          cmp ax,0
          jne c
            mov word [di],0FFFFh
            jmp mainSwitch
          c:
          mov al, [charBuffer]
          cmp al,0Dh
          je char
          mov word [di],al
          ;jmp mainSwitch
    toStart:
        jmp mainSwitch
    cont:
        mov ax, 4C00h ; end program code
        int 21h ; end program
end start