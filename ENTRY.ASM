.model tiny
.data
  swich db 0
  ;fileName db 128 dup(?)
  fileBuffer db 10000 dup(?)
  ;inputBuffer db 10000 dup(?)
  buffer dw 10000 dup(?)
  ;handle db ? ; byte variable for file handle
  charBuffer dw ?
  ;disabledAt dw ?
  enterBuf db 0Dh,0Ah,'$'
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
  mov cx,10000
  mov ax, 0       ; Set accumulator (EAX) to zero (represents two zeros for dword)
  mov si,offset buffer
  clear:
    mov word [si], ax    ; Store zero in current array element (dword)
    dec cx
    add si, 2       ; Move to next element
    loop clear      ; Loop until counter reaches zero (CX)
  ;openFile:
    ;mov dx, offset fileName ; Address filename with ds:dx 
    ;mov ah, 3Dh ; DOS Open-File function number 
    ;mov al, 0 ; 0 = Read-only access
    ;int 21h ; Call DOS to open file
    ;mov [handle], al;store handle
    ;mov dx,0
  mov si,-1
  mov di,0
  mov cx,0
  ;call dumpMemory
  mainSwitch:
    inc si
    ;mov ax,offset di
  ;xchg al,ah
  ;call printChar;print test
  ;xchg al,ah
  ;mov ax, word [buffer+si]
  ;call printChar
  ;mov al,' '
  ;call printChar
    ;cmp si,77
    ;jne notDump1
    ;call dumpMemory
    ;notDump1:
    ;cmp si,286;323;215
    ;jne notDump
    ;call dumpMemory
    ;notDump:
    mov al,[fileBuffer+si]
    ;call printChar
    mov ah,[swich]
    ;xchg al,ah
    ;call printChar
    ;xchg al,ah
    cmp ax,0
    jne plus
    jmp cont
    plus:
        cmp ax, 2Bh ; +
        jne minus
        inc word [buffer+di]
        jmp mainSwitch
    minus:
        cmp ax, 2Dh ; -
        jne next
        dec word [buffer+di]
        jmp mainSwitch
    next:
        cmp ax, 3Eh ; >
        jne prev
        add di,2
        jmp mainSwitch
    prev:
        cmp ax, 3Ch ; <
        jne loopstart
        sub di,2
        jmp mainSwitch
    loopstart:
        cmp al, 5Bh ; [
        jne loopend
        push si
        ;inc cx
        cmp word[buffer+di],0
        jne valid
        inc [swich]
        jmp mainSwitch
        valid:
        jmp mainSwitch
    loopend:
        cmp al, 5Dh ; ]
        jne print
        mov ax,si
        pop si
        ;mov ax, word [buffer+di]
        ;xchg al,ah
        ;call printChar;print test
        ;xchg al,ah
        ;mov ax, word [buffer+di]
        ;call printChar
        ;mov ax,[buffer+di]
        cmp word [buffer+di],0
        jne validd
        ;push si
        ;pop si
        ;pop si
        cmp [swich],0
        je ok
        dec [swich]
        ok:
        mov si,ax
        jmp mainSwitch
        validd:
        ;mov si,cx
        dec si
        jmp mainSwitch
    print:
        cmp ax, 2Eh ; .
        jne readd
        mov ax, word [buffer+di]
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
        ;call dumpMemory
        mov ax, 4C00h ; end program code
        int 21h ; end program
readChar proc
    ;push cx
    char:
    mov ah,3Fh ;read file directive
    mov bx,0;give bx the file hendle
    mov dx, offset charBuffer;buffer
    mov cx,1;one byte to read
    int 21h
    cmp ax,0
    jne c
        mov word [buffer+di],0FFFFh
        ret
    c:
    mov ax, [charBuffer]
    mov ah,0
    cmp ax,0Dh
    je char
    mov word [buffer+di],ax
    
    ret
readChar endp
dumpMemory proc
push si
mov si,0

a:
mov ax,word[buffer+si]
  xchg al,ah
  call printChar;print test
  xchg al,ah
  mov ax, word [buffer+si]
  call printChar
  mov al,' '
  call printChar
add si,2
;inc si
cmp si,10000
jne a
pop si
ret
dumpMemory endp

printChar proc
  ;push ax
  ;push di
  cmp al,0Ah
  jne pr
  mov ah, 09h             ; DOS Interrupt ah=9h print $ terminated string
  mov dx, offset enterBuf      ; Address of msg 
  int 21h                 ; Int 21h/ah=9h Print msg 
  ret
  pr:
  mov ah, 2 ; Specify DOS "character Output" function 
  mov dl, al ; Move character into dl 
  int 21h ; Call DOS
  ;pop di
  ;pop ax
  ret
printChar endp
end start