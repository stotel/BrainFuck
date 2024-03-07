.model small
.data
  fileName db "text.txt"
  fileBuffer db 10000 dup(?)
.code   
ORG 0100h
start:

    mov ax, 4C00h
    int 21h


end start

