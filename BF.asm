.model tiny
.data
  swich db 0
  fileName db 128 dup(?)
  fileBuffer db 10000 dup(?)
  ;inputBuffer db 10000 dup(?)
  buffer dw 10000 dup(?)
  handle db ? ; byte variable for file handle
  charBuffer dw ?
.code   
ORG 0100h
start:
  pop ax
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
    mov al, [fileBuffer+si]
    call printChar
    mov ah, [swich] ; SWICH the command evaluation
    cmp al,0
    jne plus
    jmp cont
    plus:
        cmp ax, 2Bh ; +
        jne minus
        inc [buffer+di]
        jmp mainSwitch
    minus:
        cmp ax, 2Dh ; -
        jne next
        dec [buffer+di]
        jmp mainSwitch
    next:
        cmp ax, 3Eh ; >
        jne prev
        inc di
        jmp mainSwitch
    prev:
        cmp ax, 3Ch ; <
        jne loops
        dec di
        jmp mainSwitch
    loops:
        cmp ax, 5Bh ; [
        jne loopsActivate
        inc cx
        mov ax,[buffer+di]
        cmp al, 0
        je disable
        push si
        jmp mainSwitch
        disable:
          inc [swich] ; disable command evaluation except for 0x015D
          jmp mainSwitch
    loopsActivate:
        cmp ax, 15Bh ; enable command evaluation 015Dh
        jne loopend
        inc cx
        jmp mainSwitch
    loopend:
        cmp ax, 5Dh ; ]
        jne loopendActivate
        dec cx
        mov ax,[buffer+di]
        ;call printChar
        cmp al, 0
        jne b
        ;call printChar
        dec cx
        jmp mainSwitch
        b:
        pop si
        ;inc cx
        dec si
        jmp mainSwitch
    loopendActivate:
        cmp ax, 15Dh ; enable command evaluation 015Dh
        jne print
        dec cx
        cmp cx,0
        jne mainSwitch
        ;call printChar
        dec [swich]
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
        mov [buffer+di], ax
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
    push cx
    mov ah,3Fh ;read file directive
    mov bl,0;give bx the file hendle
    mov dx, offset charBuffer;buffer
    mov cx,1;one byte to read
    int 21h
    cmp ax,0
    jne c
        mov [charBuffer],0FFFFh
    c:
    mov ax,[charBuffer]
    call printChar
    pop cx
    ret
readChar endp

printChar proc
  mov ah, 2 ; Specify DOS "character Output" function 
  mov dl, al ; Move character into dl 
  int 21h ; Call DOS
  ret
printChar endp
end start