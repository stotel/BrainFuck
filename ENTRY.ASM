.model tiny
.data
  swich db 0
  filePointer dw 0
  fileName db 128 dup(?)
  buffer dw 10000 dup(?)
  handle db ? ; byte variable for file handle
  charBuffer db ?
.code   
ORG 0100h
start:
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
    mov dx, offset charBuffer;buffer
    mov cx,1;one byte to read
    int 21h
    cmp ax,0
    jne c
    jmp cont
    c:
    inc filePointer
    ;main switch
    mov al,[charBuffer]
    mov ah, [swich]; SWICH the command evaluation
    plus:
      cmp ax,2Bh;+
      jne minus
      inc [buffer+di]
      jmp readCodeFile
    minus:
      cmp ax,2Dh;-
      jne next
      dec [buffer+di]
      jmp readCodeFile
    next:
      cmp ax,3Eh;>
      jne prev
      inc di
      jmp readCodeFile
    prev:
      cmp ax,3Ch;<
      jne loops
      dec di
      jmp readCodeFile
    loops:
      cmp ax,5Bh;[
      jne loopend
      cmp [buffer+di],0
      je disable
      push [filePointer]
      jmp readCodeFile 
      disable:
        inc [swich];disable command evaluetion exept for 0x015D
        jmp readCodeFile
    loopend:
      cmp ax,5Dh;]
      jne loopendActivate
      cmp [buffer+di],0
      je readCodeFile
      pop dx
      dec dx
      mov ah, 42h         ; DOS function for moving the file pointer
      mov al, 0           ; Move pointer to start
      mov bl, [handle]    ; File handle
      mov cx, 0         ; Offset high word
      int 21h             ; Call DOS interrupt   
      jmp readCodeFile
    loopendActivate:
      cmp ax,15Dh;];enable command evaluation 015Dh
      jne print
      ;call printChar
      dec [swich]
      jmp readCodeFile
    print:
      cmp ax,2Eh;.
      jne readd
      mov ax,[buffer+di]
      call printChar
      jmp readCodeFile
    readd:
      cmp ax,2Ch;,
      jne toStart
      call readChar
      mov [buffer+di],ax
      toStart:
      jmp readCodeFile
  cont:
    mov ax, 4C00h;end program code
    int 21h;end program

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
  mov si, 0;set pointer to the buffer start
  mov ah, 7 ; specify DOS "Character Input" function
  int 21h ; Call DOS. Character returned in al
  ret
readChar endp

printChar proc
  mov ah, 2 ; Specify DOS "character Output" function 
  mov dl, al ; Move character into dl 
  int 21h ; Call DOS
  ret
printChar endp
end start