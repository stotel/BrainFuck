.model tiny
.data
  fileName db "D:\Projects\School\BrainFuck\TEST1.B",0
  fileBuffer dw 10000 dup(?)
  handle db ? ; byte variable for file handle
.code   
ORG 0100h
start:
  mov cx,10000
  mov ax, 0       ; Set accumulator (EAX) to zero (represents two zeros for dword)
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
  call readChar
  call printChar
  cont:
    mov ax, 4C00h;end program code
    int 21h;end program

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

