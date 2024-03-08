.model tiny
.data
  fileName db 128 dup(?)
  buffer dw 10000 dup(?)
  handle db ? ; byte variable for file handle
  charBuffer db ?
.code   
ORG 0100h
start:
  call readFileName
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
  readCodeFile:
    mov ah,3Fh ;read file directive
    mov bl,[handle];give bx the file hendle
    mov dx, offset charBuffer;buffer
    mov cx,1;one byte to read
    int 21h
    cmp ax,0
    je cont
    mov al,[charBuffer]
    call printChar
    jmp readCodeFile
  ;call readChar
  ;call printChar
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